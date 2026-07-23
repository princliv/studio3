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
  }

  void disconnect() {
    _socket?.dispose();
    _socket = null;
  }

  void joinConversation(String conversationId) {
    _socket?.emit('conversation:join', {'conversationId': conversationId});
  }

  void leaveConversation(String conversationId) {
    _socket?.emit('conversation:leave', {'conversationId': conversationId});
  }

  void sendMessage(String conversationId, {String? body, String? imageUrl}) {
    _socket?.emit('message:send', {
      'conversationId': conversationId,
      if (body != null) 'body': body,
      if (imageUrl != null) 'imageUrl': imageUrl,
    });
  }

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
}
