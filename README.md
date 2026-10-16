# ARES-Nav\n\n# ARES Nav — Astronaut Real-Time Exploration & Safety System
**"Google Maps for Mars" — Tactical Surface Navigation HUD for Rover & Helmet Visors**

A complete, production-grade Flutter UI prototype centered around the **Jezero Crater** landing site ($18.38^\circ\text{ N}, 77.58^\circ\text{ E}$, Mars 2020 *Perseverance* exploration sector).

---

## 🚀 Key Architectural Features

### 1. Interactive Martian Topography & Tactical Canvas
- **Procedural Jezero Crater Surface**: Renders the ancient western river fan delta, Neretva Vallis breach channel, Belva impact crater, and MOLA topographic contour bands.
- **Dynamic Layer Toggles**:
  - `Slope Contours`: Contour gradient overlays highlighting steep terrain ($>25^\circ$).
  - `Hazards & Rad`: Translucent heat polygons representing unstable scree, regolith sinkholes, and cosmic radiation hotspots.
  - `Ice & Minerals`: Subsurface permafrost water ice deposits (cyan) and phyllosilicate/carbonate beds (violet).
  - `Storm Vectors`: Real-time animated vector arrows simulating oncoming $18\text{ km/h ENE}$ dust storm perimeter.
- **Astronaut Beacon**: Pulsing multi-ring radar beacon with directional look visor and callsign (`EVA-1 // CDR. VANCE`).
- **Base & Vehicle POIs**: Habitat Alpha (RTK base station) and Rover Unit-01 (*Chariot* class).

### 2. Google Maps-Style Floating Control Deck
- **Top HUD Search Pill**: Displays current target (*Belva Crater Delta - Section 4B*), distance ($2.4\text{ km}$), walk ETA ($38\text{ min}$), and datum elevation ($-2,584\text{ m}$). Tapping opens a quick destination selector.
- **Layer Selector Deck**: Floating glassmorphic pill buttons to toggle geological and environmental overlays.
- **Quick Action Bar**: Center on Astronaut GPS, Recenter on Habitat Alpha, Toggle 2D/3D tilt perspective, and MOLA coordinate grid overlay.

### 3. Multi-Stage Sliding Mission Drawer (`DraggableScrollableSheet`)
- **Collapsed View ($12\%$)**: Next turn instruction (*"Turn 15° NE past boulder ridge in 120m"*), ETA, and dual real-time progress gauges for primary $\text{O}_2$ tank ($82\%$) and suit battery ($76\%$).
- **Intermediate View ($38\%$)**:
  - **Cross-Section Elevation & Slope Chart**: Custom canvas chart plotting distance ($0.0\text{ to }2.4\text{ km}$) against elevation ($-2,540\text{ to }-2,584\text{ m}$), with slope warning flags ($14.2^\circ$).
- **Expanded View ($82\%$)**:
  - **Live Environmental HUD**: Surface temp ($-62^\circ\text{C}$), ambient pressure ($0.636\text{ kPa}$), wind speed ($18\text{ km/h}$), and solar/UV flux ($8.4\text{ W/m}^2$).
  - **Tactical Route Options**: Toggle between *Fastest Path* (direct scree traverse) and *Shielded Path* (crater rim shadow for low radiation exposure).
  - **Digital Field Notebook List**: List of logged science pins and sample collection targets.

### 4. Digital Field Notebook ("Drop Pin & Log" Mode)
- **Long-Press Coordinate Drop**: Long-pressing anywhere on the Martian map calculates the Martian coordinates and opens the specimen logger.
- **Specimen Logging Form**:
  - Specimen Name (e.g. *Silicate-rich mudstone core sample*)
  - Geological Layer & Depth (e.g. *Delta Topset Bed - 0.45m*)
  - Classification chips: *Sedimentary Core*, *Basaltic Igneous*, *Hydrothermal Deposit*, *Subsurface Ice*, *Regolith Matrix*.
  - Simulated **Mastcam-Z Multispectral Viewfinder** with filter switches: Visible (VIS), Near-IR (NIR), Raman (532nm), and Thermal-IR.
  - Commits new pins to the live map with glowing cyan markers.

### 5. Emergency SOS & Evacuation Protocol ("Red Alert")
- **Protected Emergency Button**: Top-right SOS button with confirmation modal.
- **Tactical Red Alert Mode**:
  - Pulsing crimson HUD border and strobe animation.
  - Clears standard exploration waypoints and plots the highest-priority direct escape vector to Habitat Alpha.
  - Displays emergency beacon telemetry: *RTK Frequency 433.8 MHz // Rescue Rover Dispatched (ETA 11 min)*.
  - Biometric telemetry tracking elevated heart rate ($138\text{ BPM}$), suit pressure ($29.6\text{ kPa}$ nominal), and $\text{O}_2$ reserve consumption.

---

## 🛰️ Production Integration Hooks

### NASA Web Map Tile Service (WMTS)
To replace the custom procedural canvas with live orbital imagery from NASA Trek or USGS:
```dart
// Example integration for flutter_map with USGS/NASA Trek tiles:
TileLayer(
  urlTemplate: 'https://trek.nasa.gov/tiles/Mars/EQ/Mars_MGS_MOLA_ClrShade_merge_global_463m/1.0.0//default/default028mm/{z}/{y}/{x}.jpg',
  additionalOptions: const {
    'userAgent': 'AresNavMissionClient/1.0',
  },
  maxZoom: 9,
)
```

### Spring Boot REST & WebSocket Telemetry APIs
- `GET /api/v1/mission/telemetry/eva-1` — Streams astronaut biometrics & suit telemetry.
- `POST /api/v1/science-pins` — Persists specimen core data to PostgreSQL / PostGIS.
- `POST /api/v1/emergency/sos` — Initiates mission control red alert and autonomous rover dispatch.
- `GET /api/v1/weather/jezero-sol` — Connects to the MEDA (Mars Environmental Dynamics Analyzer) feed.

---

## 🛠️ How to Run

```bash
# 1. Fetch dependencies
flutter pub get

# 2. Run on Chrome / macOS / iOS / Android
flutter run
```
