#!/usr/bin/env python3
"""
Automated GitHub Issue Publisher for ARES Nav
Parses docs/ISSUES.md and creates 150 production-grade issues on GitHub with configurable delay.
"""

import os
import re
import sys
import time
import json
import subprocess
import argparse
from datetime import datetime

REPO = "YeamimHossainSajid/ARES-Nav"
ISSUES_FILE = os.path.join(os.path.dirname(__file__), "..", "docs", "ISSUES.md")
PROGRESS_FILE = os.path.join(os.path.dirname(__file__), "published_issues.json")
LOG_FILE = os.path.join(os.path.dirname(__file__), "publish_issues.log")

DOMAIN_LABELS = {
    1: "domain-geodesy",
    2: "domain-imagery-dtm",
    3: "domain-slope-hazards",
    4: "domain-pathfinding",
    5: "domain-flame-engine",
    6: "domain-isru-simulation",
    7: "domain-spatial-postgis",
    8: "domain-telemetry-streaming",
    9: "domain-astrobiology-science",
    10: "domain-astronaut-safety-hud"
}

def log(msg):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    formatted = f"[{timestamp}] {msg}"
    print(formatted, flush=True)
    with open(LOG_FILE, "a", encoding="utf-8") as f:
        f.write(formatted + "\n")

def parse_issues(file_path):
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    domain_sections = re.split(r"## Domain (\d+): ([^\n]+)", content)
    # domain_sections[0] is preamble
    # Then triplets: (domain_num, domain_title, domain_content)
    
    issues = []
    
    for i in range(1, len(domain_sections), 3):
        domain_num = int(domain_sections[i])
        domain_title = domain_sections[i+1].strip()
        domain_body = domain_sections[i+2]
        
        raw_issues = re.split(r"### Issue #(\d{3}): ([^\n]+)", domain_body)
        for j in range(1, len(raw_issues), 3):
            issue_num = raw_issues[j]
            issue_title = raw_issues[j+1].strip()
            issue_content = raw_issues[j+2].strip()
            
            # Extract component, spec, acceptance criteria
            comp_match = re.search(r"-\s+\*\*Component:\*\*\s+`?([^`\n]+)`?", issue_content)
            spec_match = re.search(r"-\s+\*\*Specification:\*\*\s+([\s\S]+?)(?=-\s+\*\*Acceptance Criteria:|\Z)", issue_content)
            crit_match = re.search(r"-\s+\*\*Acceptance Criteria:\*\*\s+([\s\S]+?)(?=\Z|###)", issue_content)
            
            component = comp_match.group(1).strip() if comp_match else "General"
            spec = spec_match.group(1).strip() if spec_match else ""
            criteria = crit_match.group(1).strip() if crit_match else ""
            
            issues.append({
                "number": issue_num,
                "title": f"[ENG-{issue_num}]: {issue_title}",
                "domain_num": domain_num,
                "domain_title": domain_title,
                "domain_label": DOMAIN_LABELS.get(domain_num, "enhancement"),
                "component": component,
                "specification": spec,
                "criteria": criteria,
                "raw": issue_content
            })
            
    return issues

def build_issue_body(issue):
    body = f"""### 🪐 Planetary Engineering Domain
**{issue['domain_title']}** (Domain {issue['domain_num']})

### 📦 Target Component / Subsystem
`{issue['component']}`

---

### 🔬 Technical & Scientific Specification
{issue['specification']}

---

### ✅ Acceptance Criteria Checklist
- [ ] Implement and verify against NASA/IAU mathematical formulation.
- [ ] {issue['criteria']}
- [ ] Add integration and unit test coverage.
- [ ] Document architecture decisions in repository wiki/docs.

---
*Reference: Part of the [ARES Nav Master 150 Issue Roadmap](https://github.com/YeamimHossainSajid/ARES-Nav/blob/main/docs/ISSUES.md).*
"""
    return body

def get_published_cache():
    if os.path.exists(PROGRESS_FILE):
        try:
            with open(PROGRESS_FILE, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            return {}
    return {}

def save_published_cache(cache):
    with open(PROGRESS_FILE, "w", encoding="utf-8") as f:
        json.dump(cache, f, indent=2)

def ensure_label_exists(label, color="00D8D6", description="Planetary Engineering Domain"):
    cmd = [
        "gh", "label", "create", label,
        "-R", REPO,
        "--color", color,
        "--description", description,
        "--force"
    ]
    subprocess.run(cmd, capture_output=True, text=True)

def create_github_issue(issue, dry_run=False):
    title = issue["title"]
    body = build_issue_body(issue)
    labels = [issue["domain_label"], "high-level-architecture", "space-apps-2026"]
    
    if dry_run:
        log(f"[DRY RUN] Would create Issue #{issue['number']}: {title}")
        return f"https://github.com/{REPO}/issues/DRY_RUN_{issue['number']}"
        
    cmd = [
        "gh", "issue", "create",
        "-R", REPO,
        "--title", title,
        "--body", body,
        "--label", ",".join(labels)
    ]
    
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode == 0:
        url = res.stdout.strip()
        log(f"Successfully created Issue #{issue['number']}: {url}")
        return url
    else:
        log(f"Error creating Issue #{issue['number']}: {res.stderr}")
        return None

def main():
    parser = argparse.ArgumentParser(description="Publish ARES Nav 150 Issues to GitHub")
    parser.add_argument("--delay", type=int, default=60, help="Seconds to wait between issues (default: 60)")
    parser.add_argument("--dry-run", action="store_true", help="Parse and log without calling GitHub API")
    parser.add_argument("--limit", type=int, default=150, help="Maximum issues to publish in this run")
    parser.add_argument("--start", type=int, default=1, help="Issue number to start from (1-150)")
    args = parser.parse_args()

    log(f"Starting ARES Nav Issue Publisher (delay={args.delay}s, limit={args.limit}, start={args.start}, dry_run={args.dry_run})")
    
    issues = parse_issues(ISSUES_FILE)
    log(f"Parsed {len(issues)} issues from docs/ISSUES.md")
    
    if len(issues) != 150:
        log(f"Warning: Expected 150 issues, parsed {len(issues)}")
        
    # Pre-create labels if not dry run
    if not args.dry_run:
        log("Ensuring domain labels exist on GitHub repository...")
        colors = ["C1440E", "00D8D6", "FF3344", "00E676", "FF9100", "B388FF", "336791", "231F20", "FFD700", "FF4081"]
        for idx, (d_num, label) in enumerate(DOMAIN_LABELS.items()):
            color = colors[(idx) % len(colors)]
            ensure_label_exists(label, color=color, description=f"Domain {d_num} Issues")
        ensure_label_exists("high-level-architecture", color="1F2937", description="Core Architecture")
        ensure_label_exists("space-apps-2026", color="02569B", description="NASA Space Apps Challenge 2026")

    published_cache = get_published_cache()
    count = 0

    for issue in issues:
        num = int(issue["number"])
        if num < args.start:
            continue
            
        if issue["number"] in published_cache:
            log(f"Skipping Issue #{issue['number']} (already published: {published_cache[issue['number']]})")
            continue
            
        if count >= args.limit:
            log(f"Reached limit of {args.limit} issues. Pausing run.")
            break
            
        log(f"Publishing Issue [{num}/150]: {issue['title']}...")
        issue_url = create_github_issue(issue, dry_run=args.dry_run)
        
        if issue_url:
            published_cache[issue["number"]] = issue_url
            if not args.dry_run:
                save_published_cache(published_cache)
            count += 1
            
            # Wait 1 minute (or configured delay) before next issue if more remain
            if count < args.limit and num < len(issues):
                log(f"Waiting {args.delay} seconds before publishing next issue (rate-limit compliance)...")
                time.sleep(args.delay)

    log(f"Finished publishing batch of {count} issues.")

if __name__ == "__main__":
    main()
