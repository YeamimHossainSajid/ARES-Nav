# 🚀 ARES Nav: The Master 150 Engineering Issues
### *Production-Grade Architectural Roadmap for the World's Best Martian Map*

This document outlines **150 advanced, production-grade issues** designed for senior aerospace software engineers, planetary cartographers, graphics pipeline developers, and distributed systems architects. 

---

## Table of Contents
- [Domain 1: Planetary Geodesy & Non-Terrestrial Projections (#001 - #015)](#domain-1-planetary-geodesy--non-terrestrial-projections)
- [Domain 2: High-Resolution Orbital Imagery & HiRISE DTM Tiling (#016 - #030)](#domain-2-high-resolution-orbital-imagery--hirise-dtm-tiling)
- [Domain 3: Terrain Slope Stability & Geotechnical Hazard Solvers (#031 - #045)](#domain-3-terrain-slope-stability--geotechnical-hazard-solvers)
- [Domain 4: Autonomous Surface Pathfinding & Kinodynamics (#046 - #060)](#domain-4-autonomous-surface-pathfinding--kinodynamics)
- [Domain 5: Flame Engine Simulation & Geospatial Viewport Bridge (#061 - #075)](#domain-5-flame-engine-simulation--geospatial-viewport-bridge)
- [Domain 6: In-Situ Resource Utilization (ISRU) Micro-Simulation (#076 - #090)](#domain-6-in-situ-resource-utilization-isru-micro-simulation)
- [Domain 7: Distributed Backend, PostGIS 16 & Spatial Geometry (#091 - #105)](#domain-7-distributed-backend-postgis-16--spatial-geometry)
- [Domain 8: Real-Time Telemetry Streaming & STOMP / Kafka (#106 - #120)](#domain-8-real-time-telemetry-streaming--stomp--kafka)
- [Domain 9: Astrobiological Field Notebook & Spectral Intelligence (#121 - #135)](#domain-9-astrobiological-field-notebook--spectral-intelligence)
- [Domain 10: Astronaut Tactical Safety HUD & PLSS Telemetry (#136 - #150)](#domain-10-astronaut-tactical-safety-hud--plss-telemetry)

---

## Domain 1: Planetary Geodesy & Non-Terrestrial Projections

### Issue #001: Implement IAU 2000 Mars Triaxial Ellipsoid Projection Engine
- **Component:** `frontend/lib/core/geodesy/`
- **Specification:** Earth spherical Mercator ($EPSG:3857$) assumes equal axes ($R=6378137\text{ m}$). Mars is triaxial ($a=3398.6\text{ km}$, $b=3393.8\text{ km}$, $c=3376.2\text{ km}$). Implement an IAU 2000 bi-axial approximation ($a=3396.19\text{ km}$, $c=3376.20\text{ km}$, flattening $f=0.00589$) projection library in pure Dart to convert geocentric coordinates to planetographic conformal coordinates with sub-meter accuracy.
- **Acceptance Criteria:** Unit tests verifying forward and inverse projection against NASA NAIF SPICE kernel `pck00010.tpc` within $< 0.05\text{ m}$ tolerance.

### Issue #002: Dynamic MOLA Gravitational Areoid Undulation Correction
- **Component:** `backend/src/main/java/gov/nasa/ares/geodesy/`
- **Specification:** The Martian vertical datum (Areoid) is defined by the Goddard Mars Gravity Model (GMM-3) degree 120 spherical harmonics. Write a Java service evaluating spherical harmonic coefficients $(C_{nm}, S_{nm})$ to compute geoid undulation $N(\phi, \lambda)$ at any given surface point to correct raw orbiter radio altimeter readings to true topographic height.
- **Acceptance Criteria:** Benchmark computing 10,000 coordinate conversions in $< 15\text{ ms}$ with zero garbage collector pauses.

### Issue #003: 0° to 360° Planetocentric vs. -180° to +180° Planetographic Anti-Meridian Normalization
- **Component:** `frontend/lib/map/converters/`
- **Specification:** NASA PDS datasets oscillate between East-positive planetocentric longitudes ($0^\circ - 360^\circ$) and planetographic longitudes ($-180^\circ - +180^\circ$). Construct a bidirectional normalization filter for `flutter_map` viewport boundaries that prevents infinite pan wrapping bugs across the $0^\circ$ Prime Meridian (Airy-0 crater).
- **Acceptance Criteria:** Seamless panning across Airy-0 with continuous polyline rasterization and zero marker snapping glitches.

### Issue #004: Local Tangent Plane (LTP) North-East-Down (NED) Frame Transformation
- **Component:** `frontend/lib/core/navigation/`
- **Specification:** For local EVA excursions within a $10\text{ km}$ radius of Habitat Alpha, spherical coordinates introduce excessive trigonometry overhead. Implement an LTP/NED frame transformation matrix centered on local base stations for micro-second vector distance and bearing calculations.
- **Acceptance Criteria:** Benchmark shows $8\times$ faster distance computation compared to Haversine on mobile ARM64 CPUs.

### Issue #005: Martian Atmospheric Refraction Ray-Tracing for Horizon Line-of-Sight
- **Component:** `frontend/lib/simulation/physics/`
- **Specification:** Due to Mars' thin ($6\text{ mbar}$) $CO_2$ atmosphere and steep thermal lapse rates ($\approx -2.5\text{ K/km}$), terrestrial 4/3 Earth radius refraction models fail. Implement an astronomical refraction ray-tracer utilizing real-time MEDA atmospheric temperature and pressure inputs to determine optical horizon visibility.
- **Acceptance Criteria:** Horizon distance matches MRO optical ground validation at Chryse Planitia within $1.2\%$.

### Issue #006: Crustal Remanent Magnetic Field Vector Interpolation
- **Component:** `frontend/lib/core/sensors/`
- **Specification:** Mars lacks a global dynamo. Strong localized crustal magnetic fields (up to $\pm 1500\text{ nT}$ in Terra Sirenum) corrupt electronic compass visors. Ingest Mars Global Surveyor MAG/ER crustal magnetic maps to calculate local magnetic declination offsets and display warning overlays when compass readings become unreliable.
- **Acceptance Criteria:** Automated alert triggered when magnetic deviation rate exceeds $15^\circ/\text{km}$.

### Issue #007: Sol-Sync Martian Solar Time (MSD & MTC) Precision Clockwork
- **Component:** `frontend/lib/core/time/`
- **Specification:** Implement a high-precision Mars Sol Date (MSD) and Coordinated Mars Time (MTC) chronometer based on Allison & McEwen (2000) formulations, accounting for the Martian axial precession, equation of time, and Sol duration ($88,775.244\text{ s}$).
- **Acceptance Criteria:** Verified against NASA Goddard Space Flight Center Mars24 algorithm to within $0.001\text{ s}$ precision.

### Issue #008: Great Ellipsoidal Geodesic Inverse Solver via Vincenty's Method
- **Component:** `frontend/lib/core/geodesy/`
- **Specification:** Port Vincenty's direct and inverse geodetic algorithms to the Martian oblate spheroid, guaranteeing convergence over antipodal trajectories (e.g., Olympus Mons to Hellas Basin).
- **Acceptance Criteria:** Zero non-convergence exceptions across 1,000,000 randomized synthetic coordinate pairs.

### Issue #009: Triaxial Mars 3D Mesh Normal Generator for Shaded Relief
- **Component:** `frontend/lib/map/shaders/`
- **Specification:** Write an OpenGL / Impeller shader computing vertex surface normals directly from triaxial planetary geodetics rather than planar UV textures to eliminate polar distortion artifacts.
- **Acceptance Criteria:** 60 FPS rendering on WebGL/CanvasKit at $4\text{K}$ resolution.

### Issue #010: Cartographic Gazetteer Gazetteer Placename Database Integration (USGS nomenclature)
- **Component:** `backend/src/main/java/gov/nasa/ares/science/gazetteer/`
- **Specification:** Ingest the complete International Astronomical Union (IAU) Working Group for Planetary System Nomenclature (WGPSN) database ($> 2,000$ Martian features: craters, fossae, planitiae, valles) into PostGIS with hierarchical spatial zoom indexing.
- **Acceptance Criteria:** Full-text spatial search returning features within $< 5\text{ ms}$ query latency.

### Issue #011: SPICE Kernel Ephemeris Integration (J2000 to Mars Body-Fixed Frame)
- **Component:** `backend/src/main/java/gov/nasa/ares/science/spice/`
- **Specification:** Build a JNI/FFI wrapper for NASA CSPICE library to calculate real-time sub-solar coordinates, sub-spacecraft points for Mars Odyssey, MRO, and MAVEN, and solar incidence angles.
- **Acceptance Criteria:** Orbiter nadir ground tracks predicted accurately within $20\text{ m}$ of public JPL HORIZONS vectors.

### Issue #012: Equidistant Cylindrical vs. Polar Stereographic Dynamic Projection Switcher
- **Component:** `frontend/lib/map/projections/`
- **Specification:** Equidistant Cylindrical projections distort severely at latitudes $|\phi| > 75^\circ$. Build an automatic projection switcher transitioning `flutter_map` to North/South Polar Stereographic projections when panning into the Planum Boreum or Planum Australe ice caps.
- **Acceptance Criteria:** Smooth animated transition with zero tile tearing or coordinate dislocation.

### Issue #013: MOLA Planetary Surface Curvature Occlusion Matrix
- **Component:** `frontend/lib/map/visibility/`
- **Specification:** Compute 3D geometric line-of-sight between two ground stations across the curved Martian horizon ($R=3,396\text{ km}$) with intervening topography (crater rims, shield volcanoes) using digital elevation profiles.
- **Acceptance Criteria:** Accurately marks line-of-sight radio comms loss between Habitat Alpha and Rover-01 behind the Belva crater rim.

### Issue #014: Inertial Dead-Reckoning Kalman Filter for GPS-Denied Navigation
- **Component:** `frontend/lib/core/navigation/ekf/`
- **Specification:** Implement an Extended Kalman Filter (EKF) fusing visual wheel odometry ($10\text{ Hz}$), 6-DOF IMU gyroscopes ($100\text{ Hz}$), and stellar star tracker readings to maintain rover positional covariance $< 1.5\text{ m}$ over a $10\text{ km}$ traverse without satellite GPS.
- **Acceptance Criteria:** Simulation validation over $50\text{ km}$ noisy traverse displaying $2\sigma$ error ellipses.

### Issue #015: Rover Wheel Slip Estimation on Deformable Regolith
- **Component:** `frontend/lib/simulation/kinematics/`
- **Specification:** Integrate Bekker-Wong terramechanics equations to calculate rover longitudinal and lateral slip rates as a function of slope angle, regolith cohesion ($c$), and internal friction angle ($\phi \approx 30^\circ$).
- **Acceptance Criteria:** Dead reckoning dynamically compensates for simulated $25\%$ slip on uphill loose basaltic sand.

---

## Domain 2: High-Resolution Orbital Imagery & HiRISE DTM Tiling

### Issue #016: HiRISE Stereo Digital Terrain Model (DTM) GeoTIFF Tiling Pipeline
- **Component:** `backend/src/main/java/gov/nasa/ares/raster/`
- **Specification:** Build an automated pipeline ingesting USGS PDS HiRISE 32-bit floating point DTMs (e.g., Jezero delta $0.25\text{ m/pixel}$), generating cloud-optimized GeoTIFFs (COGs), and carving them into TMS/WMTS tile pyramids.
- **Acceptance Criteria:** Generates Zoom levels 10 to 18 with bicubic elevation interpolation in $< 3\text{ minutes}$ for a $2\text{ GB}$ PDS IMG file.

### Issue #017: Multi-Source Dynamic Hillshading WebGL Shader with Ephemeris Solar Azimuth
- **Component:** `frontend/lib/map/shaders/hillshade/`
- **Specification:** Implement a custom GLSL/SkSL fragment shader computing real-time multidirectional hillshading from raw 16-bit elevation tiles using live SPICE solar azimuth ($\theta$) and elevation ($\alpha$) angles.
- **Acceptance Criteria:** Renders dynamic shadows cast by crater rims at dawn and dusk with zero pre-baked raster lag.

### Issue #018: Sparse Quadtree Mipmap Cache for Offline Astronaut Visor Operation
- **Component:** `frontend/lib/map/cache/`
- **Specification:** Construct an IndexedDB / SQLite LRU sparse tile cache storing high-resolution tiles along a buffered corridor of the planned EVA route, permitting offline HUD operation during orbital comms blackout.
- **Acceptance Criteria:** Pre-caches $50\text{ km}$ route at Zoom 16 ($< 250\text{ MB}$) in $< 45\text{ seconds}$ on Wi-Fi/UWB.

### Issue #019: HRSC Color-Shaded Relief Geo-Registration Correction
- **Component:** `backend/src/main/java/gov/nasa/ares/raster/hrsc/`
- **Specification:** ESA Mars Express HRSC level-4 orthomosaics occasionally exhibit spatial drift ($\Delta r \le 150\text{ m}$) relative to MOLA control networks. Implement automated tie-point matching using SIFT/ORB features against MOLA shaded basemaps to reproject HRSC tiles into sub-pixel alignment.
- **Acceptance Criteria:** Root Mean Square Error (RMSE) of alignment $< 5.0\text{ m}$ across the Chryse Planitia quadrangle.

### Issue #020: Tile Level-of-Detail (LOD) Hysteresis to Prevent Rapid Churn during Pinch-Zoom
- **Component:** `frontend/lib/map/tiling/`
- **Specification:** `flutter_map` can aggressively evict tiles during continuous pinch-to-zoom gestures. Build an LOD hysteresis filter that retains parent tile textures until all 4 child quadrant tiles have completed network decoding.
- **Acceptance Criteria:** Eliminates grey background flash during zoom operations on $3\text{G}$-speed Martian satellite links.

### Issue #021: Hyperspectral CRISM Mineralogy Overlays (Phyllosilicates & Olivine Beds)
- **Component:** `frontend/lib/observation/layers/`
- **Specification:** Process Compact Reconnaissance Imaging Spectrometer for Mars (CRISM) targeted observations (MTRDR spectral parameter maps) to render semi-transparent false-color layers highlighting hydrated smectite clays, carbonates, and jarosite.
- **Acceptance Criteria:** Toggling CRISM overlay renders spectral absorption band indices at $18\text{ m/pixel}$ resolution.

### Issue #022: Dynamic Tile Super-Resolution using Edge Convolution Neural Network
- **Component:** `frontend/lib/map/ai/`
- **Specification:** Integrate a lightweight TensorFlow Lite / ONNX model running on-device Neural Processing Units (NPUs) that applies $4\times$ super-resolution to low-resolution MOLA tiles where HiRISE coverage is missing.
- **Acceptance Criteria:** Inference executes in $< 12\text{ ms}$ per $256\times256$ tile tile on Apple Silicon and Snapdragon X Elite.

### Issue #023: Sub-Surface SHARAD Radar Sounder Ground-Penetrating Profile Visualizer
- **Component:** `frontend/lib/observation/radargram/`
- **Specification:** Ingest Shallow Radar (SHARAD) radargram products (radargram FITS files) along orbital tracks to display a vertical sub-surface radargram cross-section widget showing dielectric interfaces down to $1\text{ km}$ depth (detecting basal ice layers).
- **Acceptance Criteria:** Interactive cursor on map highlights exact corresponding column in the vertical radar reflection profile.

### Issue #024: Automated Tile Boundary Alpha Blending for Mismatched Sun Angle Mosaics
- **Component:** `backend/src/main/java/gov/nasa/ares/raster/blending/`
- **Specification:** Orbital tiles acquired at differing local times of day exhibit severe shadow direction mismatches. Implement multi-band Laplacian pyramid blending to seamlessly merge adjacent orbital swaths.
- **Acceptance Criteria:** Eliminates hard border seams across adjacent HiRISE observation strips in Jezero Crater.

### Issue #025: Cloud-Optimized GeoTIFF (COG) HTTP Range-Request Streaming Engine
- **Component:** `backend/src/main/java/gov/nasa/ares/raster/cog/`
- **Specification:** Implement a native HTTP byte-range reader that extracts individual tile windows directly from multi-gigabyte remote COG buckets without downloading the entire planetary raster.
- **Acceptance Criteria:** Sub-100ms latency to serve a $256\times256$ tile from a remote $8\text{ GB}$ GeoTIFF.

### Issue #026: Dynamic Contouring Vector Engine via Marching Squares on Client GPU
- **Component:** `frontend/lib/map/contours/`
- **Specification:** Instead of static contour raster tiles, execute Marching Squares algorithm on raw elevation matrix buffers to generate smooth, dynamic vector contour lines with customizable interval steps ($10\text{ m}, 25\text{ m}, 50\text{ m}$).
- **Acceptance Criteria:** Real-time contour re-generation on zoom level changes maintaining steady 60 FPS.

### Issue #027: Thermal Inertia (THEMIS Nighttime IR) Thermophysical Map Layer
- **Component:** `frontend/lib/map/layers/themis/`
- **Specification:** Integrate Mars Odyssey THEMIS Nighttime Infrared global mosaic ($100\text{ m/pixel}$) where bright regions indicate high thermal inertia (exposed bedrock, duricrust) and dark regions indicate fine dust hazards.
- **Acceptance Criteria:** Correctly maps bedrock vs loose silt around Chryse Planitia with interactive thermal inertia readout ($J\cdot m^{-2}\cdot K^{-1}\cdot s^{-1/2}$).

### Issue #028: NASA Trek Web Map Tile Service (WMTS) Failover Circuit Breaker
- **Component:** `frontend/lib/core/network/`
- **Specification:** The NASA Trek servers occasionally throttle high-frequency requests. Construct an exponential backoff circuit breaker that falls back to secondary USGS Astrogeology mirrors or local persistent cache upon HTTP 429/503 responses.
- **Acceptance Criteria:** Zero app crashes or frozen viewports during continuous 5-minute simulated network dropouts.

### Issue #029: WebP 16-Bit Lossless Compressed Tile Encoder
- **Component:** `backend/src/main/java/gov/nasa/ares/raster/encoder/`
- **Specification:** Standard PNG 16-bit elevation tiles consume excessive bandwidth. Implement custom WebP container encoding elevation into RGB channels with sub-millimeter precision at $65\%$ lower payload size than PNG.
- **Acceptance Criteria:** Network payload size reduced by $> 50\%$ while preserving $0.1\text{ m}$ vertical elevation fidelity.

### Issue #030: Real-Time Vector Placename Collision Detection & Priority Culling
- **Component:** `frontend/lib/map/labels/`
- **Specification:** When viewing dense crater regions (e.g., Noachis Terra), placename labels overlap. Implement a dynamic R-tree bounding box collision solver prioritizing major geological features (Craters $> 50\text{ km}$, Montes, Valles) over minor features.
- **Acceptance Criteria:** Zero overlapping text labels across all zoom levels during smooth panning.

---

## Domain 3: Terrain Slope Stability & Geotechnical Hazard Solvers

### Issue #031: 3x3 Sobel Gradient Kernel Elevation Slope Angle Calculation Engine
- **Component:** `backend/src/main/java/gov/nasa/ares/simulation/terrain/`
- **Specification:** Write an optimized SIMD algorithm applying a $3\times3$ Sobel-Feldman convolution operator across the MOLA DTM grid to calculate instantaneous slope angles in degrees:
  $$\text{Slope} = \arctan\left(\sqrt{\left(\frac{\partial z}{\partial x}\right)^2 + \left(\frac{\partial z}{\partial y}\right)^2}\right)$$
- **Acceptance Criteria:** Calculates slope array for a $500\times500$ raster grid in $< 5\text{ ms}$.

### Issue #032: Scree Slope Avalanche Triggering & Critical Repose Angle Engine
- **Component:** `backend/src/main/java/gov/nasa/ares/simulation/hazards/`
- **Specification:** Martian basaltic scree has an angle of repose between $32^\circ$ and $36^\circ$. Build a physical simulation evaluating whether vehicular vibration or astronaut EVA loading on slopes $> 25^\circ$ will trigger regolith failure and localized slope slumping.
- **Acceptance Criteria:** Automatically flags traverse segments with slope $> 25^\circ$ as "High Risk of Regolith Slip".

### Issue #033: Regolith Bearing Capacity Modeling via Terzaghi Soil Mechanics
- **Component:** `backend/src/main/java/gov/nasa/ares/simulation/geotech/`
- **Specification:** Calculate ultimate bearing capacity $q_{ult} = c N_c + \gamma D N_q + 0.5 \gamma B N_\gamma$ under Martian gravity ($g = 3.721\text{ m/s}^2$) for heavy pressurized rover tracks ($B=0.8\text{ m}$) across varied sediment members (delta topset silt vs basaltic bedrock).
- **Acceptance Criteria:** Prevents deployment of heavy Habitat Domes on low-bearing unconsolidated aeolian sand deposits.

### Issue #034: Sinkhole & Sub-Surface Lava Tube Roof Collapse Vulnerability Scanner
- **Component:** `backend/src/main/java/gov/nasa/ares/simulation/geotech/`
- **Specification:** Utilizing MRO HiRISE shadow depth measurements and SHARAD negative gravity anomalies in volcanic provinces (Tharsis, Elysium), identify skylights and map structural collapse hazards over sub-surface lava tubes.
- **Acceptance Criteria:** Generates red hazard exclusion buffer zones over known pit craters and collapse corridors.

### Issue #035: Boulder Distribution Spatial Frequency & $k$-Factor Hazard Index
- **Component:** `backend/src/main/java/gov/nasa/ares/simulation/hazards/`
- **Specification:** Implement Golombek's exponential boulder size-frequency distribution law:
  $$F(D) = k e^{-q D}$$
  Estimating the probability of boulders larger than rover ground clearance ($> 0.45\text{ m}$) from thermal inertia measurements.
- **Acceptance Criteria:** Predicts boulder field density with $> 85\%$ correlation to ground-truth Perseverance Navcam rock counts.

### Issue #036: Aeolian Ripple & Transverse Aeolian Ridge (TAR) Sand Trap Classification
- **Component:** `frontend/lib/simulation/hazards/`
- **Specification:** Ingest USGS high-resolution ripple morphological maps to classify Transverse Aeolian Ridges (TARs) that trapped the *Spirit* rover at "Troy". Mark impassable dunes with warning hatching.
- **Acceptance Criteria:** Automatic route re-routing around TAR fields with dune height $> 0.3\text{ m}$.

### Issue #037: Thermal Fracture & Polygon Ground Ice Expansion Crevasse Detection
- **Component:** `frontend/lib/observation/geology/`
- **Specification:** Map periglacial patterned ground polygons (ice-wedge networks in Utopia Planitia) to predict seasonal ground heave and micro-crevasse hazards for rover suspension.
- **Acceptance Criteria:** Generates polygonal warning mesh overlay in high-latitude regions ($|\phi| > 55^\circ$).

### Issue #038: Automated Incline Grading Certification for Base Infrastructure Deployment
- **Component:** `backend/src/main/java/gov/nasa/ares/simulation/validation/`
- **Specification:** Before authorizing placement of a $20\text{ m}$ Habitat Dome via `/api/v1/simulation/deploy`, verify that the total differential elevation variance across the entire footprint radius is $< 0.8\text{ m}$ (mean slope $< 4.5^\circ$).
- **Acceptance Criteria:** Rejects deployment request with detailed geometric height deviation map and levelling grading requirements.

### Issue #039: Extreme Diurnal Thermal Stress & Rock Spalling Risk Analyzer
- **Component:** `backend/src/main/java/gov/nasa/ares/science/thermal/`
- **Specification:** At Chryse Planitia, surface temperature swings from $-85^\circ\text{C}$ to $-15^\circ\text{C}$ within 6 hours. Calculate thermal gradient stresses in fractured basalt to predict daytime spalling and rockfall events below steep canyon walls.
- **Acceptance Criteria:** Temporal warning indicator activated during hours of maximum solar thermal expansion ($10:00 - 13:00\text{ LMST}$).

### Issue #040: Dynamic Dust Devil Trajectory & Pressure Drop Warning Predictor
- **Component:** `frontend/lib/simulation/weather/`
- **Specification:** Simulate dynamic convective vortices (dust devils) based on local midday thermal insolation and surface roughness ($z_0$). Render moving animated vortex vectors that track across Chryse Planitia.
- **Acceptance Criteria:** Alerts astronaut if predicted dust devil core trajectory intersects EVA path within $500\text{ m}$.

### Issue #041: Atmospheric Dust Optical Depth (Tau $\tau$) Attenuation Modeling
- **Component:** `backend/src/main/java/gov/nasa/ares/science/weather/`
- **Specification:** Ingest MER, MSL, and Perseverance optical depth tau measurements to model solar irradiance loss:
  $$I = I_0 e^{-\tau / \cos\theta_z}$$
  Predicting remaining battery life for solar-powered rover excursions.
- **Acceptance Criteria:** Triggers automatic return-to-base order if $\tau > 2.5$ (advancing regional dust storm).

### Issue #042: Slope Aspect & Insolation Solar Flux Calculator
- **Component:** `frontend/lib/simulation/solar/`
- **Specification:** Compute slope aspect (direction of maximum incline) to identify sun-facing north/south slopes. Calculate available solar energy on rover photovoltaic arrays oriented along sloped crater walls.
- **Acceptance Criteria:** Renders heat map displaying Watt-hours/$m^2$ per Sol across 3D terrain topography.

### Issue #043: Seasonal $CO_2$ Frost Condensation & Sublimation Surface Friction Matrix
- **Component:** `frontend/lib/simulation/hazards/`
- **Specification:** Model winter deposition of dry ice ($CO_2$ snow) at high latitudes ($|\phi| > 60^\circ$). Dynamically reduce tire-regolith coefficient of friction from $\mu = 0.65$ to $\mu = 0.15$ during seasonal frost accumulation.
- **Acceptance Criteria:** Prevents traversal of slopes $> 8^\circ$ when $CO_2$ frost layer thickness exceeds $2\text{ mm}$.

### Issue #044: Real-Time Seismic Ground Acceleration ShakeMap from InSight Events
- **Component:** `frontend/lib/observation/seismic/`
- **Specification:** When an InSight marsquake occurs (e.g., event `S1222a`), calculate peak ground acceleration (PGA) attenuation across the crust to render a real-time ShakeMap showing localized rockfall hazard zones.
- **Acceptance Criteria:** Renders circular isoseismal contours with attenuation modeled specifically for low-attenuation dry Martian megaregolith ($Q \approx 1000$).

### Issue #045: Slope Hazard Vector Field Visualization via Directional Flow Lines
- **Component:** `frontend/lib/map/shaders/flowfield/`
- **Specification:** Implement a GPU particle flow field animating the direction of steepest descent across canyon walls, enabling astronauts to instantly visualize gravity-assisted slide risks.
- **Acceptance Criteria:** Smooth animated flow particles running at 60 FPS without degrading map pan/zoom responsiveness.

---

## Domain 4: Autonomous Surface Pathfinding & Kinodynamics

### Issue #046: 3D Kinodynamic Field D* Pathfinding Algorithm with Incline Penalties
- **Component:** `backend/src/main/java/gov/nasa/ares/simulation/pathfinding/`
- **Specification:** Standard 2D $A^*$ ignores gravity and tilt. Implement Field $D^*$ on the 3D elevation raster, applying non-linear cost functions that penalize steep uphill energy expenditures ($E \propto \sin\theta$) and penalize side-slopes that exceed vehicle rollover angle ($> 22^\circ$).
- **Acceptance Criteria:** Path avoids steep direct climbs, naturally generating switchbacks up the walls of Belva Crater.

### Issue #047: Solar Transit Energy-Positive Route Optimization
- **Component:** `backend/src/main/java/gov/nasa/ares/simulation/pathfinding/`
- **Specification:** For solar rovers, the fastest route is not the optimal route. Build a time-dependent pathfinder that schedules traversals so the vehicle navigates sunlit crater rims while the sun is high, maximizing photovoltaic generation.
- **Acceptance Criteria:** Produces a route with $30\%$ higher end-of-traverse state-of-charge compared to Euclidean shortest path.

### Issue #048: Shadow Avoidance & Hypothermic Thermoregulation Routing in Deep Chasmata
- **Component:** `backend/src/main/java/gov/nasa/ares/simulation/routing/`
- **Specification:** In deep canyons (Valles Marineris, depth $7\text{ km}$), shadows persist for months. Compute shadow polygons cast by high plateau rims and route rovers to remain in thermal equilibrium, avoiding freezing of battery electrolytes.
- **Acceptance Criteria:** Minimizes time spent in deep shadows ($T < -100^\circ\text{C}$) to $< 30\text{ minutes}$ continuous exposure.

### Issue #049: Line-of-Sight Fresnel Comms Relay Route Optimization to Orbiting Relay Assets
- **Component:** `backend/src/main/java/gov/nasa/ares/simulation/routing/comms/`
- **Specification:** When out of direct line-of-sight of Habitat Alpha, calculate real-time line-of-sight elevation to passing orbiters (TGO, Odyssey) and surface relay towers, plotting routes that maintain $95\%$ communication continuity.
- **Acceptance Criteria:** Routes maintain UHF comms link ($401.5\text{ MHz}$) with at least one relay node throughout the traverse.

### Issue #050: Dynamic Obstacle Re-Routing for Moving Surface Rovers
- **Component:** `frontend/lib/simulation/navigation/`
- **Specification:** In multi-client simulation mode, rovers navigate the same terrain. Implement Velocity Obstacle (VO) or Reciprocal Velocity Obstacle (RVO2) collision avoidance to re-plan local path waypoints around oncoming autonomous vehicles.
- **Acceptance Criteria:** Two automated rovers on intersecting paths pass each other with minimum $10\text{ m}$ lateral clearance without coming to a full stop.

### Issue #051: Turn Radius & Ackerman Steering Kinematic Trajectory Smoothing
- **Component:** `frontend/lib/simulation/kinematics/`
- **Specification:** Discrete grid paths have sharp turns impossible for heavy 6-wheel rovers. Implement cubic Hermite or B-spline trajectory smoothing that conforms to Ackerman steering geometry and maximum steering angle ($45^\circ$).
- **Acceptance Criteria:** Generated path curvature $\kappa \le 1 / R_{min}$ at all continuous path points.

### Issue #052: Return-to-Base "Point of No Return" Consumable Bingo Fuel Boundary
- **Component:** `frontend/lib/core/navigation/bingo/`
- **Specification:** Dynamically compute the "Bingo Oxygen / Battery" envelope. Plot a real-time perimeter on the map beyond which the astronaut cannot return safely to Habitat Alpha given current walking speed and PLSS consumption.
- **Acceptance Criteria:** Visual red boundary contracts dynamically as suit battery and oxygen reserves diminish.

### Issue #053: Multi-Waypoint Traveling Salesperson Problem (TSP) with Sample Priority
- **Component:** `backend/src/main/java/gov/nasa/ares/simulation/tsp/`
- **Specification:** Solve NP-hard TSP routing for a mission requiring visits to 8 science outcrop waypoints, optimizing for sample scientific priority rating while completing the traverse before Sol sunset ($17:15\text{ MTC}$).
- **Acceptance Criteria:** Solves 15-waypoint tour in $< 200\text{ ms}$ using Lin-Kernighan heuristic with slope constraints.

### Issue #054: Scree Traverse Side-Slope Rollover Risk Prevention Solver
- **Component:** `backend/src/main/java/gov/nasa/ares/simulation/pathfinding/`
- **Specification:** Traveling perpendicular to a steep incline causes vehicle rollover. Disallow path segments where the cross-slope tilt vector angle $\beta > 15^\circ$, forcing perpendicular or fall-line ascents.
- **Acceptance Criteria:** Validates 0 rollover risk alerts along generated paths across crater rims.

### Issue #055: Emergency Direct Escape Vector Routing with Hazard Override
- **Component:** `frontend/lib/core/navigation/emergency/`
- **Specification:** When RED ALERT SOS is declared, standard fuel-saving routes are superseded. Compute the maximum allowable speed traverse to Habitat Alpha, accepting up to $20^\circ$ slopes and maximum rover powertrain output.
- **Acceptance Criteria:** Reduces calculated return time by $> 25\%$ compared to conservative nominal paths.

### Issue #056: Real-Time Dynamic Cost Grid Re-weighting on Weather Dust Front Alerts
- **Component:** `backend/src/main/java/gov/nasa/ares/simulation/pathfinding/`
- **Specification:** When an approaching dust front is detected, dynamically re-weight cost raster cells intersecting the storm perimeter with infinite penalty, forcing path recalculation to skirt the storm boundary.
- **Acceptance Criteria:** Path recalculation triggers and updates on client via WebSocket in $< 350\text{ ms}$.

### Issue #057: Autonomous Rover Return to Base on Comms Loss (Dead Reckoning Failsafe)
- **Component:** `frontend/lib/simulation/agents/`
- **Specification:** Build an autonomous state machine in Flame that triggers if WebSocket heartbeat is lost for $> 60\text{ seconds}$, causing simulated rovers to execute inverse dead-reckoning return along their exact inbound track.
- **Acceptance Criteria:** Rover safely returns to Habitat base perimeter autonomously without human control input.

### Issue #058: Paleochannel Navigational Sinuosity & Stream Gradient Profiler
- **Component:** `frontend/lib/observation/hydrology/`
- **Specification:** Ancient fluvial channels (Ares Vallis, Neretva Vallis) follow minimum gradient paths. Implement automated channel thalweg extraction that guides explorers along smooth ancient riverbeds rather than fractured surrounding plateaus.
- **Acceptance Criteria:** Automatically extracts and plots optimal center-line riverbed traverse for Neretva Vallis.

### Issue #059: Energy Consumption Estimation Engine via Complete Vehicle Mass Matrix
- **Component:** `backend/src/main/java/gov/nasa/ares/simulation/energy/`
- **Specification:** Compute power draw $P(t) = m g \sin\theta \cdot v + C_{rr} m g \cos\theta \cdot v + 0.5 \rho_{atm} C_d A v^3 + P_{avionics}$ accounting for astronaut payload mass ($180\text{ kg}$ with suit) and rover unladen mass ($2,500\text{ kg}$).
- **Acceptance Criteria:** Energy prediction accurate to within $5\%$ of actual simulated telemetry over a $15\text{ km}$ traverse.

### Issue #060: Micro-Topography Lidar Point Cloud Integration for Real-Time Path Smoothing
- **Component:** `frontend/lib/simulation/lidar/`
- **Specification:** Ingest localized synthetic $10\text{ cm}$ resolution rover LiDAR point clouds to detect small boulders invisible on orbital $463\text{ m}$ MOLA maps, executing local obstacle swerve maneuvers.
- **Acceptance Criteria:** Smoothly avoids $0.5\text{ m}$ boulder without breaking global path trajectory.

---

## Domain 5: Flame Engine Simulation & Geospatial Viewport Bridge

### Issue #061: Sub-Pixel Geospatial Anchor Projection Bridge between `flutter_map` and Flame
- **Component:** `frontend/lib/simulation/bridge/`
- **Specification:** `flutter_map` continuously updates its camera matrix during pan/zoom gestures. Construct a high-performance Flame `World` component listening to `MapEvent` streams that maps LatLng coordinates to canvas coordinates every game tick:
  $$\vec{V}_{flame} = \text{MapCamera}.\text{latLngToScreenPoint}(\text{LatLng}(\phi, \lambda))$$
  with zero frame jitter or position desynchronization.
- **Acceptance Criteria:** Position error between base map raster feature and Flame sprite $< 0.5\text{ pixels}$ at 60 FPS during fast multi-touch drag.

### Issue #062: MOLA Elevation Z-Buffer Isometric Depth Sorting for Ground Infrastructure
- **Component:** `frontend/lib/simulation/rendering/`
- **Specification:** When viewing the map with 3D tilt perspective, Flame sprites (Habitat Domes, Antennas) must sort their render order based on distance from the camera and terrain elevation to prevent far-side structures rendering on top of foreground crater rims.
- **Acceptance Criteria:** Correct painter's algorithm depth occlusion for 50 concurrent simulated buildings.

### Issue #063: Procedural Regolith Dust Particle System for Moving Rover Tires
- **Component:** `frontend/lib/simulation/particles/`
- **Specification:** Implement a GPU particle emitter in Flame generating low-gravity basaltic dust plumes behind moving rovers. Dust particles must settle at Martian gravity ($g = 3.721\text{ m/s}^2$) and drift according to active wind vectors (e.g., $18\text{ km/h ENE}$).
- **Acceptance Criteria:** Renders up to 1,000 active dust particles while maintaining $\ge 58\text{ FPS}$ on mobile web.

### Issue #064: Drag-and-Drop Infrastructure Placement Reticle with Live Slope Indicator
- **Component:** `frontend/lib/ui/simulation/`
- **Specification:** In Simulation Mode, allow users to drag virtual buildings (Solar Array, Habitat, Refinery) from the bottom drawer onto the map. While dragging, render an interactive ground reticle that turns green if slope $< 12^\circ$ and pulses red if slope exceeds safety limits.
- **Acceptance Criteria:** Live slope angle indicator updates under touch cursor with sub-$16\text{ ms}$ response time.

### Issue #065: 6-Wheel Rocker-Bogie Suspension Kinematics Simulation in Flame
- **Component:** `frontend/lib/simulation/rover/`
- **Specification:** Model the mechanical kinematics of the NASA Curiosity/Perseverance Rocker-Bogie suspension. As the rover traverses the micro-elevation grid, tilt the bogies and main differential chassis realistically without losing wheel-to-ground contact.
- **Acceptance Criteria:** Rover body pitch and roll angles conform accurately to underlying elevation terrain normals.

### Issue #066: Flame Engine Lifecycle Throttling during Observation Mode Switch
- **Component:** `frontend/lib/simulation/lifecycle/`
- **Specification:** To conserve device battery and prevent GPU overheating, when the user toggles to Lens 1 (Observation Mode), Flame's engine loop must be immediately paused (`pauseEngine()`) and its canvas detached or ignored via `IgnorePointer`.
- **Acceptance Criteria:** CPU/GPU consumption drops to $< 2\%$ baseline when Observation Lens is active.

### Issue #067: Solar Radiation Shadow Projection for 3D Habitat Structures
- **Component:** `frontend/lib/simulation/lighting/`
- **Specification:** Calculate 3D shadow volumes cast by deployed habitat domes and communication towers based on solar altitude and azimuth. Render soft directional shadows across the terrain surface.
- **Acceptance Criteria:** Shadow orientation and length perfectly match theoretical solar vector computed by SPICE kernel.

### Issue #068: Multi-Rover Spatial Collision Detection via Oriented Bounding Boxes (OBB)
- **Component:** `frontend/lib/simulation/collision/`
- **Specification:** Axis-Aligned Bounding Boxes (AABB) fail when rovers rotate. Implement Oriented Bounding Boxes (OBB) with the Separating Axis Theorem (SAT) to detect precise vehicle-to-vehicle and vehicle-to-building collisions.
- **Acceptance Criteria:** Detects collisions accurately at arbitrary vehicle yaw angles with zero false positives.

### Issue #069: Animated Comms Transmission Wave Pulses between Base and Rovers
- **Component:** `frontend/lib/simulation/effects/`
- **Specification:** Render pulsating circular radio waves expanding outward from Habitat Alpha to represent active RTK carrier frequency ($433.8\text{ MHz}$) transmissions, displaying signal attenuation degradation with distance.
- **Acceptance Criteria:** Smooth pulsating visual waves that scale correctly with map zoom levels.

### Issue #070: Procedural Wind Direction Arrows with Animated Streamlines
- **Component:** `frontend/lib/simulation/weather/`
- **Specification:** Ingest MEDA wind velocity vectors to render animated curved streamlines indicating regional atmospheric circulation across the Jezero basin floor.
- **Acceptance Criteria:** Velocity of streamline animation scales proportionally with actual wind speed ($10\text{ to }60\text{ km/h}$).

### Issue #071: Modular Power Grid Cable Routing & Underground Conduit Simulation
- **Component:** `frontend/lib/simulation/power/`
- **Specification:** Enable users to interconnect deployed Solar Arrays and Nuclear Kilopower Reactors to Habitat Domes via power conduit lines, computing resistive $I^2 R$ transmission line power losses across distances.
- **Acceptance Criteria:** Warns user if high-voltage DC conduit distance exceeds maximum allowable run without a transformer substation.

### Issue #072: Building Health Degradation from Continuous Aeolian Dust Abrasion
- **Component:** `frontend/lib/simulation/buildings/`
- **Specification:** Model the mechanical wear and tear on habitat exterior membranes from high-velocity windblown sand particles, slowly degrading building health percentage over simulated sols.
- **Acceptance Criteria:** Degradation rate scales with local wind speed and atmospheric optical depth ($\tau$).

### Issue #073: Interactive Heat Radiation Thermal Signatures in Night View Mode
- **Component:** `frontend/lib/simulation/thermal/`
- **Specification:** During Martian night ($T < -80^\circ\text{C}$), active habitats and rover radioisotope thermoelectric generators (RTGs) emit thermal infrared. Render thermal glow halos around active energy-consuming infrastructure.
- **Acceptance Criteria:** Infrared glow intensity corresponds directly to kilowatt thermal dissipation output.

### Issue #074: Flame Touch Tap-to-Inspect Entity Selection & Radial Context Menu
- **Component:** `frontend/lib/ui/simulation/`
- **Specification:** Tapping any Flame entity on the map opens an orbiting radial HUD context menu (e.g., *Inspect Telemetry*, *Toggle Power*, *Dispatch Rover*, *Decommission*).
- **Acceptance Criteria:** Radial menu springs open with smooth glassmorphic animation centered precisely over the tapped sprite.

### Issue #075: Multi-Touch Pinch-to-Rotate Viewport with Flame Sprite Billboard Alignment
- **Component:** `frontend/lib/simulation/camera/`
- **Specification:** When the user rotates the base map bearing using two-finger twist gesture, 2D UI billboards (health bars, name tags) must counter-rotate to remain horizontally readable to the user.
- **Acceptance Criteria:** All text labels maintain upright horizontal alignment regardless of map bearing angle ($0^\circ - 360^\circ$).

---

## Domain 6: In-Situ Resource Utilization (ISRU) Micro-Simulation

### Issue #076: Subsurface Permafrost Water-Ice Extraction Yield Simulator via SHARAD Data
- **Component:** `backend/src/main/java/gov/nasa/ares/simulation/isru/water/`
- **Specification:** Ingest SHARAD radar dielectric permittivity maps to locate subsurface water ice deposits in Utopia and Arcadia Planitia. Model thermal sublimation extraction wells (Rodwells) to compute daily water yield (liters/Sol) based on thermal input energy.
- **Acceptance Criteria:** Extraction yield accurately balances against thermal heater power consumption ($15\text{ kWh/liter}$).

### Issue #077: Atmospheric $CO_2$ Sabatier Methane/Oxygen Synthesis Plant Model
- **Component:** `backend/src/main/java/gov/nasa/ares/simulation/isru/propellant/`
- **Specification:** Model Sabatier reaction ($CO_2 + 4H_2 \to CH_4 + 2H_2 O$) coupled with water electrolysis ($2H_2 O \to 2H_2 + O_2$) for rocket propellant production. Track mass balance of methane and liquid oxygen production for the Mars Ascent Vehicle (MAV).
- **Acceptance Criteria:** Verifies stoichiometric $O_2 / CH_4$ mass ratio ($3.5 : 1$) with cryogenic storage boil-off losses.

### Issue #078: Photovoltaic Dust Deposition & Clearing Event Degradation Curve
- **Component:** `backend/src/main/java/gov/nasa/ares/simulation/isru/power/`
- **Specification:** Implement the historic Opportunity/Spirit solar panel dust degradation curve ($\approx 0.28\%$ power loss per Sol). Simulate random convective vortex "cleaning events" that abruptly restore power output by $15\% - 40\%$.
- **Acceptance Criteria:** Power curve exhibits realistic saw-tooth profile over a simulated 500-Sol mission duration.

### Issue #079: Kilopower Nuclear Fission Reactor Heat Balance & Brayton Cycle Efficiency
- **Component:** `backend/src/main/java/gov/nasa/ares/simulation/isru/nuclear/`
- **Specification:** Model a $10\text{ kWe}$ Kilopower nuclear reactor with Stirling/Brayton energy conversion. Calculate waste heat rejection via titanium-water heat pipe radiators into Mars' thin atmosphere.
- **Acceptance Criteria:** Simulates radiator freeze-out hazard if reactor thermal output falls below minimum operational core temperature.

### Issue #080: Regolith Sintering 3D Printing Habitat Construction Timeline Simulator
- **Component:** `backend/src/main/java/gov/nasa/ares/simulation/construction/`
- **Specification:** Simulate autonomous construction rovers using microwave/concentrated solar sintering of basaltic regolith to build radiation protection berms and landing pads. Track metric tons of regolith excavated and sintered per hour.
- **Acceptance Criteria:** Construction progress updates in real time based on rover power availability and distance to borrow pits.

### Issue #081: Environmental Control & Life Support System (ECLSS) Mass Balance
- **Component:** `backend/src/main/java/gov/nasa/ares/simulation/eclss/`
- **Specification:** Track habitat life support consumables: $O_2$ consumption ($0.84\text{ kg/crew/day}$), $CO_2$ removal via amine beds, potable water recycling ($98\%$ recovery efficiency), and nitrogen leakage buffer replenishment.
- **Acceptance Criteria:** Alerts mission control if buffer gas tank pressure drops below safe partial pressure limits ($p_{O2} < 19.5\text{ kPa}$).

### Issue #082: Regolith Basaltic Iron Extraction via Molten Regolith Electrolysis (MRE)
- **Component:** `backend/src/main/java/gov/nasa/ares/simulation/isru/mining/`
- **Specification:** Model high-temperature electrolysis ($1600^\circ\text{C}$) of iron-rich Martian regolith ($18\% FeO$) to extract structural metallic iron and silicon for solar cell manufacturing.
- **Acceptance Criteria:** Calculates high electrical energy requirements ($12\text{ MWh/ton}$) and generates slag byproduct inventories.

### Issue #083: MOXIE Solid Oxide Electrolysis Cell (SOEC) $O_2$ Production Emulator
- **Component:** `backend/src/main/java/gov/nasa/ares/simulation/isru/moxie/`
- **Specification:** Emulate the Mars 2020 MOXIE instrument ($CO_2 \to CO + \frac{1}{2}O_2$) operating at $800^\circ\text{C}$. Calculate oxygen purity ($> 99.6\%$) and voltage efficiency across varying atmospheric intake densities.
- **Acceptance Criteria:** Production rate matches MOXIE flight performance telemetry ($6 - 12\text{ g } O_2/\text{hour}$).

### Issue #084: Micro-Algae Photobioreactor Carbon Dioxide Scrubbing & Protein Yield
- **Component:** `backend/src/main/java/gov/nasa/ares/simulation/bio/`
- **Specification:** Model a secondary biological life support system utilizing *Spirulina* cyanobacteria arrays inside illuminated pressurized pods to sequester $CO_2$ and generate supplemental caloric biomass.
- **Acceptance Criteria:** Computes photon efficiency and water nutrient depletion rates under artificial LED spectral wavelengths.

### Issue #085: Cryogenic Propellant Zero-Boil-Off (ZBO) Thermal Insulation Model
- **Component:** `backend/src/main/java/gov/nasa/ares/simulation/cryo/`
- **Specification:** Liquid methane (boiling point $111\text{ K}$) and liquid oxygen (boiling point $90\text{ K}$) stored in vacuum-jacketed tanks with active cryocoolers. Model boil-off mass loss if cryocooler electrical power is cut.
- **Acceptance Criteria:** Computes tank boil-off venting rates accurately over a 48-hour power outage.

### Issue #086: Martian Concrete (Sulfur-Regolith Composite) Mixing & Curing Rates
- **Component:** `backend/src/main/java/gov/nasa/ares/simulation/materials/`
- **Specification:** Waterless Martian concrete blends molten elemental sulfur ($130^\circ\text{C}$) with regolith aggregate ($1:1$ ratio). Simulate compression strength ($> 40\text{ MPa}$) and curing time under rapid Martian atmospheric cooling.
- **Acceptance Criteria:** Generates material strength certification reports for simulated landing pad construction.

### Issue #087: Greenhouse Food Production Calories & Lighting Schedule Optimizer
- **Component:** `backend/src/main/java/gov/nasa/ares/simulation/agriculture/`
- **Specification:** Simulate hydroponic crop growth (potatoes, dwarf wheat, soybeans) under low atmospheric pressure ($p = 10\text{ kPa}$). Model growth cycles, daily water transpiration, and caloric output per square meter.
- **Acceptance Criteria:** Tracks total crop harvest dates and alerts if crew caloric requirements exceed greenhouse yield.

### Issue #088: Atmospheric Nitrogen Separation & Fertilizer Synthesis (Haber-Bosch)
- **Component:** `backend/src/main/java/gov/nasa/ares/simulation/chemistry/`
- **Specification:** Nitrogen constitutes only $2.6\%$ of Mars' atmosphere. Model cryogenic fractional distillation plants separating atmospheric $N_2$ and synthesizing ammonium nitrate fertilizer ($NH_4 NO_3$) for greenhouse agriculture.
- **Acceptance Criteria:** Accurately accounts for large volume of Martian air intake needed ($> 40\text{ m}^3\text{ air / kg } N_2$).

### Issue #089: Water Ice Hydrate Desorption from Gypsum & Smectite Clay Outcrops
- **Component:** `backend/src/main/java/gov/nasa/ares/simulation/geology/`
- **Specification:** In equatorial regions where permafrost ice is absent, hydrated minerals (sulfates, smectites containing $4\% - 8\%$ water by weight) can be heated ($450^\circ\text{C}$) to drive off structural water. Compute energy-per-liter yields from local mineral deposits.
- **Acceptance Criteria:** Links directly to CRISM mineral maps to prioritize mining sites with highest hydration absorption peaks.

### Issue #090: Automated Infrastructure Maintenance Scheduling & Spare Parts Inventory
- **Component:** `backend/src/main/java/gov/nasa/ares/simulation/logistics/`
- **Specification:** Model mean-time-between-failures (MTBF) for pumps, valves, and solar panel gimbals. Track 3D printer filament consumption to manufacture replacement titanium/PEEK spare parts in-situ.
- **Acceptance Criteria:** Dispatches maintenance work orders to nearest available autonomous robotic technician rover.

---

## Domain 7: Distributed Backend, PostGIS 16 & Spatial Geometry

### Issue #091: Custom PostGIS Spatial Reference Identifier (SRID 49900) for IAU Mars Ellipsoid
- **Component:** `backend/src/main/resources/db/`
- **Specification:** Standard PostGIS uses Earth $EPSG:4326$. Register the custom IAU 2000 Mars Coordinate Reference System ($SRID:49900$, semi-major $a=3396190$, semi-minor $b=3376200$) in `spatial_ref_sys` table so all `ST_Distance` and `ST_DWithin` queries operate natively on Martian ellipsoidal math.
- **Acceptance Criteria:** `ST_Distance(point1, point2)` returns geodesic distances conforming to NASA SPICE vectors within $< 0.1\%$ error.

### Issue #092: R-Tree GiST Spatial Indexing Optimization for Global Telemetry Queries
- **Component:** `backend/src/main/resources/db/indexes.sql`
- **Specification:** As simulation entities scale to tens of thousands of assets, naive spatial bounding box queries degrade. Tune PostgreSQL GiST spatial indexes with custom fill-factor and multi-column clustering on `(geom, sol_timestamp)`.
- **Acceptance Criteria:** Spatial bounding box queries (`ST_Contains`, `ST_Intersects`) execute in $< 3.5\text{ ms}$ over 500,000 spatial records.

### Issue #093: PostGIS Raster Engine Integration for Real-Time Polyline Elevation Profiles
- **Component:** `backend/src/main/java/gov/nasa/ares/simulation/raster/`
- **Specification:** Import the global MOLA DTM raster into PostGIS `raster` columns with $256\times256$ block tiling. Write a repository query using `ST_Intersection(rast, line)` and `ST_Value` to return an elevation cross-section array along any queried EVA polyline in a single database roundtrip.
- **Acceptance Criteria:** Returns 200-point elevation profile for a $50\text{ km}$ traverse in $< 25\text{ ms}$.

### Issue #094: Transactional Isolation & Optimistic Locking for Simultaneous Player Deployments
- **Component:** `backend/src/main/java/gov/nasa/ares/simulation/repository/`
- **Specification:** In multiplayer mode, two players deploying overlapping infrastructure at the same millisecond can cause phantom overlaps. Implement JPA `@Version` optimistic locking and spatial exclusion locks (`ST_Overlaps`) to guarantee clean transactional isolation.
- **Acceptance Criteria:** Zero duplicate infrastructure deployments under high-concurrency JMeter stress test ($1,000\text{ req/sec}$).

### Issue #095: Regional Dust Storm Polygon Vector Ingestion & Spatial Intersection Queries
- **Component:** `backend/src/main/java/gov/nasa/ares/science/weather/`
- **Specification:** Ingest vector polygons representing advancing Martian dust storms (from Mars Color Imager - MARCI). Run spatial intersection queries identifying all rovers, habitats, and planned EVA routes located inside or within a $50\text{ km}$ buffer of the storm front.
- **Acceptance Criteria:** Emits high-priority Kafka alerts to affected clients within $100\text{ ms}$ of storm polygon ingestion.

### Issue #096: Spatial Clustering of Micro-Seismic InSight Events via DBSCAN
- **Component:** `backend/src/main/java/gov/nasa/ares/science/seismic/`
- **Specification:** Implement a PostGIS DBSCAN spatial clustering query (`ST_ClusterDBSCAN`) grouping hundreds of low-magnitude marsquakes to discover previously unmapped active tectonic fault grabens.
- **Acceptance Criteria:** Accurately isolates Cerberus Fossae fault swarm as a single dense spatial cluster with noise filtering.

### Issue #097: Reactive Spatial Queries via R2DBC & Spring Data Reactive Repositories
- **Component:** `backend/src/main/java/gov/nasa/ares/simulation/reactive/`
- **Specification:** Migrate traditional blocking JDBC repositories to non-blocking R2DBC spatial repositories to handle thousands of concurrent WebSocket client telemetry subscriptions without thread exhaustion.
- **Acceptance Criteria:** Sustains 10,000 concurrent active client streams with $< 500\text{ MB}$ JVM heap allocation.

### Issue #098: Automated Spatial Partitioning by Martian Quadrangle (MC-01 to MC-30)
- **Component:** `backend/src/main/resources/db/partitioning.sql`
- **Specification:** Mars is cartographically divided into 30 USGS Quadrangles (e.g., MC-11 Oxia Palus, MC-14 Chryse, MC-18 Coprates). Implement PostgreSQL native table partitioning based on polygon bounding coordinates of each quadrangle.
- **Acceptance Criteria:** Query planner executes partition pruning, reading only relevant quadrangle partition tables during localized map bounds queries.

### Issue #099: Historical Telemetry TimescaleDB Hypertables for Long-Term Sol Archival
- **Component:** `backend/src/main/java/gov/nasa/ares/telemetry/timescale/`
- **Specification:** Store millions of high-frequency rover sensor ticks ($10\text{ Hz}$ IMU, battery, temperature) by integrating TimescaleDB hypertables with automated chunk compression and data retention policies.
- **Acceptance Criteria:** Achieves $> 90\%$ compression ratio on historic rover sensor telemetry over 1,000 simulated Sols.

### Issue #100: Spatial Geofencing Engine for Astronaut EVA Safety Boundaries
- **Component:** `backend/src/main/java/gov/nasa/ares/simulation/geofence/`
- **Specification:** Construct an in-memory spatial geofencing engine monitoring astronaut live positions against high-risk hazard zones (steep cliffs, radiation hot spots). Trigger immediate WebSocket alarms upon boundary breach.
- **Acceptance Criteria:** Geofence evaluation latency $< 2\text{ ms}$ per telemetry update.

### Issue #101: GeoJSON FeatureCollection Serialization for Spatial API Payloads
- **Component:** `backend/src/main/java/gov/nasa/ares/config/jackson/`
- **Specification:** Configure Jackson JTS module to serialize JTS `Geometry` entities cleanly into standard RFC 7946 GeoJSON format, ensuring seamless consumption by `flutter_map` GeoJSON layer parsers.
- **Acceptance Criteria:** Produces valid GeoJSON FeatureCollection verified against GeoJSON Lint specifications.

### Issue #102: Flyway Database Migration Scripts for Planetary Geodesy Schemas
- **Component:** `backend/src/main/resources/db/migration/`
- **Specification:** Implement incremental Flyway migrations (`V1__init_mars_geodesy.sql`, `V2__add_isru_models.sql`) ensuring deterministic schema creation across development, CI/CD, and production environments.
- **Acceptance Criteria:** Automated clean migration runs in GitHub Actions CI pipeline without manual intervention.

### Issue #103: Voronoi Diagram Polygon Partitioning for Habitat Regional Jurisdiction
- **Component:** `backend/src/main/java/gov/nasa/ares/simulation/voronoi/`
- **Specification:** When multiple ground stations exist across Mars, use PostGIS `ST_VoronoiPolygons` to calculate territorial service zones, determining which base has emergency rescue jurisdiction for any given incident coordinate.
- **Acceptance Criteria:** Re-computes Voronoi regional boundaries in $< 20\text{ ms}$ when a new habitat is commissioned.

### Issue #104: Spatial Buffer Aggregation for Comms Tower Radio Coverage Footprint
- **Component:** `backend/src/main/java/gov/nasa/ares/simulation/comms/`
- **Specification:** Compute the union of circular radio coverage buffers (`ST_Union(ST_Buffer(geom, range))`) across all deployed communication towers to generate a single continuous polygon representing global comms availability.
- **Acceptance Criteria:** Renders combined coverage polygon with holes where canyon walls block propagation.

### Issue #105: Automated PostGIS Vacuum & Spatial Index Re-indexing Cron Task
- **Component:** `backend/src/main/java/gov/nasa/ares/config/scheduled/`
- **Specification:** High-frequency rover position updates cause GiST index bloat. Implement a scheduled Spring task executing `VACUUM ANALYZE` and concurrent index re-building during simulated nighttime hours (low server load).
- **Acceptance Criteria:** Maintains constant index query execution time over 30 days of continuous multi-agent updates.

---

## Domain 8: Real-Time Telemetry Streaming & STOMP / Kafka

### Issue #106: Binary Protobuf Serialization over STOMP WebSockets for Low-Bandwidth Up-links
- **Component:** `backend/src/main/java/gov/nasa/ares/websocket/protobuf/`
- **Specification:** Text JSON over WebSockets consumes excessive bandwidth. Define `.proto` schemas for rover positions, suit vitals, and alert beacons, serializing telemetry into compact binary packets over STOMP byte frames.
- **Acceptance Criteria:** Reduces network payload bandwidth by $78\%$ compared to JSON payloads.

### Issue #107: Apache Kafka Partitioning Strategy by Martian Quadrangle
- **Component:** `backend/src/main/java/gov/nasa/ares/kafka/partitioner/`
- **Specification:** Implement a custom Kafka partitioner hashing telemetry messages by Martian Quadrangle identifier (`MC-01` to `MC-30`), ensuring that all updates for a specific geographic region remain strictly ordered and scalable across consumer pods.
- **Acceptance Criteria:** Demonstrates linear throughput scaling across 30 Kafka topic partitions without message reordering.

### Issue #108: Delay-Tolerant Networking (DTN) Bundle Protocol (RFC 5050) Simulator
- **Component:** `backend/src/main/java/gov/nasa/ares/telemetry/dtn/`
- **Specification:** Interplanetary communication experiences signal delays ($3 - 22\text{ minutes}$) and blackouts during superior solar conjunctions (every 26 months). Build a DTN store-and-forward bundle protocol emulator that queues messages and synchronizes state when line-of-sight resumes.
- **Acceptance Criteria:** Queues up to 100,000 messages during simulated 48-hour solar conjunction, reconciling state with zero message loss upon reconnection.

### Issue #109: Conflict-Free Replicated Data Types (CRDTs) for Multi-Explorer Offline Sync
- **Component:** `frontend/lib/core/sync/crdt/`
- **Specification:** When astronaut field parties explore deep lava tubes with zero connection to the main habitat server, they log sample notes locally. Use State-based CRDTs (LWW-Element-Set) to automatically resolve merge conflicts when reconnecting to Habitat Wi-Fi.
- **Acceptance Criteria:** Resolves concurrent conflicting edits across 5 disconnected explorers without human intervention.

### Issue #110: WebRTC Peer-to-Peer Mesh Data Channels for Close-Proximity Rover Swarms
- **Component:** `frontend/lib/core/p2p/`
- **Specification:** For rovers operating within line-of-sight ($< 2\text{ km}$), bypass the central Spring Boot server entirely. Establish WebRTC DataChannels over local UHF/WiFi mesh to stream low-latency ($< 10\text{ ms}$) collision avoidance vectors.
- **Acceptance Criteria:** P2P connection established and streams position data at $20\text{ Hz}$ with sub-15ms round-trip latency.

### Issue #111: WebSocket Heartbeat Liveness & Adaptive Reconnection Backoff
- **Component:** `frontend/lib/core/network/websocket/`
- **Specification:** Construct a robust WebSocket client wrapper featuring configurable heartbeats ($5\text{ s}$ interval, $10\text{ s}$ timeout) and jittered exponential backoff reconnection algorithms ($1\text{ s}, 2\text{ s}, 4\text{ s}, \dots, 60\text{ s}$).
- **Acceptance Criteria:** Automatically reconnects and restores all topic subscriptions within $1.5\text{ seconds}$ of simulated network restoration.

### Issue #112: Spring WebSocket Channel Interceptor for Astronaut JWT Security Tokens
- **Component:** `backend/src/main/java/gov/nasa/ares/config/security/`
- **Specification:** Build a `ChannelInterceptor` intercepting STOMP `CONNECT` frames to validate astronaut asymmetric RSA JWT tokens, extracting mission role privileges (e.g., Commander, Science Specialist, Autonomous Rover).
- **Acceptance Criteria:** Rejects unauthorized WebSocket connection attempts with STOMP `ERROR` frame and terminates TCP socket.

### Issue #113: Client-Side Dead Reckoning Interpolator for Smooth Remote Rover Motion
- **Component:** `frontend/lib/simulation/interpolation/`
- **Specification:** When receiving server position updates at $2\text{ Hz}$, naive rendering causes jerky vehicle motion. Implement Hermite spline trajectory extrapolation computing intermediate positions and orientations at 60 FPS based on velocity vectors.
- **Acceptance Criteria:** Smooth fluid vehicle movement on client screens with zero visual stutter during network packet jitter.

### Issue #114: Backpressure Handling via Reactive Streams (Project Reactor)
- **Component:** `backend/src/main/java/gov/nasa/ares/websocket/backpressure/`
- **Specification:** If a mobile client experiences high network latency, unbounded WebSocket outbound message queues cause JVM OutOfMemory errors. Apply `onBackpressureDrop` and `onBackpressureLatest` operators to drop intermediate non-critical telemetry frames.
- **Acceptance Criteria:** Maintains stable backend memory usage even when 50 clients are throttled to $10\text{ kbps}$ dialup speeds.

### Issue #115: Distributed Trace Logging with OpenTelemetry for Telemetry Pipelines
- **Component:** `backend/src/main/java/gov/nasa/ares/config/telemetry/`
- **Specification:** Instrument all Kafka message producers, consumers, and WebSocket broadcast handlers with OpenTelemetry traces, exporting trace spans to Jaeger to pinpoint processing latency across the telemetry pipeline.
- **Acceptance Criteria:** Visual trace graph displays end-to-end telemetry pipeline latency from rover ingest to browser screen ($< 45\text{ ms}$).

### Issue #116: Spatial Telemetry Topic Sharding via Dynamic WebSocket Topics
- **Component:** `backend/src/main/java/gov/nasa/ares/websocket/sharding/`
- **Specification:** Broadcasting all planetary telemetry to `/topic/all` overwhelms client devices. Implement dynamic geographic topic subscriptions (e.g., `/topic/quadrant/MC-14/chryse`), allowing clients to receive updates only for their currently visible map viewport.
- **Acceptance Criteria:** Client network traffic reduced by $> 95\%$ when viewing localized crater basins.

### Issue #117: NASA Live InSight SEIS Real-Time Seismic Webhook Ingest Service
- **Component:** `backend/src/main/java/gov/nasa/ares/science/webhook/`
- **Specification:** Construct an event listener querying the NASA JPL InSight SEIS continuous data stream, immediately broadcasting new detected marsquakes to connected mission control clients within seconds of public release.
- **Acceptance Criteria:** Automated notification and map pin drop displayed on client screens within $5\text{ seconds}$ of upstream event publication.

### Issue #118: Redis Pub/Sub Backplane for Multi-Node Spring Boot Horizontal Scaling
- **Component:** `backend/src/main/java/gov/nasa/ares/config/redis/`
- **Specification:** To scale the backend across multiple server instances in Kubernetes, integrate a Redis Pub/Sub message broker backplane that synchronizes WebSocket STOMP messages across clustered nodes.
- **Acceptance Criteria:** Messages broadcast from Server Node A are received by WebSocket clients connected to Server Node B in $< 5\text{ ms}$.

### Issue #119: Compression of High-Rate IMU Sensor Streams using Delta-of-Delta Encoding
- **Component:** `frontend/lib/core/compression/`
- **Specification:** Implement Facebook Gorilla / Delta-of-Delta compression algorithm on numeric timestamped rover sensor streams ($100\text{ Hz}$ accelerometer and gyroscope ticks), compressing floating-point values into compact bitstreams.
- **Acceptance Criteria:** Achieves $> 80\%$ compression ratio on high-rate inertial sensor telemetry.

### Issue #120: Audio Visualizer Packet Streaming for Tactical Tactical Helmet Comms
- **Component:** `frontend/lib/ui/audio/`
- **Specification:** Implement a low-bitrate Opus audio stream player displaying an interactive oscilloscope waveform in the top HUD during simulated astronaut voice comms transmissions between Base and EVA parties.
- **Acceptance Criteria:** Audio waveform visualizer updates at 60 FPS in sync with voice transmission frames.

---

## Domain 9: Astrobiological & Scientific Field Notebook Intelligence

### Issue #121: Automated Hyperspectral Mineral Deconvolution (CRISM / Raman Spectral Unmixing)
- **Component:** `frontend/lib/observation/spectrometry/`
- **Specification:** Implement Non-Negative Matrix Factorization (NMF) spectral unmixing on client-side, comparing observed $532\text{ nm}$ Raman spectrum curves against the RRUFF mineral database to output percentage breakdowns of olivine, pyroxene, and gypsum.
- **Acceptance Criteria:** Correctly decomposes a synthetic mineral mixture into its constituent components with $> 92\%$ accuracy.

### Issue #122: Biosignature Preservation Potential (BPP) Rating Algorithm
- **Component:** `backend/src/main/java/gov/nasa/ares/science/astrobiology/`
- **Specification:** Build an expert scoring algorithm evaluating sample collection sites based on geological facies: fine-grained lacustrine mudstones (Score 10/10), hydrothermal silica deposits (Score 9/10), coarse aeolian sands (Score 2/10), and igneous basalt (Score 4/10).
- **Acceptance Criteria:** Automatically assigns Biosignature Preservation Potential rating to any tapped coordinate on Mars.

### Issue #123: 3D Photogrammetric Drill Core Sample Tube Reconstructor
- **Component:** `frontend/lib/observation/sample_3d/`
- **Specification:** Ingest multi-angle macro imagery of collected drill core samples to generate an interactive 3D textured cylindrical mesh in Flutter, allowing scientists to rotate and inspect sedimentary layering and grain size.
- **Acceptance Criteria:** Smooth interactive 3D rotation of sample tube mesh with adjustable lighting controls.

### Issue #124: Geological Stratum Chronological Correlation across Traverses
- **Component:** `backend/src/main/java/gov/nasa/ares/science/stratigraphy/`
- **Specification:** Implement automated stratigraphic column correlation linking discrete sample points across multiple kilometers using MOLA elevation datum and spectral band matching to reconstruct ancient lakebed depositional histories.
- **Acceptance Criteria:** Generates chronostratigraphic cross-section diagram linking Jezero floor to delta rim.

### Issue #125: Automated Scientific Report Generation to NASA Planetary Data System (PDS4) XML
- **Component:** `backend/src/main/java/gov/nasa/ares/science/pds4/`
- **Specification:** Compile all field notes, coordinates, spectral curves, and sample metadata into strict NASA PDS4-compliant XML archive packages complete with SHA-256 checksums and provenance tracking.
- **Acceptance Criteria:** Output validates successfully against official NASA PDS4 Schematron and XML Schema Definition (XSD).

### Issue #126: SuperCam Laser-Induced Breakdown Spectroscopy (LIBS) Elemental Matrix Estimator
- **Component:** `frontend/lib/observation/libs/`
- **Specification:** Emulate SuperCam LIBS laser plasma emission spectra (atomic emission lines for $Si, Fe, Mg, Ca, Na, K$), displaying calibrated elemental weight percentages ($wt\%$) for targeted rock targets.
- **Acceptance Criteria:** Accurately plots elemental oxide ternary diagrams ($AFM$ and $QAPF$ diagrams) from simulated spectra.

### Issue #127: Delta Fan Sedimentary Facies Micro-Environment Classifier
- **Component:** `frontend/lib/observation/geology/`
- **Specification:** Integrate geological decision trees classifying sedimentary facies (Topset, Fore-set, Bottomset beds, Point Bar deposits) based on grain sorting, cross-bedding angles, and elevation context.
- **Acceptance Criteria:** Automatically suggests target classification during Science Pin logging.

### Issue #128: Organic Molecule Fluorophore Spectral Signature Detector (SHERLOC Emulator)
- **Component:** `frontend/lib/observation/sherloc/`
- **Specification:** Emulate deep-UV ($248.6\text{ nm}$) resonance Raman and fluorescence spectrometry, detecting native aromatic organic molecules (polycyclic aromatic hydrocarbons - PAHs) embedded in sulfate minerals.
- **Acceptance Criteria:** Displays fluorescence emission wavelength peaks ($300 - 350\text{ nm}$) with background noise filtering.

### Issue #129: Radiometric Age Dating Isochron Plotter (K-Ar and Rb-Sr Simulation)
- **Component:** `frontend/lib/observation/geochronology/`
- **Specification:** Implement interactive isochron plotting widgets computing parent/daughter isotope ratios ($^{87}Rb/^{86}Sr$ vs $^{87}Sr/^{86}Sr$), determining calculated geological formation ages in billions of years ($Ga$).
- **Acceptance Criteria:** Calculates slope and age uncertainty ($3.82 \pm 0.05\text{ Ga}$) for simulated Jezero crater floor basalt samples.

### Issue #130: Voice-to-Text Field Observation Audio Transcription Engine
- **Component:** `frontend/lib/ui/notebook/audio/`
- **Specification:** Build an on-device speech-to-text pipeline allowing astronauts to dictate geological observations through helmet microphones, auto-populating field note descriptions with specialized planetary terminology (e.g., "regolith", "vesicular basalt", "laminations").
- **Acceptance Criteria:** High-accuracy transcription of specialized scientific terminology without cloud API dependency.

### Issue #131: Digital Microscope Thin-Section Petrographic Polarizer Simulator
- **Component:** `frontend/lib/observation/petrography/`
- **Specification:** Simulate cross-polarized light (XPL) and plane-polarized light (PPL) optical microscopy on thin-section rock slices, allowing mineralogists to rotate polarization angles to inspect mineral birefringence and extinction.
- **Acceptance Criteria:** Interactive polarizer rotation updates mineral interference colors dynamically at 60 FPS.

### Issue #132: Ancient Riverbed Hydraulic Discharge & Paleoflow Velocity Estimator
- **Component:** `backend/src/main/java/gov/nasa/ares/science/hydrology/`
- **Specification:** Ingest ancient river channel width ($W$), depth ($D$), and MOLA bed slope ($S$) along Ares Vallis to calculate ancient flood discharge via Manning's equation:
  $$Q = \frac{1}{n} A R_h^{2/3} S^{1/2}$$
  estimating ancient water velocity during the Noachian/Hesperian transition.
- **Acceptance Criteria:** Computes catastrophic flood discharge rates consistent with published geomorphological papers ($> 10^7\text{ m}^3\text{/s}$).

### Issue #133: Sub-Surface Core Integrity & Brittleness Index Estimator
- **Component:** `backend/src/main/java/gov/nasa/ares/science/drilling/`
- **Specification:** Model drill bit torque, RPM, and weight-on-bit (WOB) resistance curves to calculate Rock Quality Designation (RQD) and fracture frequency within sample core tubes before extraction.
- **Acceptance Criteria:** Warns drill operator if core sample is at high risk of pulverization or jamming inside sample sleeve.

### Issue #134: Spatial Density Heatmap of Collected Martian Samples by Geological Era
- **Component:** `frontend/lib/map/layers/samples/`
- **Specification:** Render an interactive Gaussian kernel density heatmap across Mars displaying the distribution of collected samples categorized by epoch: Noachian ($> 3.7\text{ Ga}$), Hesperian ($3.7 - 3.0\text{ Ga}$), and Amazonian ($< 3.0\text{ Ga}$).
- **Acceptance Criteria:** Interactive filter slider isolating samples from specific planetary geological epochs.

### Issue #135: Automated Sample Return Cannister Packing & Mass Optimization
- **Component:** `backend/src/main/java/gov/nasa/ares/science/logistics/`
- **Specification:** The Mars Sample Return (MSR) capture containment cannister has strict weight ($< 15\text{ kg}$) and volume ($30\text{ tubes}$) constraints. Implement a knapsack optimization algorithm selecting the highest-scoring scientific portfolio for Earth return.
- **Acceptance Criteria:** Computes optimal sample manifest maximizing scientific diversity and mineralogical representation.

---

## Domain 10: Astronaut Tactical Safety HUD & PLSS Telemetry

### Issue #136: Primary Life Support System (PLSS) Consumable Depletion Forecaster
- **Component:** `frontend/lib/core/telemetry/plss/`
- **Specification:** Build a predictive metabolic consumption engine tracking oxygen pressure drop ($\Delta p_{O2}/\Delta t$), battery drain (Watts), and sublimator water cooling feed rate as a function of astronaut heart rate and uphill physical exertion:
  $$\text{Oxygen Depletion Rate} = \dot{V}_{O2,base} \cdot \left(1 + \frac{\text{HR} - 70}{100}\right) \cdot (1 + \sin\theta)$$
- **Acceptance Criteria:** Predicts exact minute of consumable exhaustion within $\pm 3\text{ minutes}$ accuracy.

### Issue #137: Galactic Cosmic Radiation (GCR) & Solar Particle Event (SPE) Dosimeter Matrix
- **Component:** `frontend/lib/ui/hud/radiation/`
- **Specification:** Ingest Mars Science Laboratory RAD instrument telemetry to calculate cumulative equivalent radiation dosage in Sieverts ($mSv$). Display visual color-coded alert badges (Nominal, Elevated, Critical Solar Particle Event).
- **Acceptance Criteria:** Triggers audible alarm and plots emergency shelter route if dose rate exceeds $1.5\text{ mSv/hour}$.

### Issue #138: Autonomous Rescue Rover Dispatch & Rendezvous Intercept Vector Solver
- **Component:** `backend/src/main/java/gov/nasa/ares/simulation/rescue/`
- **Specification:** When an incapacitated astronaut triggers RED ALERT SOS, calculate the fastest time-to-intercept rendezvous trajectory for autonomous Rescue Rover Unit-01, accounting for rover maximum speed ($12\text{ km/h}$) and intervening obstacle topography.
- **Acceptance Criteria:** Publishes calculated rescue vehicle trajectory and ETA countdown to all HUDs in $< 100\text{ ms}$.

### Issue #139: Suit Depressurization Emergency Barometric Decay Predictor
- **Component:** `frontend/lib/core/telemetry/suit/`
- **Specification:** Model rapid suit cabin pressure decay through punctures of varying diameter ($1\text{ mm} - 5\text{ mm}$) into Mars ambient vacuum ($0.6\text{ kPa}$). Calculate Time of Useful Consciousness (TUC) and trigger automated emergency valve seals.
- **Acceptance Criteria:** Displays real-time countdown timer to Armstrong Limit depressurization ($p < 6.3\text{ kPa}$).

### Issue #140: Real-Time Electrocardiogram (ECG) Waveform Synthesis with Dynamic Arrhythmia
- **Component:** `frontend/lib/ui/hud/biometrics/`
- **Specification:** Render an interactive canvas ECG line chart plotting realistic P-QRS-T wave complexes dynamically driven by live heart rate telemetry, simulating premature ventricular contractions (PVCs) during high physical stress.
- **Acceptance Criteria:** Smooth 60 FPS heartbeat animation with zero garbage collector frame drops.

### Issue #141: Emergency Topographic Natural Radiation Shelter Line-of-Sight Calculation
- **Component:** `backend/src/main/java/gov/nasa/ares/simulation/shelter/`
- **Specification:** During unpredicted Solar Particle Events (SPEs), astronauts must seek immediate terrain shielding (shadow of cliff walls, overhanging alcoves, caves). Identify nearest $2\pi$ steradian rock shielding sites within 15-minute walking radius.
- **Acceptance Criteria:** Immediately displays nearest natural radiation shelter coordinates with fastest descent path.

### Issue #142: Core Body Temperature & Hypothermia/Hyperthermia Thermal Model
- **Component:** `frontend/lib/core/telemetry/thermal/`
- **Specification:** Model metabolic heat generation, suit Liquid Cooling and Ventilation Garment (LCVG) coolant loop heat exchange, and ambient environmental convective loss to track astronaut core body temperature ($T_{core}$).
- **Acceptance Criteria:** Warns of incipient heat exhaustion if core temperature exceeds $38.5^\circ\text{C}$ during intense manual drilling.

### Issue #143: Suit Carbon Dioxide Scrubbing Breakthrough & Hypercapnia Warning System
- **Component:** `frontend/lib/core/telemetry/co2/`
- **Specification:** Model lithium hydroxide (LiOH) or Metal Oxide (MetOx) canister $CO_2$ absorption saturation. Calculate ambient suit partial pressure $p_{CO2}$ and trigger hypercapnia warnings if concentration exceeds $0.5\text{ kPa}$ ($3.8\text{ mmHg}$).
- **Acceptance Criteria:** Displays clear physiological warning: "Elevated $CO_2$ - Slow Exertion Pace".

### Issue #144: Tactical Voice Audio Comm Channel Multiplexer with Distance Attenuation
- **Component:** `frontend/lib/core/audio/mesh/`
- **Specification:** Build a multi-channel spatial audio multiplexer (Direct EVA UHF, Habitat Operations, Mission Control relay), applying distance-based signal-to-noise ratio (SNR) degradation and radio static effects.
- **Acceptance Criteria:** Audio volume and radio static scale realistically as distance between astronaut and base station increases.

### Issue #145: Heads-Up Display (HUD) Night/Dust Storm High-Contrast Visor Theme
- **Component:** `frontend/lib/ui/theme/`
- **Specification:** During intense daytime dust storms or nighttime operations, standard UI becomes unreadable. Implement an automated high-contrast monochrome neon HUD mode (amber `#FF9100` on black `#000000`) compliant with NASA MIL-STD-1472H human factors engineering.
- **Acceptance Criteria:** Seamless visual theme switch triggered automatically by ambient light sensor or user toggle.

### Issue #146: Astronaut Spatial Disorientation & Spatial Inversion Compass Recovery
- **Component:** `frontend/lib/ui/navigation/compass/`
- **Specification:** In featureless dune plains (Olympia Undae) during dust storms, astronauts experience severe spatial disorientation. Implement a dominant, uncluttered "Homing Vector Arrow" pointing unwaveringly toward Habitat Alpha airlock entrance.
- **Acceptance Criteria:** Homing arrow remains pinned to habitat portal vector regardless of erratic helmet look angles.

### Issue #147: Multi-Astronaut Biometric Squad Telemetry Matrix Drawer
- **Component:** `frontend/lib/ui/hud/squad/`
- **Specification:** Build a sliding squad status drawer displaying simultaneous telemetry for up to 4 EVA crew members (Commander, Science Specialist, Flight Engineer, Medical Officer) with instant triage status flags.
- **Acceptance Criteria:** Real-time multi-agent biometric cards update concurrently over WebSocket broadcast channel.

### Issue #148: Helmet Visor Condensation & Anti-Fog Sub-Surface Heater Control
- **Component:** `frontend/lib/simulation/suit/`
- **Specification:** Model visor interior dew point temperature as a function of suit humidity and ambient exterior cold. Compute heating power requirements for conductive visor heating elements to eliminate fogging.
- **Acceptance Criteria:** Simulates visual fogging effect if visor heater power is deactivated in cold environments ($T < -60^\circ\text{C}$).

### Issue #149: Biometric Fatigue Index Estimator via Continuous Exertion Integration
- **Component:** `frontend/lib/core/telemetry/fatigue/`
- **Specification:** Calculate a cumulative fatigue index ($0 - 100\%$) based on total distance traversed, elevation climbed, Sol work duration, and sleep history, alerting mission commanders when astronaut cognitive error rates rise.
- **Acceptance Criteria:** Recommends mandatory 15-minute rest stop when fatigue index exceeds $75\%$.

### Issue #150: Black-Box Telemetry Flight Recorder with Cryptographic Tamper-Proof Audit Log
- **Component:** `backend/src/main/java/gov/nasa/ares/telemetry/blackbox/`
- **Specification:** Construct an immutable append-only local and server-side flight recorder logging every navigation step, biometric alert, valve actuation, and user input into a cryptographically signed SHA-256 Merkle tree log.
- **Acceptance Criteria:** Cryptographic audit trail verifies exact sequence of events leading up to simulated emergency SOS triggers.

---

<div align="center">
  <b>ARES Nav Open-Source Engineering Board</b><br/>
  <i>Submit Pull Requests referencing specific Issue numbers to contribute.</i>
</div>
