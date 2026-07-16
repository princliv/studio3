import '../models/nearby_seller.dart';
import 'api_client.dart';
import 'auth_session.dart';

class NearbyService {
  NearbyService._();
  static final NearbyService instance = NearbyService._();

  final _api = ApiClient.instance;

  Future<List<NearbySeller>> getNearbySellers({
    required double lat,
    required double lng,
    int? radiusKm,
    int? limit,
  }) async {
    final query = <String, String>{
      'lat': lat.toString(),
      'lng': lng.toString(),
      if (radiusKm != null) 'radiusKm': radiusKm.toString(),
      if (limit != null) 'limit': limit.toString(),
    };
    final json = await _api.get(
      '/api/users/nearby',
      query: query,
      auth: AuthSession.instance.isLoggedIn,
    );
    return _api.extractList(json).map(NearbySeller.fromJson).toList();
  }
}
