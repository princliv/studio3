import '../models/feed_item.dart';
import '../models/feed_preview_item.dart';
import '../services/piece_service.dart';
import '../services/post_service.dart';
import '../services/auth_session.dart';

/// Loads enriched piece/scene detail for detail screens.
abstract final class ContentDetailLoader {
  static Future<FeedPreviewItem> loadPiece(FeedPreviewItem seed) async {
    if (!seed.isApiBacked || seed.isScene) return seed;
    try {
      final piece = await PieceService.instance.getById(
        seed.id,
        auth: AuthSession.instance.isLoggedIn,
      );
      var item = FeedPreviewItem.fromPieceSummary(piece);
      try {
        final related = await PieceService.instance.getRelatedPosts(seed.id);
        item = item.copyWith(
          relatedScenes: FeedPreviewItem.relatedScenesFromPosts(related),
        );
      } catch (_) {
        // Related scenes are optional enrichment.
      }
      return item;
    } catch (_) {
      return seed;
    }
  }

  static Future<FeedPreviewItem> loadScene(FeedPreviewItem seed) async {
    if (!seed.isApiBacked || !seed.isScene) return seed;
    try {
      final post = await PostService.instance.getById(
        seed.id,
        auth: AuthSession.instance.isLoggedIn,
      );
      return FeedPreviewItem.fromFeedItem(
        FeedItem.post(post),
      );
    } catch (_) {
      return seed;
    }
  }

  static Future<FeedPreviewItem> load(FeedPreviewItem seed) {
    return seed.isScene ? loadScene(seed) : loadPiece(seed);
  }
}
