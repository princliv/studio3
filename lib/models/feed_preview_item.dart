import '../data/home_feed_dummy.dart';
import 'feed_item.dart';
import 'piece_summary.dart';
import 'post_summary.dart';
import 'series_summary.dart';

enum FeedAspectRatio { portrait3x4, landscape16x9 }

enum FeedAvailabilityFilter { all, available }

class RelatedScene {
  const RelatedScene({
    this.id,
    this.imageSeed = 0,
    this.mediaUrl,
    this.mediaType,
    this.duration,
  });

  final String? id;
  final int imageSeed;
  final String? mediaUrl;
  final String? mediaType;
  final String? duration;

  bool get isVideo {
    final t = mediaType?.toLowerCase();
    return t == 'video' || t == 'reel' || t == 'reels';
  }

  factory RelatedScene.fromPost(PostSummary post) {
    return RelatedScene(
      id: post.id,
      imageSeed: post.id.hashCode.abs(),
      mediaUrl: post.mediaUrl,
      mediaType: post.mediaType,
    );
  }
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
    this.seriesThumbUrls = const [],
    this.relatedScenes = const [],
    this.priceCents,
    this.shippingRegion,
    this.framingNote,
    this.provenanceNote,
    this.heroImageUrl,
    this.isLiked = false,
    this.isSaved = false,
    this.likeCount = 0,
    this.commentCount = 0,
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
  final List<String> seriesThumbUrls;
  final List<RelatedScene> relatedScenes;
  final int? priceCents;
  final String? shippingRegion;
  final String? framingNote;
  final String? provenanceNote;
  final String? heroImageUrl;
  final bool isLiked;
  final bool isSaved;
  final int likeCount;
  final int commentCount;

  int get imageCount => imageSeeds.length;

  bool get isApiBacked => !id.contains('dummy');

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

  FeedPreviewItem copyWith({
    String? id,
    List<int>? imageSeeds,
    int? artistIndex,
    String? title,
    String? medium,
    int? year,
    String? dimensions,
    String? story,
    String? handle,
    bool? isAvailable,
    FeedAspectRatio? aspectRatio,
    bool? isProcess,
    String? seriesName,
    List<int>? seriesThumbs,
    List<String>? seriesThumbUrls,
    List<RelatedScene>? relatedScenes,
    int? priceCents,
    String? shippingRegion,
    String? framingNote,
    String? provenanceNote,
    String? heroImageUrl,
    bool? isLiked,
    bool? isSaved,
    int? likeCount,
    int? commentCount,
  }) {
    return FeedPreviewItem(
      id: id ?? this.id,
      imageSeeds: imageSeeds ?? this.imageSeeds,
      artistIndex: artistIndex ?? this.artistIndex,
      title: title ?? this.title,
      medium: medium ?? this.medium,
      year: year ?? this.year,
      dimensions: dimensions ?? this.dimensions,
      story: story ?? this.story,
      handle: handle ?? this.handle,
      isAvailable: isAvailable ?? this.isAvailable,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      isProcess: isProcess ?? this.isProcess,
      seriesName: seriesName ?? this.seriesName,
      seriesThumbs: seriesThumbs ?? this.seriesThumbs,
      seriesThumbUrls: seriesThumbUrls ?? this.seriesThumbUrls,
      relatedScenes: relatedScenes ?? this.relatedScenes,
      priceCents: priceCents ?? this.priceCents,
      shippingRegion: shippingRegion ?? this.shippingRegion,
      framingNote: framingNote ?? this.framingNote,
      provenanceNote: provenanceNote ?? this.provenanceNote,
      heroImageUrl: heroImageUrl ?? this.heroImageUrl,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
    );
  }

  /// Builds a preview-shaped item from an API [PieceSummary] for collect detail.
  factory FeedPreviewItem.fromPieceSummary(PieceSummary piece) {
    final artistIndex = piece.id.hashCode.abs() % kHomeFeedArtists.length;
    final username = piece.authorUsername ?? 'artist';
    final series = piece.series;
    final seriesThumbs = series?.previewPieces
            .map((preview) => preview.id.hashCode.abs())
            .toList(growable: false) ??
        const <int>[];
    final seriesThumbUrls = series?.previewPieces
            .map((preview) => preview.mediaUrl)
            .whereType<String>()
            .where((url) => url.isNotEmpty)
            .toList(growable: false) ??
        const <String>[];
    return FeedPreviewItem(
      id: piece.id,
      imageSeeds: [piece.id.hashCode.abs()],
      artistIndex: artistIndex,
      title: piece.title,
      medium: piece.medium ?? 'Mixed media',
      year: piece.yearCreated ?? DateTime.now().year,
      dimensions: piece.dimensions ?? '',
      story: piece.caption ?? '',
      handle: username.startsWith('@') ? username : '@$username',
      isAvailable: piece.isForSale,
      aspectRatio: aspectRatioFromDimensions(piece.dimensions),
      priceCents: piece.priceCents,
      shippingRegion: piece.shippingRegion,
      framingNote: piece.framingMounting,
      provenanceNote: piece.provenance,
      heroImageUrl: piece.mediaUrl,
      seriesName: series?.name ?? '',
      seriesThumbs: seriesThumbs,
      seriesThumbUrls: seriesThumbUrls,
      isLiked: piece.isLiked,
      isSaved: piece.isSaved,
      likeCount: piece.likeCount,
      commentCount: piece.commentCount,
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
      isProcess: post.isProcess,
      isLiked: post.isLiked,
      isSaved: post.isSaved,
      likeCount: post.likeCount,
      commentCount: post.commentCount,
    );
  }

  static List<RelatedScene> relatedScenesFromPosts(List<PostSummary> posts) {
    return posts.map(RelatedScene.fromPost).toList(growable: false);
  }

  static List<String> seriesThumbUrlsFrom(PieceSeriesInfo? series) {
    if (series == null) return const [];
    return series.previewPieces
        .map((preview) => preview.mediaUrl)
        .whereType<String>()
        .where((url) => url.isNotEmpty)
        .toList(growable: false);
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
  if (item.heroImageUrl != null && item.heroImageUrl!.isNotEmpty) {
    return item.heroImageUrl!;
  }
  final seed =
      item.imageSeeds[imageIndex.clamp(0, item.imageSeeds.length - 1)];
  switch (item.aspectRatio) {
    case FeedAspectRatio.portrait3x4:
      return picsumUrl(seed, 390, 520);
    case FeedAspectRatio.landscape16x9:
      return picsumUrl(seed, 390, 220);
  }
}
