import 'dart:math' as math;

/// 1:1 piece tile size as a fraction of the series square width (same for every series).
const double kSeriesCardSideFraction = 0.58;

/// Max number of piece thumbnails fanned in the series card (performance cap).
const int kSeriesMaxPreviewPieces = 6;

/// Dummy series row. [pieceCount] must match [imageSeeds].length.
/// Only series with [pieceCount] > 1 appear in the Series tab.
class ProfileSeriesData {
  ProfileSeriesData({
    required this.name,
    required this.pieceCount,
    required this.imageSeeds,
  }) : assert(pieceCount == imageSeeds.length),
       assert(pieceCount >= 1);

  final String name;
  final int pieceCount;
  final List<int> imageSeeds;

  /// Seeds shown in the fan (all pieces up to [kSeriesMaxPreviewPieces]).
  List<int> get stackSeeds {
    if (pieceCount <= 1) return const [];
    final cap = math.min(pieceCount, kSeriesMaxPreviewPieces);
    return imageSeeds.take(cap).toList(growable: false);
  }
}
