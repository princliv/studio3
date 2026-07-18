import '../models/piece_summary.dart';
import '../models/post_summary.dart';
import 'api_client.dart';
import 'auth_session.dart';
import 'cache_service.dart';
import 'connectivity_service.dart';

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

  /// Cache-first piece detail — short TTL since availability/price can
  /// change, but enables offline drill-in from an already-cached feed.
  Future<PieceSummary> getByIdCached(String id, {bool forceRefresh = false}) {
    final key = 'piece.$id';
    return CacheService.instance.fetchWithCache<PieceSummary>(
      key: key,
      ttl: const Duration(minutes: 2),
      forceRefresh: forceRefresh,
      fetchRaw: () {
        if (!ConnectivityService.instance.isOnline) {
          throw CacheMiss(key);
        }
        return _api.get(
          '/api/pieces/$id',
          auth: AuthSession.instance.isLoggedIn,
        );
      },
      parse: (json) =>
          PieceSummary.fromJson(_api.extractData(json) as Map<String, dynamic>),
    );
  }

  Future<PieceSummary> update(String id, Map<String, dynamic> body) async {
    final json = await _api.patch('/api/pieces/$id', body: body);
    final data = _api.extractData(json) as Map<String, dynamic>;
    await CacheService.instance.invalidate('piece.$id');
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
