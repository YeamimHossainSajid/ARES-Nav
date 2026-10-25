# Contributing to ARES Nav

Thank you for your interest in contributing to **ARES Nav** — the open-source geodetic GIS and tactical navigation engine for Mars.

We are building a mission-critical platform designed for the highest standards of scientific precision and real-time graphics performance.

---

## 🎯 How to Contribute

1. **Pick an Issue from the Roadmap:**
   Browse the **[Master 150 Engineering Issues](docs/ISSUES.md)**. All issues are categorized across 10 specialized domains.
2. **Assign & Discuss:**
   Comment on the issue or create a GitHub Issue using the [Advanced Engineering Template](.github/ISSUE_TEMPLATE/engineering_issue.yml) to signal you are working on it.
3. **Fork & Branch:**
   ```bash
   git checkout -b feature/issue-XXX-short-title
   ```
4. **Code Standards:**
   - **Frontend (Dart/Flutter):** Strict linting (`flutter analyze`), zero unnecessary dynamic typing, memory leaks prevented on streams and controllers.
   - **Backend (Java 21/Spring Boot):** Modern Java 21 features (records, pattern matching, virtual threads), spatial queries optimized with GiST indexing.
   - **Scientific Rigor:** All geodetic calculations must reference authoritative NASA, IAU, or USGS standards (e.g., IAU 2000 Mars Reference Ellipsoid, MOLA Areoid).
5. **Verify Before Submitting:**
   ```bash
   # Frontend checks
   cd frontend
   flutter analyze
   flutter test

   # Backend checks
   cd ../backend
   ./gradlew test
   ```
6. **Pull Request Protocol:**
   - Reference the Issue number (e.g., `Closes #031`).
   - Include performance benchmark results where relevant (e.g., FPS metrics or query latency).

---

## 🛰️ Geodetic & Spatial Principles

- **Never assume Earth coordinate reference systems (CRS):** Mars has no sea level datum ($EPSG:4326$ is strictly mapped to IAU 2000 parameters in our PostGIS $SRID:49900$).
- **No Hardcoded Cloud Secrets:** Always read credentials from environment variables or `application.yml` profiles.
- **Offline First:** Astronaut helmet HUDs must function during orbital communication blackouts.

Thank you for helping humanity navigate the Red Planet!
