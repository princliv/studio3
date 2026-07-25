import '../models/feed_item.dart';
import '../models/feed_preview_item.dart';
import '../services/engagement_store.dart';
import '../services/piece_service.dart';
import '../services/post_service.dart';
import '../services/auth_session.dart';

/// Loads enriched piece/scene detail for detail screens.
abstract final class ContentDetailLoader {
  static FeedPreviewItem _withEngagement(FeedPreviewItem item) {
    return EngagementStore.instance.applyToPreview(item);
  }

  static Future<FeedPreviewItem> loadPiece(FeedPreviewItem seed) async {
    if (!seed.isApiBacked || seed.isScene) return _withEngagement(seed);
    try {
      final piece = await PieceService.instance.getByIdCached(seed.id);
      var item = FeedPreviewItem.fromPieceSummary(piece);
      try {
        final related = await PieceService.instance.getRelatedPosts(seed.id);
        item = item.copyWith(
          relatedScenes: FeedPreviewItem.relatedScenesFromPosts(related),
        );
      } catch (_) {
        // Related scenes are optional enrichment.
      }
      return _withEngagement(item);
    } catch (_) {
      return _withEngagement(seed);
    }
  }

  static Future<FeedPreviewItem> loadScene(FeedPreviewItem seed) async {
    if (!seed.isApiBacked || !seed.isScene) return _withEngagement(seed);
    try {
      final post = await PostService.instance.getById(
        seed.id,
        auth: AuthSession.instance.isLoggedIn,
      );
      return _withEngagement(FeedPreviewItem.fromFeedItem(FeedItem.post(post)));
    } catch (_) {
      return _withEngagement(seed);
    }
  }

  static Future<FeedPreviewItem> load(FeedPreviewItem seed) {
    return seed.isScene ? loadScene(seed) : loadPiece(seed);
  }
}
