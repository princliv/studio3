import 'package:socket_io_client/socket_io_client.dart' as io;

import '../config/api_config.dart';
import '../models/chat_message.dart';
import 'auth_session.dart';

/// Real-time layer for chat: wraps a single Socket.IO connection authenticated
/// with the same JWT used for REST calls. REST (ChatService) remains the
/// source of truth for history/pagination; this only carries live deltas.
class ChatSocketService {
  ChatSocketService._();
  static final ChatSocketService instance = ChatSocketService._();

  io.Socket? _socket;
  final _notificationListeners =
      <void Function(Map<String, dynamic> json)>{};

  void connect() {
    final token = AuthSession.instance.accessToken;
    if (token == null || token.isEmpty) return;
    _socket?.dispose();
    _socket = io.io(
      ApiConfig.baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setQuery({'token': token})
          .enableAutoConnect()
          .enableReconnection()
          .build(),
    );
    _wireNotificationFanout();
  }

  void disconnect() {
    _socket?.dispose();
    _socket = null;
    _notificationListeners.clear();
  }

  void _wireNotificationFanout() {
    _socket?.off('notification:new');
    _socket?.on('notification:new', (data) {
      final json = Map<String, dynamic>.from(data as Map);
      for (final cb in List.of(_notificationListeners)) {
        cb(json);
      }
    });
  }

  void joinConversation(String conversationId) {
    _socket?.emit('conversation:join', {'conversationId': conversationId});
  }

  void leaveConversation(String conversationId) {
    _socket?.emit('conversation:leave', {'conversationId': conversationId});
  }

  // Writes stay on REST ([ChatService.sendMessage]); socket is receive-only
  // for launch. Do not emit message:send from the client.

  void startTyping(String conversationId) =>
      _socket?.emit('typing:start', {'conversationId': conversationId});

  void stopTyping(String conversationId) =>
      _socket?.emit('typing:stop', {'conversationId': conversationId});

  // Listener registration is exclusive per event (a new call replaces the previous listener)
  // rather than additive, since only one screen at a time (the current conversation thread)
  // ever needs to be listening — this keeps a screen's dispose() -> off*() pairing simple and
  // prevents a disposed screen's stale callback from firing (and calling setState after
  // dispose) the next time a thread page is opened.
  void onNewMessage(void Function(String conversationId, ChatMessage message) callback) {
    _socket?.off('message:new');
    _socket?.on('message:new', (data) {
      final json = Map<String, dynamic>.from(data as Map);
      final conversationId = json['conversationId'] as String? ?? '';
      callback(conversationId, ChatMessage.fromJson(json));
    });
  }

  void offNewMessage() => _socket?.off('message:new');

  void onMessageError(void Function(String message, {String? code}) callback) {
    _socket?.off('message:error');
    _socket?.on('message:error', (data) {
      final json = data is Map
          ? Map<String, dynamic>.from(data)
          : <String, dynamic>{'message': data?.toString() ?? 'Message error'};
      callback(
        json['message'] as String? ?? 'Message error',
        code: json['code'] as String?,
      );
    });
  }

  void offMessageError() => _socket?.off('message:error');

  void onTypingStart(void Function(String conversationId, String userId) callback) {
    _socket?.off('typing:start');
    _socket?.on('typing:start', (data) {
      final json = Map<String, dynamic>.from(data as Map);
      callback(json['conversationId'] as String? ?? '', json['userId'] as String? ?? '');
    });
  }

  void offTypingStart() => _socket?.off('typing:start');

  void onTypingStop(void Function(String conversationId, String userId) callback) {
    _socket?.off('typing:stop');
    _socket?.on('typing:stop', (data) {
      final json = Map<String, dynamic>.from(data as Map);
      callback(json['conversationId'] as String? ?? '', json['userId'] as String? ?? '');
    });
  }

  void offTypingStop() => _socket?.off('typing:stop');

  void onPresenceUpdate(void Function(String userId, bool online) callback) {
    _socket?.off('presence:update');
    _socket?.on('presence:update', (data) {
      final json = Map<String, dynamic>.from(data as Map);
      callback(json['userId'] as String? ?? '', json['online'] as bool? ?? false);
    });
  }

  void offPresenceUpdate() => _socket?.off('presence:update');

  void onConversationRead(
    void Function(String conversationId, String readerId, DateTime readAt)
        callback,
  ) {
    _socket?.off('conversation:read');
    _socket?.on('conversation:read', (data) {
      final json = Map<String, dynamic>.from(data as Map);
      final readAt = DateTime.tryParse(json['readAt'] as String? ?? '') ??
          DateTime.now();
      callback(
        json['conversationId'] as String? ?? '',
        json['readerId'] as String? ?? '',
        readAt,
      );
    });
  }

  void offConversationRead() => _socket?.off('conversation:read');

  /// Additive — home badge and Notifications tab can both listen.
  void onNotificationNew(void Function(Map<String, dynamic> json) callback) {
    _notificationListeners.add(callback);
    _wireNotificationFanout();
  }

  void offNotificationNew([void Function(Map<String, dynamic> json)? callback]) {
    if (callback != null) {
      _notificationListeners.remove(callback);
    } else {
      _notificationListeners.clear();
    }
  }
  void joinTarget({required String targetType, required String targetId}) {
    _socket?.emit('target:join', {
      'targetType': targetType,
      'targetId': targetId,
    });
  }

  void leaveTarget({required String targetType, required String targetId}) {
    _socket?.emit('target:leave', {
      'targetType': targetType,
      'targetId': targetId,
    });
  }

  void onCommentNew(void Function(Map<String, dynamic> json) callback) {
    _socket?.off('comment:new');
    _socket?.on('comment:new', (data) {
      callback(Map<String, dynamic>.from(data as Map));
    });
  }

  void offCommentNew() => _socket?.off('comment:new');
}
