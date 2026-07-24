import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../models/chat_message.dart';
import '../services/auth_session.dart';
import '../services/chat_service.dart';
import '../services/chat_socket_service.dart';
import '../services/media_service.dart';
import '../theme/app_theme.dart';
import '../theme/home_feed_tokens.dart';
import '../widgets/accept_decline_buttons.dart';
import '../widgets/home_feed/home_feed_widgets.dart';
import '../widgets/studio_loading.dart';

/// A single 1:1 chat thread — real-time via [ChatSocketService], with REST
/// ([ChatService]) as the source of truth for history and pagination.
///
/// Supports two entry modes:
/// - Existing thread: pass [conversationId] (from the inbox).
/// - New/"compose" thread: pass [conversationId] as null plus
///   [otherPartyUsername] (e.g. from a profile's "Message" button) — no
///   conversation is created on the server until the first message is sent,
///   matching Instagram's actual "Message" button behavior.
class ConversationThreadPage extends StatefulWidget {
  const ConversationThreadPage({
    super.key,
    this.conversationId,
    this.otherPartyId,
    required this.otherPartyUsername,
    required this.otherPartyName,
    required this.otherPartyAvatarUrl,
    this.initialStatus = 'open',
  }) : assert(
         conversationId != null || otherPartyUsername != null,
         'Either conversationId or otherPartyUsername is required.',
       );

  final String? conversationId;
  final String? otherPartyId;
  final String? otherPartyUsername;
  final String otherPartyName;
  final String? otherPartyAvatarUrl;
  final String initialStatus;

  @override
  State<ConversationThreadPage> createState() => _ConversationThreadPageState();
}

class _ConversationThreadPageState extends State<ConversationThreadPage> {
  final List<ChatMessage> _messages = [];
  bool _loading = true;
  bool _sending = false;
  bool _busy = false;
  bool _otherTyping = false;
  bool _otherOnline = false;
  String _status = 'open';
  String? _conversationId;
  String? _otherPartyId;
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _typingStopTimer;

  bool get _isComposing => _conversationId == null;

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus;
    _conversationId = widget.conversationId;
    _otherPartyId = widget.otherPartyId;
    _textController.addListener(_onTextChanged);
    if (_conversationId != null) {
      _load();
      _joinLiveUpdates();
    } else {
      // Compose mode: nothing to load yet — the thread doesn't exist until
      // the first message is sent.
      _loading = false;
    }
  }

  void _joinLiveUpdates() {
    final id = _conversationId;
    if (id == null) return;
    ChatSocketService.instance.joinConversation(id);
    ChatSocketService.instance.onNewMessage(_onSocketMessage);
    ChatSocketService.instance.onTypingStart(_onTypingStart);
    ChatSocketService.instance.onTypingStop(_onTypingStop);
    ChatSocketService.instance.onPresenceUpdate(_onPresenceUpdate);
  }

  @override
  void dispose() {
    final id = _conversationId;
    if (id != null) {
      ChatSocketService.instance.leaveConversation(id);
      ChatSocketService.instance.offNewMessage();
      ChatSocketService.instance.offTypingStart();
      ChatSocketService.instance.offTypingStop();
      ChatSocketService.instance.offPresenceUpdate();
    }
    _typingStopTimer?.cancel();
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final id = _conversationId;
    if (id == null) return; // no live typing signal before the thread exists
    ChatSocketService.instance.startTyping(id);
    _typingStopTimer?.cancel();
    _typingStopTimer = Timer(const Duration(seconds: 2), () {
      ChatSocketService.instance.stopTyping(id);
    });
  }

  void _onSocketMessage(String conversationId, ChatMessage message) {
    if (conversationId != _conversationId || !mounted) return;
    setState(() {
      _messages.add(message);
      _status = 'open';
    });
  }

  void _onTypingStart(String conversationId, String userId) {
    // The server excludes the emitting client from its own broadcast
    // (include_self=False), so any typing event received for this room is
    // always the other participant in a 1:1 thread.
    if (conversationId != _conversationId || !mounted) return;
    setState(() => _otherTyping = true);
  }

  void _onTypingStop(String conversationId, String userId) {
    if (conversationId != _conversationId || !mounted) return;
    setState(() => _otherTyping = false);
  }

  void _onPresenceUpdate(String userId, bool online) {
    if (!mounted || _otherPartyId == null || userId != _otherPartyId) return;
    setState(() => _otherOnline = online);
  }

  Future<void> _load() async {
    final id = _conversationId;
    if (id == null) return;
    setState(() => _loading = true);
    try {
      final thread = await ChatService.instance.getThread(id);
      if (!mounted) return;
      setState(() {
        _messages
          ..clear()
          ..addAll(thread.messages);
        _status = thread.status;
        _otherPartyId = thread.otherPartyId ?? _otherPartyId;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  /// Starts the conversation on the server with the first message, then
  /// switches this page from compose mode into a live thread.
  Future<ChatMessage?> _startWithFirstMessage({
    String? body,
    String? imageUrl,
  }) async {
    final username = widget.otherPartyUsername;
    if (username == null) return null;
    final result = await ChatService.instance.startConversation(
      username,
      body ?? '',
      imageUrl: imageUrl,
    );
    if (!mounted) return null;
    setState(() {
      _conversationId = result.id;
      _status = result.status;
    });
    _joinLiveUpdates();
    // startConversation doesn't return the created message payload — fetch
    // the thread once so the message list (with real id/timestamp) is correct.
    final thread = await ChatService.instance.getThread(result.id);
    if (!mounted) return null;
    setState(() {
      _messages
        ..clear()
        ..addAll(thread.messages);
      _status = thread.status;
    });
    return thread.messages.isNotEmpty ? thread.messages.last : null;
  }

  Future<void> _sendText() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    _textController.clear();
    final id = _conversationId;
    if (id != null) ChatSocketService.instance.stopTyping(id);
    try {
      if (id == null) {
        await _startWithFirstMessage(body: text);
        if (!mounted) return;
        setState(() => _sending = false);
      } else {
        final message = await ChatService.instance.sendMessage(id, body: text);
        if (!mounted) return;
        setState(() {
          _messages.add(message);
          _status = 'open';
          _sending = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send: $e')));
    }
  }

  Future<void> _pickAndSendPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;
    setState(() => _sending = true);
    try {
      final url = await MediaService.instance.uploadFile(
        purpose: MediaPurpose.chat,
        file: File(picked.path),
      );
      final id = _conversationId;
      if (id == null) {
        await _startWithFirstMessage(imageUrl: url);
        if (!mounted) return;
        setState(() => _sending = false);
      } else {
        final message = await ChatService.instance.sendMessage(
          id,
          imageUrl: url,
        );
        if (!mounted) return;
        setState(() {
          _messages.add(message);
          _status = 'open';
          _sending = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send photo: $e')));
    }
  }

  Future<void> _accept() async {
    final id = _conversationId;
    if (id == null) return;
    setState(() => _busy = true);
    try {
      await ChatService.instance.acceptRequest(id);
      if (!mounted) return;
      setState(() {
        _status = 'open';
        _busy = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to accept: $e')));
    }
  }

  Future<void> _decline() async {
    final id = _conversationId;
    if (id == null) return;
    setState(() => _busy = true);
    try {
      await ChatService.instance.declineRequest(id);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to decline: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final myUsername = AuthSession.instance.user?.username;
    final showPendingActions = _status == 'pending';

    return Scaffold(
      backgroundColor: HomeFeedTokens.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: HomeFeedTokens.textPrimary,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      UserAvatar(
                        url: widget.otherPartyAvatarUrl,
                        name: widget.otherPartyName,
                        size: 36,
                      ),
                      if (_otherOnline)
                        Positioned(
                          right: -1,
                          bottom: -1,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green.shade500,
                              border: Border.all(
                                color: HomeFeedTokens.background,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.otherPartyName,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: HomeFeedTokens.textPrimary,
                          ),
                        ),
                        if (_otherTyping)
                          Text(
                            'typing…',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.slate500,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const StudioLoadingBody()
                  : (_isComposing && _messages.isEmpty)
                  ? Center(
                      child: Text(
                        'Say hello to ${widget.otherPartyName}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.slate500,
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      reverse: false,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: _messages.length,
                      itemBuilder: (context, i) {
                        final message = _messages[i];
                        return _MessageBubble(
                          message: message,
                          isMine:
                              myUsername != null &&
                              message.senderUsername == myUsername,
                        );
                      },
                    ),
            ),
            if (showPendingActions)
              Padding(
                padding: const EdgeInsets.all(AppDims.spaceLg),
                child: Center(
                  child: AcceptDeclineButtons(
                    busy: _busy,
                    onAccept: _accept,
                    onDecline: _decline,
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _sending ? null : _pickAndSendPhoto,
                      icon: Icon(
                        Icons.image_outlined,
                        color: HomeFeedTokens.textPrimary,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        minLines: 1,
                        maxLines: 4,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.slate900,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _sending ? null : _sendText,
                      icon: _sending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(Icons.send_rounded, color: AppColors.slate900),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMine});

  final ChatMessage message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final hasImage = message.imageUrl != null && message.imageUrl!.isNotEmpty;
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: hasImage
            ? const EdgeInsets.all(4)
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isMine ? AppColors.slate900 : AppColors.slate100,
          borderRadius: BorderRadius.circular(AppDims.radiusMd),
        ),
        child: hasImage
            ? ClipRRect(
                borderRadius: BorderRadius.circular(AppDims.radiusMd - 4),
                child: Image.network(message.imageUrl!, fit: BoxFit.cover),
              )
            : Text(
                message.body ?? '',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isMine ? AppColors.white : AppColors.slate800,
                ),
              ),
      ),
    );
  }
}
