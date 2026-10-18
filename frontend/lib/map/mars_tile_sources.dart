enum MarsTileLayerType {
  molaElevation,
  vikingVisible,
  hiriseJezero,
  tesMineralogy,
}

class MarsTileSource {
  final MarsTileLayerType type;
  final String title;
  final String description;
  final String urlTemplate;
  final int minZoom;
  final int maxZoom;
  final String attribution;
  final String badgeText;

  const MarsTileSource({
    required this.type,
    required this.title,
    required this.description,
    required this.urlTemplate,
    required this.minZoom,
    required this.maxZoom,
    required this.attribution,
    required this.badgeText,
  });

  /// NASA JPL / USGS Planetary Data System (PDS) Web Map Tile Service (WMTS) URLs
  static const MarsTileSource molaColorElevation = MarsTileSource(
    type: MarsTileLayerType.molaElevation,
    title: 'MOLA Elevation (Color Shaded)',
    description: 'Mars Global Surveyor MOLA 463m elevation topography color ramp',
    urlTemplate: 'https://trek.nasa.gov/tiles/Mars/EQ/Mars_MGS_MOLA_ClrShade_merge_global_463m/1.0.0//default/default028mm/{z}/{y}/{x}.jpg',
    minZoom: 1,
    maxZoom: 9,
    attribution: 'NASA/JPL/GSFC/USGS',
    badgeText: 'MOLA 463m',
  );

  static const MarsTileSource vikingVisibleMosaic = MarsTileSource(
    type: MarsTileLayerType.vikingVisible,
    title: 'Viking MDIM 2.1 (True Color)',
    description: 'Viking Orbiter Mars Digital Image Model (MDIM 2.1) global mosaic',
    urlTemplate: 'https://trek.nasa.gov/tiles/Mars/EQ/Mars_Viking_MDIM21_ClrMosaic_global_232m/1.0.0//default/default028mm/{z}/{y}/{x}.jpg',
    minZoom: 1,
    maxZoom: 9,
    attribution: 'NASA/USGS Astrogeology',
    badgeText: 'VIS 232m',
  );

  static const MarsTileSource hiriseJezeroDelta = MarsTileSource(
    type: MarsTileLayerType.hiriseJezero,
    title: 'HiRISE Jezero Crater Mosaic',
    description: 'High Resolution Imaging Science Experiment (HiRISE) 25cm/pixel Jezero delta fan',
    urlTemplate: 'https://trek.nasa.gov/tiles/Mars/EQ/Jezero_HiRISE_Mosaic/1.0.0//default/default028mm/{z}/{y}/{x}.jpg',
    minZoom: 4,
    maxZoom: 14,
    attribution: 'NASA/JPL/University of Arizona',
    badgeText: 'HiRISE 25cm',
  );

  static const List<MarsTileSource> allSources = [
    molaColorElevation,
    vikingVisibleMosaic,
    hiriseJezeroDelta,
  ];
}
