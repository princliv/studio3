import '../models/feed_item.dart';
import 'api_client.dart';

class SocialService {
  SocialService._();
  static final SocialService instance = SocialService._();

  final _api = ApiClient.instance;

  Future<void> follow(String username) async {
    await _api.post('/api/users/$username/follow', auth: true);
  }

  Future<void> unfollow(String username) async {
    await _api.delete('/api/users/$username/follow');
  }

  Future<void> likePiece(String id) async {
    await _api.post('/api/pieces/$id/like', auth: true);
  }

  Future<void> unlikePiece(String id) async {
    await _api.delete('/api/pieces/$id/like');
  }

  Future<void> likePost(String id) async {
    await _api.post('/api/posts/$id/like', auth: true);
  }

  Future<void> unlikePost(String id) async {
    await _api.delete('/api/posts/$id/like');
  }

  Future<void> savePiece(String id) async {
    await _api.post('/api/pieces/$id/save', auth: true);
  }

  Future<void> unsavePiece(String id) async {
    await _api.delete('/api/pieces/$id/save');
  }

  Future<void> savePost(String id) async {
    await _api.post('/api/posts/$id/save', auth: true);
  }

  Future<void> unsavePost(String id) async {
    await _api.delete('/api/posts/$id/save');
  }

  Future<CommentSummary> commentOnPiece(String id, String body) async {
    final json = await _api.post(
      '/api/pieces/$id/comments',
      body: {'body': body},
      auth: true,
    );
    final data = _api.extractData(json) as Map<String, dynamic>;
    return CommentSummary.fromJson(data);
  }

  Future<CommentSummary> commentOnPost(String id, String body) async {
    final json = await _api.post(
      '/api/posts/$id/comments',
      body: {'body': body},
      auth: true,
    );
    final data = _api.extractData(json) as Map<String, dynamic>;
    return CommentSummary.fromJson(data);
  }
}
