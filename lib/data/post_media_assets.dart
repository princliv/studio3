/// Gallery thumbnails for the posting flow media picker.
abstract final class PostMediaAssets {
  static const closeIcon = 'assets/post/close_icon.svg';
  static const chevronDown = 'assets/post/chevron_down.svg';
  static const filterButton = 'assets/post/filter_button.svg';

  static const cropRotate = 'assets/post/crop/rotate.svg';
  static const cropPerspectiveV = 'assets/post/crop/perspective_v.svg';
  static const cropPerspectiveH = 'assets/post/crop/perspective_h.svg';
  static const cropRotationDial = 'assets/post/crop/rotation_dial.svg';

  static const adjustBrightness = 'assets/post/adjust/brightness.svg';
  static const adjustContrast = 'assets/post/adjust/contrast.svg';
  static const adjustExposure = 'assets/post/adjust/exposure.svg';

  static const createCloseIcon = 'assets/post/create/close_icon.svg';
  static const createPencilIcon = 'assets/post/create/pencil_icon.svg';
  static const createChevronRight = 'assets/post/create/chevron_right.svg';
  static const createLocationIcon = 'assets/post/create/location_icon.svg';
  static const createMediumIcon = 'assets/post/create/medium_icon.svg';
  static const createStyleIcon = 'assets/post/create/style_icon.svg';
  static const createMaterialsIcon = 'assets/post/create/materials_icon.svg';
  static const createSeriesIcon = 'assets/post/create/series_icon.svg';
  static const createScenesIcon = 'assets/post/create/scenes_icon.svg';
  static const createAiToolsIcon = 'assets/post/create/ai_tools_icon.svg';
  static const createSearchIcon = 'assets/post/create/search_icon.svg';

  static const pieceGridThumbs = <String>[
    'assets/post/grid/grid_00.png',
    'assets/post/grid/grid_01.png',
    'assets/post/grid/grid_02.png',
    'assets/post/grid/grid_03.png',
    'assets/post/grid/grid_04.png',
    'assets/post/grid/grid_05.png',
    'assets/post/grid/grid_06.png',
    'assets/post/grid/grid_07.png',
    'assets/post/grid/grid_08.png',
    'assets/post/grid/grid_09.png',
    'assets/post/grid/grid_10.png',
    'assets/post/grid/grid_11.png',
    'assets/post/grid/grid_12.png',
    'assets/post/grid/grid_13.png',
    'assets/post/grid/grid_14.png',
    'assets/post/grid/grid_15.png',
    'assets/post/grid/grid_16.png',
    'assets/post/grid/grid_17.png',
    'assets/post/grid/grid_18.png',
  ];

  static const sceneGridThumbs = <String>[
    'assets/post/scene_grid/grid_00.png',
    'assets/post/scene_grid/grid_01.png',
    'assets/post/scene_grid/grid_02.png',
    'assets/post/scene_grid/grid_03.png',
    'assets/post/scene_grid/grid_04.png',
    'assets/post/scene_grid/grid_05.png',
    'assets/post/scene_grid/grid_06.png',
    'assets/post/scene_grid/grid_07.png',
    'assets/post/scene_grid/grid_08.png',
    'assets/post/scene_grid/grid_09.png',
    'assets/post/scene_grid/grid_10.png',
    'assets/post/scene_grid/grid_11.png',
    'assets/post/scene_grid/grid_12.png',
    'assets/post/scene_grid/grid_13.png',
    'assets/post/scene_grid/grid_14.png',
    'assets/post/scene_grid/grid_15.png',
    'assets/post/scene_grid/grid_16.png',
    'assets/post/scene_grid/grid_17.png',
    'assets/post/scene_grid/grid_18.png',
  ];

  /// Piece flow — 7 rows × 3 columns, uniform 128px rows (Figma 1609:1975).
  static const pieceGridRows = <PostMediaGridRow>[
    PostMediaGridRow(height: 128, thumbIndices: [0, 2, 3]),
    PostMediaGridRow(height: 128, thumbIndices: [4, 5, 6]),
    PostMediaGridRow(height: 128, thumbIndices: [7, 8, 9]),
    PostMediaGridRow(height: 128, thumbIndices: [10, 11, 12]),
    PostMediaGridRow(height: 128, thumbIndices: [13, 14, 15]),
    PostMediaGridRow(height: 128, thumbIndices: [16, 17, 18]),
    PostMediaGridRow(height: 128, thumbIndices: [16, 17, 18]),
  ];

  /// Scene flow — first 3 rows are 227px, remaining 128px (Figma 1953:1164).
  static const sceneGridRows = <PostMediaGridRow>[
    PostMediaGridRow(height: 227, thumbIndices: [0, 2, 3]),
    PostMediaGridRow(height: 227, thumbIndices: [4, 5, 6]),
    PostMediaGridRow(height: 227, thumbIndices: [7, 8, 9]),
    PostMediaGridRow(height: 128, thumbIndices: [10, 11, 12]),
    PostMediaGridRow(height: 128, thumbIndices: [13, 14, 15]),
    PostMediaGridRow(height: 128, thumbIndices: [16, 17, 18]),
    PostMediaGridRow(height: 128, thumbIndices: [16, 17, 18]),
  ];

  static List<PostMediaGridRow> rowsFor(String postType) =>
      postType == 'scene' ? sceneGridRows : pieceGridRows;

  static List<String> thumbsFor(String postType) =>
      postType == 'scene' ? sceneGridThumbs : pieceGridThumbs;

  /// Resolves a grid cell index to its asset path for [postType].
  static String assetPathForCell({
    required String postType,
    required int cellIndex,
  }) {
    final rows = rowsFor(postType);
    final thumbs = thumbsFor(postType);
    final rowIndex = cellIndex ~/ 3;
    final colIndex = cellIndex % 3;
    if (rowIndex >= rows.length || colIndex >= rows[rowIndex].thumbIndices.length) {
      return thumbs.first;
    }
    return thumbs[rows[rowIndex].thumbIndices[colIndex]];
  }

  static List<String> assetPathsForCells({
    required String postType,
    required List<int> cellIndices,
  }) =>
      cellIndices
          .map(
            (index) => assetPathForCell(postType: postType, cellIndex: index),
          )
          .toList(growable: false);
}

class PostMediaGridRow {
  const PostMediaGridRow({
    required this.height,
    required this.thumbIndices,
  });

  final double height;
  final List<int> thumbIndices;
}
