import '../data/home_feed_dummy.dart';

enum FeedLayoutKind { a, b, c, d, e }

/// One tappable card’s data in the feed.
class FeedCardData {
  FeedCardData({
    required this.imageSeeds,
    required this.artistIndex,
    required this.mediumIndex,
  }) : assert(imageSeeds.isNotEmpty);

  /// One Picsum seed per photo in the post (order matches carousel pages).
  final List<int> imageSeeds;
  final int artistIndex;
  final int mediumIndex;

  int get imageCount => imageSeeds.length;

  HomeFeedArtist get artist => kHomeFeedArtists[artistIndex % kHomeFeedArtists.length];

  String get medium => kHomeFeedMediums[mediumIndex % kHomeFeedMediums.length];
}

String feedCardImageUrl(FeedCardData data, FeedLayoutKind layoutKind, {int imageIndex = 0}) {
  final seed = data.imageSeeds[imageIndex.clamp(0, data.imageSeeds.length - 1)];
  switch (layoutKind) {
    case FeedLayoutKind.a:
    case FeedLayoutKind.d:
      return picsumUrl(seed, 400, 500);
    case FeedLayoutKind.e:
      return picsumUrl(seed, 400, 250);
    case FeedLayoutKind.b:
      return picsumUrl(seed, 400, 422);
    case FeedLayoutKind.c:
      return picsumUrl(seed, 240, 240);
  }
}

/// One row in the mixed feed (layout A–E).
class FeedRowModel {
  const FeedRowModel({required this.kind, required this.cards});

  final FeedLayoutKind kind;
  final List<FeedCardData> cards;
}
