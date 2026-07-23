import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/chat_message.dart';
import '../services/chat_service.dart';
import '../theme/app_theme.dart';
import '../theme/home_feed_tokens.dart';
import '../widgets/accept_decline_buttons.dart';
import '../widgets/glass_card.dart';
import '../widgets/home_feed/home_feed_widgets.dart';
import 'conversation_thread_page.dart';
import 'new_message_page.dart';

enum _InboxTab { all, requests }

/// Instagram-style DM inbox — general-purpose 1:1 chat (replaces the
/// piece-anchored Inquiries feature for v1, deferred to v2).
class DirectMessagesPage extends StatefulWidget {
  const DirectMessagesPage({super.key});

  @override
  State<DirectMessagesPage> createState() => _DirectMessagesPageState();
}

class _DirectMessagesPageState extends State<DirectMessagesPage> {
  _InboxTab _activeTab = _InboxTab.all;

  final List<ConversationSummary> _conversations = [];
  bool _loading = true;
  bool _loadingMore = false;
  String? _nextCursor;

  final List<ConversationSummary> _requests = [];
  bool _requestsLoading = true;
  bool _requestsLoaded = false;
  bool _requestsLoadingMore = false;
  String? _requestsNextCursor;
  final Set<String> _requestBusy = {};

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _load();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load({bool append = false}) async {
    if (append && (_nextCursor == null || _nextCursor!.isEmpty)) return;
    setState(() {
      if (append) {
        _loadingMore = true;
      } else {
        _loading = true;
      }
    });
    try {
      final page = await ChatService.instance.getInbox(
        cursor: append ? _nextCursor : null,
      );
      if (!mounted) return;
      setState(() {
        if (append) {
          _conversations.addAll(page.items);
        } else {
          _conversations
            ..clear()
            ..addAll(page.items);
        }
        _nextCursor = page.nextCursor;
        _loading = false;
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        if (!append) _conversations.clear();
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  Future<void> _loadRequests({bool append = false}) async {
    if (append && (_requestsNextCursor == null || _requestsNextCursor!.isEmpty)) {
      return;
    }
    setState(() {
      if (append) {
        _requestsLoadingMore = true;
      } else {
        _requestsLoading = true;
      }
    });
    try {
      final page = await ChatService.instance.listRequests(
        cursor: append ? _requestsNextCursor : null,
      );
      if (!mounted) return;
      setState(() {
        if (append) {
          _requests.addAll(page.items);
        } else {
          _requests
            ..clear()
            ..addAll(page.items);
        }
        _requestsNextCursor = page.nextCursor;
        _requestsLoading = false;
        _requestsLoadingMore = false;
        _requestsLoaded = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        if (!append) _requests.clear();
        _requestsLoading = false;
        _requestsLoadingMore = false;
        _requestsLoaded = true;
      });
    }
  }

  void _onTabChanged(_InboxTab tab) {
    setState(() => _activeTab = tab);
    if (tab == _InboxTab.requests && !_requestsLoaded) _loadRequests();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels < pos.maxScrollExtent - 200) return;
    if (_activeTab == _InboxTab.all) {
      if (_loadingMore) return;
      if (_nextCursor == null || _nextCursor!.isEmpty) return;
      _load(append: true);
    } else {
      if (_requestsLoadingMore) return;
      if (_requestsNextCursor == null || _requestsNextCursor!.isEmpty) return;
      _loadRequests(append: true);
    }
  }

  Future<void> _openNewMessage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewMessagePage()),
    );
    // The composer replaces itself with ConversationThreadPage rather than popping back
    // here directly, so refresh in case a new conversation was started in the meantime.
    _load();
  }

  Future<void> _openThread(ConversationSummary conversation, {required bool isRequest}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConversationThreadPage(
          conversationId: conversation.id,
          otherPartyId: conversation.otherPartyId,
          otherPartyUsername: conversation.otherPartyUsername,
          otherPartyName: conversation.otherPartyDisplayName,
          otherPartyAvatarUrl: conversation.otherPartyAvatarUrl,
          initialStatus: conversation.status,
        ),
      ),
    );
    // Refresh both lists on return — accept/decline/read may have changed status.
    _load();
    if (_requestsLoaded) _loadRequests();
  }

  Future<void> _acceptRequest(ConversationSummary request) async {
    setState(() => _requestBusy.add(request.id));
    try {
      await ChatService.instance.acceptRequest(request.id);
      if (!mounted) return;
      setState(() {
        _requests.removeWhere((r) => r.id == request.id);
        _conversations.insert(0, request.copyWith(status: 'open'));
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to accept: $e')),
      );
    } finally {
      if (mounted) setState(() => _requestBusy.remove(request.id));
    }
  }

  Future<void> _declineRequest(ConversationSummary request) async {
    setState(() => _requestBusy.add(request.id));
    try {
      await ChatService.instance.declineRequest(request.id);
    } catch (_) {
      // Treat as handled either way.
    } finally {
      if (mounted) {
        setState(() {
          _requests.removeWhere((r) => r.id == request.id);
          _requestBusy.remove(request.id);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeFeedTokens.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 12),
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
                  Expanded(
                    child: Text(
                      'Chats',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: HomeFeedTokens.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.edit_square,
                      color: HomeFeedTokens.textPrimary,
                      size: 22,
                    ),
                    onPressed: _openNewMessage,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  FeedFilterTab(
                    label: 'All',
                    active: _activeTab == _InboxTab.all,
                    onTap: () => _onTabChanged(_InboxTab.all),
                  ),
                  const SizedBox(width: 24),
                  FeedFilterTab(
                    label: _requests.isEmpty
                        ? 'Requests'
                        : 'Requests (${_requests.length})',
                    active: _activeTab == _InboxTab.requests,
                    onTap: () => _onTabChanged(_InboxTab.requests),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _activeTab == _InboxTab.all ? _buildAllBody() : _buildRequestsBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    if (_conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline_rounded, size: 48, color: AppColors.slate200),
            const SizedBox(height: AppDims.spaceMd),
            Text(
              'No messages yet',
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.slate500),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _conversations.length + (_loadingMore ? 1 : 0),
        itemBuilder: (context, i) {
          if (i >= _conversations.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }
          final conversation = _conversations[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppDims.spaceSm),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _openThread(conversation, isRequest: false),
                borderRadius: BorderRadius.circular(AppDims.radiusMd),
                child: GlassCard(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      UserAvatar(
                        url: conversation.otherPartyAvatarUrl,
                        name: conversation.otherPartyDisplayName,
                        size: 48,
                      ),
                      const SizedBox(width: AppDims.spaceSm + 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              conversation.otherPartyDisplayName,
                              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.slate900),
                            ),
                            Text(
                              conversation.preview ?? 'No messages yet',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(fontSize: 13, color: AppColors.slate500),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _timeAgo(conversation.updatedAt),
                            style: GoogleFonts.inter(fontSize: 11, color: AppColors.slate400),
                          ),
                          if (conversation.unread) ...[
                            const SizedBox(height: 4),
                            Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.slate900)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRequestsBody() {
    if (_requestsLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    if (_requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mark_email_unread_outlined, size: 48, color: AppColors.slate200),
            const SizedBox(height: AppDims.spaceMd),
            Text(
              'No message requests',
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.slate500),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRequests,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _requests.length + (_requestsLoadingMore ? 1 : 0),
        itemBuilder: (context, i) {
          if (i >= _requests.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }
          final conversation = _requests[i];
          final busy = _requestBusy.contains(conversation.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: AppDims.spaceSm),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _openThread(conversation, isRequest: true),
                borderRadius: BorderRadius.circular(AppDims.radiusMd),
                child: GlassCard(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      UserAvatar(
                        url: conversation.otherPartyAvatarUrl,
                        name: conversation.otherPartyDisplayName,
                        size: 48,
                      ),
                      const SizedBox(width: AppDims.spaceSm + 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              conversation.otherPartyDisplayName,
                              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.slate900),
                            ),
                            Text(
                              conversation.preview ?? 'No messages yet',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(fontSize: 13, color: AppColors.slate500),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      AcceptDeclineButtons(
                        busy: busy,
                        onAccept: () => _acceptRequest(conversation),
                        onDecline: () => _declineRequest(conversation),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

String _timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';
  return '${(diff.inDays / 7).floor()}w';
}
