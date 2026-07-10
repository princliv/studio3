import '../models/series_summary.dart';
import 'api_client.dart';

class SeriesService {
  SeriesService._();
  static final SeriesService instance = SeriesService._();

  final _api = ApiClient.instance;

  Future<List<SeriesSummary>> getUserSeries(String username) async {
    final json = await _api.get('/api/users/$username/series');
    return _api.extractList(json).map(SeriesSummary.fromJson).toList();
  }

  /// All series owned by the current user (management UI).
  Future<List<SeriesSummary>> getMySeries() async {
    final json = await _api.get('/api/user/me/series', auth: true);
    return _api.extractList(json).map(SeriesSummary.fromJson).toList();
  }

  Future<SeriesSummary> getById(String id) async {
    final json = await _api.get('/api/series/$id');
    final data = _api.extractData(json) as Map<String, dynamic>;
    return SeriesSummary.fromJson(data);
  }

  Future<SeriesSummary> create({
    required String name,
    List<String>? pieceIds,
  }) async {
    final body = <String, dynamic>{'name': name};
    if (pieceIds != null && pieceIds.isNotEmpty) {
      body['pieceIds'] = pieceIds;
    }
    final json = await _api.post('/api/series', body: body, auth: true);
    final data = _api.extractData(json) as Map<String, dynamic>;
    return SeriesSummary.fromJson(data);
  }

  Future<SeriesSummary> update(
    String id, {
    String? name,
    List<String>? pieceOrder,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (pieceOrder != null) body['pieceOrder'] = pieceOrder;
    final json = await _api.patch('/api/series/$id', body: body);
    final data = _api.extractData(json) as Map<String, dynamic>;
    return SeriesSummary.fromJson(data);
  }

  Future<SeriesSummary> addPiece(String seriesId, String pieceId) async {
    final json = await _api.post(
      '/api/series/$seriesId/pieces',
      body: {'pieceId': pieceId},
      auth: true,
    );
    final data = _api.extractData(json) as Map<String, dynamic>;
    return SeriesSummary.fromJson(data);
  }

  Future<SeriesSummary> removePiece(String seriesId, String pieceId) async {
    final json = await _api.delete('/api/series/$seriesId/pieces/$pieceId');
    final data = _api.extractData(json) as Map<String, dynamic>;
    return SeriesSummary.fromJson(data);
  }
}
