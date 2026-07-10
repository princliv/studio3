import '../models/feed_item.dart';
import 'api_client.dart';
import '../data/scene_videos_dummy.dart';

class FeedService {
  FeedService._();
  static final FeedService instance = FeedService._();

  final _api = ApiClient.instance;

  Future<List<FeedItem>> getFollowing() async {
    final json = await _api.get('/api/feed/following', auth: true);
    return _api.extractList(json).map(FeedItem.fromJson).toList();
  }

  Future<List<FeedItem>> getExplore({String? medium, bool videoOnly = false}) async {
    final query = <String, String>{};
    if (videoOnly) {
      query['medium'] = 'video';
    } else if (medium != null && medium.isNotEmpty && medium != 'All') {
      query['medium'] = medium.toLowerCase();
    }
    final json = await _api.get(
      '/api/feed/explore',
      query: query.isEmpty ? null : query,
    );
    final items = _api.extractList(json).map(FeedItem.fromJson).toList();
    if (videoOnly) {
      return items.where((item) => item.isVideo).toList();
    }
    return items;
  }

  Future<List<FeedItem>> getForYou() async {
    final json = await _api.get('/api/feed/for-you', auth: true);
    return _api.extractList(json).map(FeedItem.fromJson).toList();
  }

  /// Video scenes for the Scenes videos tab (`FeedItemType.post` + `isVideo`).
  Future<List<FeedItem>> getVideoScenes() async {
    try {
      final json = await _api.get(
        '/api/feed/explore',
        query: const {'medium': 'video'},
      );
      final items = _api.extractList(json).map(FeedItem.fromJson).toList();
      final videoScenes = items
          .where((item) => item.type == FeedItemType.post && item.isVideo)
          .toList();
      if (videoScenes.isNotEmpty) return videoScenes;
    } catch (_) {
      // Fall through to scene video placeholders.
    }
    return List<FeedItem>.from(kSceneVideoDummyItems);
  }
}
