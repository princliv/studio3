import '../models/post_summary.dart';
import 'api_client.dart';

class PostService {
  PostService._();
  static final PostService instance = PostService._();

  final _api = ApiClient.instance;

  Future<PostSummary> create(Map<String, dynamic> body) async {
    final json = await _api.post('/api/posts', body: body, auth: true);
    final data = _api.extractData(json) as Map<String, dynamic>;
    return PostSummary.fromJson(data);
  }

  Future<PostSummary> getById(String id) async {
    final json = await _api.get('/api/posts/$id');
    final data = _api.extractData(json) as Map<String, dynamic>;
    return PostSummary.fromJson(data);
  }

  Future<PostSummary> update(String id, Map<String, dynamic> body) async {
    final json = await _api.patch('/api/posts/$id', body: body);
    final data = _api.extractData(json) as Map<String, dynamic>;
    return PostSummary.fromJson(data);
  }

  Future<List<PostSummary>> getUserPosts(String username) async {
    final json = await _api.get('/api/users/$username/posts');
    return _api.extractList(json).map(PostSummary.fromJson).toList();
  }
}
