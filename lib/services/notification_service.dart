import '../models/notification_item.dart';
import 'api_client.dart';

class NotificationPage {
  const NotificationPage({required this.items, this.nextCursor});

  final List<NotificationItem> items;
  final String? nextCursor;
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _api = ApiClient.instance;

  Future<NotificationPage> list({String? cursor, int? limit}) async {
    final query = <String, String>{};
    if (cursor != null && cursor.isNotEmpty) query['cursor'] = cursor;
    if (limit != null) query['limit'] = limit.toString();

    final json = await _api.get(
      '/api/notifications',
      query: query.isEmpty ? null : query,
      auth: true,
    );
    final data = _api.extractData(json);
    final items = _api
        .extractList(json)
        .map(NotificationItem.fromJson)
        .toList(growable: false);
    final nextCursor =
        data is Map<String, dynamic> ? data['nextCursor'] as String? : null;
    return NotificationPage(items: items, nextCursor: nextCursor);
  }

  Future<void> markRead(String id) =>
      _api.patch('/api/notifications/$id/read');

  Future<void> markAllRead() => _api.post('/api/notifications/read-all', auth: true);

  Future<int> getUnreadCount() async {
    final json = await _api.get('/api/notifications/unread-count', auth: true);
    final data = _api.extractData(json);
    return data is Map<String, dynamic> ? (data['count'] as num?)?.toInt() ?? 0 : 0;
  }
}
