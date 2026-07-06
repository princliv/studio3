import '../data/home_feed_dummy.dart';

enum FeedAspectRatio { portrait3x4, landscape16x9 }

enum FeedAvailabilityFilter { all, available }

class RelatedScene {
  const RelatedScene({
    required this.imageSeed,
    this.duration,
  });

  final int imageSeed;
  final String? duration;
}

/// Local dummy piece/post shown in the For You feed when API data is unavailable.
class FeedPreviewItem {
  const FeedPreviewItem({
    required this.id,
    required this.imageSeeds,
    required this.artistIndex,
    required this.title,
    required this.medium,
    required this.year,
    required this.dimensions,
    required this.story,
    required this.handle,
    required this.isAvailable,
    required this.aspectRatio,
    this.isProcess = false,
    this.seriesName = '',
    this.seriesThumbs = const [],
    this.relatedScenes = const [],
  });

  final String id;
  final List<int> imageSeeds;
  final int artistIndex;
  final String title;
  final String medium;
  final int year;
  final String dimensions;
  final String story;
  final String handle;
  final bool isAvailable;
  final FeedAspectRatio aspectRatio;
  final bool isProcess;
  final String seriesName;
  final List<int> seriesThumbs;
  final List<RelatedScene> relatedScenes;

  int get imageCount => imageSeeds.length;

  HomeFeedArtist get artist =>
      kHomeFeedArtists[artistIndex % kHomeFeedArtists.length];

  double get aspectRatioValue =>
      aspectRatio == FeedAspectRatio.portrait3x4 ? 3 / 4 : 16 / 9;
}

String feedPreviewImageUrl(FeedPreviewItem item, {int imageIndex = 0}) {
  final seed =
      item.imageSeeds[imageIndex.clamp(0, item.imageSeeds.length - 1)];
  switch (item.aspectRatio) {
    case FeedAspectRatio.portrait3x4:
      return picsumUrl(seed, 390, 520);
    case FeedAspectRatio.landscape16x9:
      return picsumUrl(seed, 390, 220);
  }
}
