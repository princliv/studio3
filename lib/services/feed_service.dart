import '../data/scene_videos_dummy.dart';
import '../models/feed_item.dart';
import '../models/feed_page.dart';
import 'api_client.dart';
import 'auth_session.dart';

class FeedService {
  FeedService._();
  static final FeedService instance = FeedService._();

  final _api = ApiClient.instance;

  Future<FeedPage> getFollowing({String? cursor, int? limit}) async {
    final json = await _api.get(
      '/api/feed/following',
      query: _query(cursor: cursor, limit: limit),
      auth: true,
    );
    return _parseFeedPage(json);
  }

  Future<FeedPage> getExplore({
    String? medium,
    bool videoOnly = false,
    String? cursor,
    int? limit,
  }) async {
    final query = _query(cursor: cursor, limit: limit);
    if (videoOnly) {
      query['medium'] = 'video';
    } else if (medium != null && medium.isNotEmpty && medium != 'All') {
      query['medium'] = medium.toLowerCase();
    }

    final json = await _api.get(
      '/api/feed/explore',
      query: query.isEmpty ? null : query,
      auth: AuthSession.instance.isLoggedIn,
    );
    return _parseFeedPage(
      json,
      videoOnly: videoOnly,
    );
  }

  Future<FeedPage> getForYou({String? cursor, int? limit}) async {
    final json = await _api.get(
      '/api/feed/for-you',
      query: _query(cursor: cursor, limit: limit),
      auth: true,
    );
    return _parseFeedPage(json);
  }

  /// Video scenes for Reels (`type: post` + `mediaType: video`).
  Future<FeedPage> getVideoScenes({String? cursor, int? limit}) async {
    try {
      final page = await getExplore(
        videoOnly: true,
        cursor: cursor,
        limit: limit,
      );
      if (page.items.isNotEmpty || cursor != null) return page;
    } catch (_) {
      if (cursor != null) rethrow;
    }
    return FeedPage(items: List<FeedItem>.from(kSceneVideoDummyItems));
  }

  Map<String, String> _query({String? cursor, int? limit}) {
    final query = <String, String>{};
    if (cursor != null && cursor.isNotEmpty) query['cursor'] = cursor;
    if (limit != null) query['limit'] = limit.toString();
    return query;
  }

  FeedPage _parseFeedPage(
    Map<String, dynamic> json, {
    bool videoOnly = false,
  }) {
    final data = _api.extractData(json);
    final rawItems = data is Map<String, dynamic> ? data['items'] : data;
    final nextCursor =
        data is Map<String, dynamic> ? data['nextCursor'] as String? : null;

    var items = _api
        .extractList(json)
        .map(FeedItem.fromJson)
        .toList(growable: false);

    if (rawItems is! List && items.isEmpty) {
      items = const [];
    }

    if (videoOnly) {
      items = items
          .where((item) => item.type == FeedItemType.post && item.isVideo)
          .toList(growable: false);
    }

    return FeedPage(items: items, nextCursor: nextCursor);
  }
}
