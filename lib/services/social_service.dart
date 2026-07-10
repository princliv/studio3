import '../models/comment_page.dart';
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

  Future<CommentPage> getPieceComments(
    String id, {
    String? cursor,
    int? limit,
  }) async {
    final json = await _api.get(
      '/api/pieces/$id/comments',
      query: _commentQuery(cursor: cursor, limit: limit),
    );
    return _parseCommentPage(json);
  }

  Future<CommentPage> getPostComments(
    String id, {
    String? cursor,
    int? limit,
  }) async {
    final json = await _api.get(
      '/api/posts/$id/comments',
      query: _commentQuery(cursor: cursor, limit: limit),
    );
    return _parseCommentPage(json);
  }

  Map<String, String> _commentQuery({String? cursor, int? limit}) {
    final query = <String, String>{};
    if (cursor != null && cursor.isNotEmpty) query['cursor'] = cursor;
    if (limit != null) query['limit'] = limit.toString();
    return query;
  }

  CommentPage _parseCommentPage(Map<String, dynamic> json) {
    final data = _api.extractData(json);
    final nextCursor =
        data is Map<String, dynamic> ? data['nextCursor'] as String? : null;
    final items = _api
        .extractList(json)
        .map(CommentSummary.fromJson)
        .toList(growable: false);
    return CommentPage(items: items, nextCursor: nextCursor);
  }
}
