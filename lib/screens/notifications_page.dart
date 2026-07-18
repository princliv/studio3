import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/notification_item.dart';
import '../services/connectivity_service.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../theme/home_feed_tokens.dart';
import '../widgets/glass_card.dart';
import '../widgets/home_feed/home_feed_widgets.dart';
import '../widgets/offline_state.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<NotificationItem> _items = [];
  bool _loading = true;
  bool _loadingMore = false;
  String? _nextCursor;
  final _scrollController = ScrollController();

  bool _showOfflineState = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    ConnectivityService.instance.addReconnectHook(_onReconnected);
    _load();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    ConnectivityService.instance.removeReconnectHook(_onReconnected);
    super.dispose();
  }

  Future<void> _onReconnected() => _load(refresh: true);

  Future<void> _load({bool append = false, bool refresh = false}) async {
    if (append && (_nextCursor == null || _nextCursor!.isEmpty)) return;
    setState(() {
      if (append) {
        _loadingMore = true;
      } else {
        _loading = true;
      }
    });
    try {
      final page = append
          ? await NotificationService.instance.list(cursor: _nextCursor)
          : await NotificationService.instance.listCached(
              forceRefresh: refresh,
            );
      if (!mounted) return;
      setState(() {
        if (append) {
          _items.addAll(page.items);
        } else {
          _items
            ..clear()
            ..addAll(page.items);
        }
        _nextCursor = page.nextCursor;
        _loading = false;
        _loadingMore = false;
        _showOfflineState =
            _items.isEmpty && !ConnectivityService.instance.isOnline;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        if (!append) _items.clear();
        _loading = false;
        _loadingMore = false;
        _showOfflineState =
            _items.isEmpty && !ConnectivityService.instance.isOnline;
      });
    }
  }

  void _onScroll() {
    if (_loadingMore) return;
    if (_nextCursor == null || _nextCursor!.isEmpty) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      _load(append: true);
    }
  }

  Future<void> _onTap(NotificationItem item) async {
    if (item.read) return;
    setState(() {
      final index = _items.indexWhere((n) => n.id == item.id);
      if (index != -1) {
        _items[index] = NotificationItem(
          id: item.id,
          type: item.type,
          actorName: item.actorName,
          actorUsername: item.actorUsername,
          actorAvatarUrl: item.actorAvatarUrl,
          targetType: item.targetType,
          targetId: item.targetId,
          payload: item.payload,
          message: item.message,
          read: true,
          createdAt: item.createdAt,
        );
      }
    });
    try {
      await NotificationService.instance.markRead(item.id);
    } catch (_) {
      // Keep the optimistic read state even if the request fails.
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = _items
        .where((n) => now.difference(n.createdAt) < const Duration(hours: 24))
        .toList();
    final earlier = _items
        .where((n) => now.difference(n.createdAt) >= const Duration(hours: 24))
        .toList();

    return Scaffold(
      backgroundColor: HomeFeedTokens.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Text(
                'Activity',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: HomeFeedTokens.textPrimary,
                ),
              ),
            ),
            Expanded(child: _buildBody(today, earlier)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    List<NotificationItem> today,
    List<NotificationItem> earlier,
  ) {
    if (_showOfflineState) {
      return OfflineState(onRetry: () => _load(refresh: true));
    }
    if (_loading && _items.isEmpty) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    if (_items.isEmpty) {
      return Center(
        child: Text(
          'No activity yet',
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.slate400),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _load(),
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          if (today.isNotEmpty) ...[
            _SectionLabel('Today'),
            ...today.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _ActivityCard(item: item, onTap: () => _onTap(item)),
                )),
            const SizedBox(height: 8),
          ],
          if (earlier.isNotEmpty) ...[
            _SectionLabel('Earlier'),
            ...earlier.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _ActivityCard(item: item, onTap: () => _onTap(item)),
                )),
          ],
          if (_loadingMore)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.slate400,
        ),
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

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.item, required this.onTap});

  final NotificationItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserAvatar(
              url: item.actorAvatarUrl,
              name: item.actorDisplayName,
              size: 36,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '${item.actorDisplayName} ',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate900,
                    ),
                  ),
                  Text(
                    item.displayText,
                    style: GoogleFonts.inter(fontSize: 14, color: AppColors.slate700),
                  ),
                  if (item.isInquiry) ...[
                    const SizedBox(width: 6),
                    _Pill(label: 'Inquiry', background: AppColors.slate100, textColor: AppColors.slate600),
                  ],
                  if (item.isSale) ...[
                    const SizedBox(width: 6),
                    _Pill(label: 'Sale', background: AppColors.slate900, textColor: AppColors.white, bold: true),
                  ],
                  if (!item.read) ...[
                    const SizedBox(width: 6),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.slate900,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _timeAgo(item.createdAt),
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.slate400),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.background,
    required this.textColor,
    this.bold = false,
  });

  final String label;
  final Color background;
  final Color textColor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
          color: textColor,
        ),
      ),
    );
  }
}
