import '../models/piece_summary.dart';
import '../models/post_summary.dart';
import 'api_client.dart';
import 'auth_session.dart';

class PieceService {
  PieceService._();
  static final PieceService instance = PieceService._();

  final _api = ApiClient.instance;

  Future<PieceSummary> create(Map<String, dynamic> body) async {
    final json = await _api.post('/api/pieces', body: body, auth: true);
    final data = _api.extractData(json) as Map<String, dynamic>;
    return PieceSummary.fromJson(data);
  }

  Future<PieceSummary> getById(String id, {bool? auth}) async {
    final json = await _api.get(
      '/api/pieces/$id',
      auth: auth ?? AuthSession.instance.isLoggedIn,
    );
    final data = _api.extractData(json) as Map<String, dynamic>;
    return PieceSummary.fromJson(data);
  }

  Future<PieceSummary> update(String id, Map<String, dynamic> body) async {
    final json = await _api.patch('/api/pieces/$id', body: body);
    final data = _api.extractData(json) as Map<String, dynamic>;
    return PieceSummary.fromJson(data);
  }

  Future<List<PieceSummary>> getUserPieces(String username) async {
    final json = await _api.get('/api/users/$username/pieces');
    return _api.extractList(json).map(PieceSummary.fromJson).toList();
  }

  Future<List<PieceSummary>> getUserPiecesForSale(String username) async {
    final json = await _api.get('/api/users/$username/pieces/for-sale');
    return _api.extractList(json).map(PieceSummary.fromJson).toList();
  }

  Future<List<PostSummary>> getRelatedPosts(String pieceId) async {
    final json = await _api.get('/api/pieces/$pieceId/related-posts');
    return _api.extractList(json).map(PostSummary.fromJson).toList();
  }

  Future<void> delete(String id) => _api.delete('/api/pieces/$id');
}
