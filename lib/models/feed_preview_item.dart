import '../data/home_feed_dummy.dart';
import 'feed_item.dart';
import 'piece_summary.dart';

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

/// Local dummy Piece/Scene shown in the For You feed when API data is unavailable.
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
    this.priceCents,
    this.shippingRegion,
    this.framingNote,
    this.provenanceNote,
    this.heroImageUrl,
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
  final int? priceCents;
  final String? shippingRegion;
  final String? framingNote;
  final String? provenanceNote;
  final String? heroImageUrl;

  int get imageCount => imageSeeds.length;

  HomeFeedArtist get artist =>
      kHomeFeedArtists[artistIndex % kHomeFeedArtists.length];

  double get aspectRatioValue =>
      aspectRatio == FeedAspectRatio.portrait3x4 ? 3 / 4 : 16 / 9;

  String? get priceDisplay {
    if (priceCents == null) return null;
    return '\$${(priceCents! / 100).toStringAsFixed(0)}';
  }

  bool get isScene => medium == 'Scene' || medium == 'Video';

  bool get isPiece => !isScene;

  /// Builds a preview-shaped item from an API [PieceSummary] for collect detail.
  factory FeedPreviewItem.fromPieceSummary(PieceSummary piece) {
    final artistIndex = piece.id.hashCode.abs() % kHomeFeedArtists.length;
    final username = piece.authorUsername ?? 'artist';
    return FeedPreviewItem(
      id: piece.id,
      imageSeeds: [piece.id.hashCode.abs()],
      artistIndex: artistIndex,
      title: piece.title,
      medium: piece.medium ?? 'Mixed media',
      year: DateTime.now().year,
      dimensions: piece.dimensions ?? '',
      story: piece.caption ?? '',
      handle: username.startsWith('@') ? username : '@$username',
      isAvailable: piece.isForSale,
      aspectRatio: aspectRatioFromDimensions(piece.dimensions),
      priceCents: piece.priceCents,
      shippingRegion: piece.shippingRegion,
      heroImageUrl: piece.mediaUrl,
    );
  }

  /// Builds a preview item from an explore/home API [FeedItem].
  factory FeedPreviewItem.fromFeedItem(FeedItem item) {
    if (item.type == FeedItemType.piece && item.piece != null) {
      return FeedPreviewItem.fromPieceSummary(item.piece!);
    }

    final post = item.post!;
    final artistIndex = post.id.hashCode.abs() % kHomeFeedArtists.length;
    final username = post.authorUsername ?? 'artist';
    final isVideo = item.isVideo;
    return FeedPreviewItem(
      id: post.id,
      imageSeeds: [post.id.hashCode.abs()],
      artistIndex: artistIndex,
      title: post.caption ?? 'Scene',
      medium: isVideo ? 'Video' : 'Scene',
      year: DateTime.now().year,
      dimensions: '',
      story: post.caption ?? '',
      handle: username.startsWith('@') ? username : '@$username',
      isAvailable: false,
      aspectRatio: isVideo
          ? FeedAspectRatio.landscape16x9
          : FeedAspectRatio.portrait3x4,
      heroImageUrl: post.mediaUrl,
    );
  }
}

FeedAspectRatio aspectRatioFromDimensions(String? dimensions) {
  if (dimensions == null || dimensions.isEmpty) {
    return FeedAspectRatio.portrait3x4;
  }
  final match = RegExp(r'(\d+(?:\.\d+)?)\s*[x×]\s*(\d+(?:\.\d+)?)')
      .firstMatch(dimensions);
  if (match == null) return FeedAspectRatio.portrait3x4;
  final w = double.tryParse(match.group(1)!);
  final h = double.tryParse(match.group(2)!);
  if (w == null || h == null || h == 0) return FeedAspectRatio.portrait3x4;
  return w / h > 1.2
      ? FeedAspectRatio.landscape16x9
      : FeedAspectRatio.portrait3x4;
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
