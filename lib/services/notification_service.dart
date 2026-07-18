import '../models/notification_item.dart';
import 'api_client.dart';
import 'cache_service.dart';
import 'connectivity_service.dart';

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

  /// Cache-first first page — short TTL since notifications are
  /// time-sensitive, but avoids a spinner every time the tab is reopened.
  Future<NotificationPage> listCached({bool forceRefresh = false}) {
    return CacheService.instance.fetchWithCache<NotificationPage>(
      key: 'notifications.list',
      ttl: const Duration(minutes: 1),
      forceRefresh: forceRefresh,
      fetchRaw: () {
        if (!ConnectivityService.instance.isOnline) {
          throw const CacheMiss('notifications.list');
        }
        return _api.get('/api/notifications', auth: true);
      },
      parse: _parsePage,
    );
  }

  Future<int> getUnreadCountCached({bool forceRefresh = false}) {
    return CacheService.instance.fetchWithCache<int>(
      key: 'notifications.unreadCount',
      ttl: const Duration(seconds: 30),
      forceRefresh: forceRefresh,
      fetchRaw: () {
        if (!ConnectivityService.instance.isOnline) {
          throw const CacheMiss('notifications.unreadCount');
        }
        return _api.get('/api/notifications/unread-count', auth: true);
      },
      parse: (json) {
        final data = _api.extractData(json);
        return data is Map<String, dynamic>
            ? (data['count'] as num?)?.toInt() ?? 0
            : 0;
      },
    );
  }

  NotificationPage _parsePage(Map<String, dynamic> json) {
    final data = _api.extractData(json);
    final items = _api
        .extractList(json)
        .map(NotificationItem.fromJson)
        .toList(growable: false);
    final nextCursor =
        data is Map<String, dynamic> ? data['nextCursor'] as String? : null;
    return NotificationPage(items: items, nextCursor: nextCursor);
  }

  Future<void> markRead(String id) async {
    await _api.patch('/api/notifications/$id/read');
    await CacheService.instance.invalidate('notifications.list');
    await CacheService.instance.invalidate('notifications.unreadCount');
  }

  Future<void> markAllRead() async {
    await _api.post('/api/notifications/read-all', auth: true);
    await CacheService.instance.invalidate('notifications.list');
    await CacheService.instance.invalidate('notifications.unreadCount');
  }

  Future<int> getUnreadCount() async {
    final json = await _api.get('/api/notifications/unread-count', auth: true);
    final data = _api.extractData(json);
    return data is Map<String, dynamic> ? (data['count'] as num?)?.toInt() ?? 0 : 0;
  }
}
