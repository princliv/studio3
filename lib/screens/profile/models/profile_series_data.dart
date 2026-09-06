import 'dart:math' as math;

import '../../../models/series_summary.dart';

/// 1:1 piece tile size as a fraction of the series square width (same for every series).
const double kSeriesCardSideFraction = 0.58;

/// Max number of piece thumbnails fanned in the series card (performance cap).
const int kSeriesMaxPreviewPieces = 6;

/// Series row for the profile Series tab.
/// Only series with [pieceCount] > 1 appear in the Series tab.
class ProfileSeriesData {
  ProfileSeriesData({
    this.id,
    required this.name,
    required this.pieceCount,
    List<int>? imageSeeds,
    List<String>? previewUrls,
  }) : imageSeeds = imageSeeds ?? const [],
       previewUrls = previewUrls ?? const [];

  final String? id;
  final String name;
  final int pieceCount;
  final List<int> imageSeeds;
  final List<String> previewUrls;

  factory ProfileSeriesData.fromSeries(SeriesSummary series) {
    final urls = series.previewPieces
        .map((piece) => piece.mediaUrl)
        .whereType<String>()
        .where((url) => url.isNotEmpty)
        .toList(growable: false);
    final seeds = series.previewPieces
        .map((piece) => piece.id.hashCode.abs())
        .toList(growable: false);
    return ProfileSeriesData(
      id: series.id,
      name: series.name,
      pieceCount: series.pieceCount,
      imageSeeds: seeds,
      previewUrls: urls,
    );
  }

  /// Preview image URLs shown in the fan (API first, then dummy seeds).
  List<String> get stackUrls {
    if (pieceCount <= 1) return const [];
    final cap = math.min(pieceCount, kSeriesMaxPreviewPieces);
    if (previewUrls.isNotEmpty) {
      return previewUrls.take(cap).toList(growable: false);
    }
    return const [];
  }

  /// Seeds shown in the fan when API URLs are unavailable.
  List<int> get stackSeeds {
    if (pieceCount <= 1) return const [];
    final cap = math.min(pieceCount, kSeriesMaxPreviewPieces);
    return imageSeeds.take(cap).toList(growable: false);
  }
}
