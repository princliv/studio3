import '../models/feed_item.dart';
import 'api_client.dart';

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
}
