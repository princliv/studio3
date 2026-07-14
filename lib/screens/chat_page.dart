import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/inquiry_summary.dart';
import '../services/auth_session.dart';
import '../services/inquiry_service.dart';
import '../theme/app_theme.dart';
import '../theme/home_feed_tokens.dart';
import '../widgets/glass_card.dart';
import '../widgets/home_feed/home_feed_widgets.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<InquirySummary> _inquiries = [];
  bool _loading = true;
  bool _loadingMore = false;
  String? _nextCursor;
  String? _selectedId;
  InquiryThread? _thread;
  bool _threadLoading = false;
  bool _sending = false;
  final _replyController = TextEditingController();
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
    _replyController.dispose();
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
      final page = await InquiryService.instance.getInbox(
        cursor: append ? _nextCursor : null,
      );
      if (!mounted) return;
      setState(() {
        if (append) {
          _inquiries.addAll(page.items);
        } else {
          _inquiries
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
        if (!append) _inquiries.clear();
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  void _onScroll() {
    if (_loadingMore) return;
    if (_nextCursor == null || _nextCursor!.isEmpty) return;
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      _load(append: true);
    }
  }

  Future<void> _openThread(InquirySummary inquiry) async {
    setState(() {
      _selectedId = inquiry.id;
      _thread = null;
      _threadLoading = true;
    });
    try {
      final thread = await InquiryService.instance.getThread(inquiry.id);
      if (!mounted) return;
      setState(() {
        _thread = thread;
        _threadLoading = false;
        final index = _inquiries.indexWhere((i) => i.id == inquiry.id);
        if (index != -1 && _inquiries[index].unread) {
          _inquiries[index] = InquirySummary(
            id: inquiry.id,
            pieceId: inquiry.pieceId,
            pieceTitle: inquiry.pieceTitle,
            pieceThumbnailUrl: inquiry.pieceThumbnailUrl,
            otherPartyUsername: inquiry.otherPartyUsername,
            otherPartyName: inquiry.otherPartyName,
            otherPartyAvatarUrl: inquiry.otherPartyAvatarUrl,
            preview: inquiry.preview,
            updatedAt: inquiry.updatedAt,
            unread: false,
            status: inquiry.status,
          );
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _threadLoading = false;
        _selectedId = null;
      });
    }
  }

  void _closeThread() {
    setState(() {
      _selectedId = null;
      _thread = null;
      _replyController.clear();
    });
  }

  Future<void> _sendReply() async {
    final id = _selectedId;
    final text = _replyController.text.trim();
    if (id == null || text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      final message = await InquiryService.instance.reply(id, text);
      if (!mounted) return;
      setState(() {
        final thread = _thread;
        if (thread != null) {
          _thread = InquiryThread(
            id: thread.id,
            pieceId: thread.pieceId,
            pieceTitle: thread.pieceTitle,
            pieceThumbnailUrl: thread.pieceThumbnailUrl,
            otherPartyUsername: thread.otherPartyUsername,
            otherPartyName: thread.otherPartyName,
            otherPartyAvatarUrl: thread.otherPartyAvatarUrl,
            status: thread.status,
            messages: [...thread.messages, message],
          );
        }
        _replyController.clear();
        _sending = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send reply: $e')),
      );
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
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Text(
                'Inquiries',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: HomeFeedTokens.textPrimary,
                ),
              ),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      bottomSheet: _selectedId != null
          ? _InquiryBottomSheet(
              thread: _thread,
              loading: _threadLoading,
              sending: _sending,
              replyController: _replyController,
              onClose: _closeThread,
              onSend: _sendReply,
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    if (_inquiries.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mail_outline, size: 48, color: AppColors.slate200),
            const SizedBox(height: AppDims.spaceMd),
            Text(
              'No inquiries yet',
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
        itemCount: _inquiries.length + (_loadingMore ? 1 : 0),
        itemBuilder: (context, i) {
          if (i >= _inquiries.length) {
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
          final inq = _inquiries[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppDims.spaceSm),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _openThread(inq),
                borderRadius: BorderRadius.circular(AppDims.radiusMd),
                child: GlassCard(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      UserAvatar(
                        url: inq.otherPartyAvatarUrl,
                        name: inq.otherPartyDisplayName,
                        size: 48,
                      ),
                      const SizedBox(width: AppDims.spaceSm + 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              inq.displayTitle,
                              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.slate900),
                            ),
                            Text(
                              '${inq.otherPartyDisplayName} — ${inq.preview ?? 'No messages yet'}',
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
                            _timeAgo(inq.updatedAt),
                            style: GoogleFonts.inter(fontSize: 11, color: AppColors.slate400),
                          ),
                          if (inq.unread) ...[
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
}

String _timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';
  return '${(diff.inDays / 7).floor()}w';
}

class _InquiryBottomSheet extends StatelessWidget {
  const _InquiryBottomSheet({
    required this.thread,
    required this.loading,
    required this.sending,
    required this.replyController,
    required this.onClose,
    required this.onSend,
  });

  final InquiryThread? thread;
  final bool loading;
  final bool sending;
  final TextEditingController replyController;
  final VoidCallback onClose;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final myUsername = AuthSession.instance.user?.username;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.75),
      padding: const EdgeInsets.all(AppDims.spaceLg),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDims.radiusXl)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              UserAvatar(
                url: thread?.otherPartyAvatarUrl,
                name: thread?.otherPartyName ?? 'Someone',
                size: 48,
              ),
              const SizedBox(width: AppDims.spaceSm + 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      thread?.displayTitle ?? 'Inquiry',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.slate900),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.slate100, borderRadius: BorderRadius.circular(9999)),
                      child: Text(
                        thread?.otherPartyName ?? '',
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.slate600),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: AppDims.spaceMd),
          if (loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            Flexible(
              child: SingleChildScrollView(
                reverse: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final message in thread?.messages ?? const [])
                      _MessageBubble(
                        message: message,
                        isMine: myUsername != null &&
                            message.senderUsername == myUsername,
                      ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: AppDims.spaceMd),
          TextField(
            controller: replyController,
            maxLines: 3,
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.slate900),
            decoration: InputDecoration(
              hintText: 'Reply...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDims.radiusMd)),
            ),
          ),
          const SizedBox(height: AppDims.spaceSm + 4),
          FilledButton(
            onPressed: sending ? null : onSend,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.slate900,
              minimumSize: const Size.fromHeight(AppDims.primaryButtonHeight),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
              textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            child: sending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Send Reply'),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMine});

  final InquiryMessage message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.7),
        decoration: BoxDecoration(
          color: isMine ? AppColors.slate900 : AppColors.slate100,
          borderRadius: BorderRadius.circular(AppDims.radiusMd),
        ),
        child: Text(
          message.body,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: isMine ? AppColors.white : AppColors.slate800,
          ),
        ),
      ),
    );
  }
}
