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

  Future<List<FeedItem>> getExplore({String? medium}) async {
    final query = medium != null && medium.isNotEmpty && medium != 'All'
        ? {'medium': medium.toLowerCase()}
        : null;
    final json = await _api.get('/api/feed/explore', query: query);
    return _api.extractList(json).map(FeedItem.fromJson).toList();
  }

  Future<List<FeedItem>> getForYou() async {
    final json = await _api.get('/api/feed/for-you', auth: true);
    return _api.extractList(json).map(FeedItem.fromJson).toList();
  }
}
