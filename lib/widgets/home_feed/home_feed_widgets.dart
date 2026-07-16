import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/nav_assets.dart';
import '../../models/feed_preview_item.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/home_feed_tokens.dart';
import '../../utils/profile_navigation.dart';
import '../studio_logo.dart';

class FeedHomeHeader extends StatelessWidget {
  const FeedHomeHeader({
    super.key,
    required this.filter,
    required this.onFilterChanged,
    required this.onAddTap,
  });

  final FeedAvailabilityFilter filter;
  final ValueChanged<FeedAvailabilityFilter> onFilterChanged;
  final VoidCallback onAddTap;

  static const _headerHeight = 52.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _headerHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 16,
            top: 0,
            bottom: 0,
            child: Center(
              child: Image.asset(
                StudioLogoPaths.iconBlack,
                width: 29,
                height: 27,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FeedFilterTab(
                label: 'All',
                active: filter == FeedAvailabilityFilter.all,
                onTap: () => onFilterChanged(FeedAvailabilityFilter.all),
              ),
              const SizedBox(width: 24),
              FeedFilterTab(
                label: 'Available',
                active: filter == FeedAvailabilityFilter.available,
                onTap: () =>
                    onFilterChanged(FeedAvailabilityFilter.available),
              ),
            ],
          ),
          Positioned(
            right: 12,
            top: 0,
            bottom: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: onAddTap,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: SvgPicture.asset(
                      NavAssets.plusIcon,
                      width: 16,
                      height: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const _InboxMenuButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Right-side header icon that opens a small popup with
/// "Notifications" and "Chats" entries.
class _InboxMenuButton extends StatefulWidget {
  const _InboxMenuButton();

  @override
  State<_InboxMenuButton> createState() => _InboxMenuButtonState();
}

class _InboxMenuButtonState extends State<_InboxMenuButton> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _refreshUnreadCount();
  }

  Future<void> _refreshUnreadCount() async {
    try {
      final count = await NotificationService.instance.getUnreadCount();
      if (!mounted) return;
      setState(() => _unreadCount = count);
    } catch (_) {
      // Keep the last known count if the request fails.
    }
  }

  Future<void> _openMenu(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox;
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        box.localToGlobal(Offset(0, box.size.height), ancestor: overlay),
        box.localToGlobal(
          box.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    final selection = await showMenu<String>(
      context: context,
      position: position,
      color: HomeFeedTokens.background,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDims.radiusMd),
      ),
      items: const [
        PopupMenuItem(
          value: '/notifications',
          child: _InboxMenuRow(
            icon: Icons.notifications_none_rounded,
            label: 'Notifications',
          ),
        ),
        PopupMenuItem(
          value: '/chat',
          child: _InboxMenuRow(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Chats',
          ),
        ),
      ],
    );

    if (selection != null && context.mounted) {
      await Navigator.pushNamed(context, selection);
      _refreshUnreadCount();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () => _openMenu(context),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              SvgPicture.asset(
                NavAssets.bellIcon,
                width: 18,
                height: 18,
              ),
              if (_unreadCount > 0)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE05252),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _unreadCount > 9 ? '9+' : '$_unreadCount',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InboxMenuRow extends StatelessWidget {
  const _InboxMenuRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: HomeFeedTokens.textPrimary),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: HomeFeedTokens.textPrimary,
          ),
        ),
      ],
    );
  }
}

class FeedFilterTab extends StatelessWidget {
  const FeedFilterTab({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: active
              ? HomeFeedTokens.textPrimary
              : HomeFeedTokens.textSecondary,
          decoration: active ? TextDecoration.underline : null,
          decorationColor: HomeFeedTokens.textPrimary,
          decorationThickness: 1,
        ),
      ),
    );
  }
}

class FeedDotIndicators extends StatelessWidget {
  const FeedDotIndicators({
    super.key,
    required this.count,
    required this.page,
  });

  final int count;
  final double page;

  @override
  Widget build(BuildContext context) {
    if (count <= 1) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final d = (page - i).abs().clamp(0.0, 1.0);
        final opacity = 0.5 + 0.5 * (1.0 - d);
        return Padding(
          padding: EdgeInsets.only(left: i > 0 ? 4 : 0),
          child: Container(
            width: HomeFeedTokens.dotSize,
            height: HomeFeedTokens.dotSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: opacity.clamp(0.5, 1.0)),
            ),
          ),
        );
      }),
    );
  }
}

/// Shows a real avatar photo when a URL is available, otherwise an
/// initials circle — avoids ever showing a fake stranger's photo.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.url,
    required this.name,
    this.size = HomeFeedTokens.avatarSize,
  });

  final String? url;
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (url != null && url!.isNotEmpty) {
      final px = (size * MediaQuery.devicePixelRatioOf(context)).round();
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: url!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          memCacheWidth: px,
          memCacheHeight: px,
          errorWidget: (context, error, stackTrace) =>
              _InitialsAvatar(name: name, size: size),
        ),
      );
    }
    return _InitialsAvatar(name: name, size: size);
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.name, required this.size});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final initial = trimmed.isNotEmpty ? trimmed[0].toUpperCase() : '?';
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: HomeFeedTokens.neutral800,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: GoogleFonts.inter(
          fontSize: size * 0.42,
          fontWeight: FontWeight.w600,
          color: HomeFeedTokens.textInverse,
        ),
      ),
    );
  }
}

class FeedCardArtistStrip extends StatelessWidget {
  const FeedCardArtistStrip({
    super.key,
    required this.avatarUrl,
    required this.name,
    this.medium,
    this.authorUsername,
  });

  final String? avatarUrl;
  final String name;
  final String? medium;
  final String? authorUsername;

  void _onAvatarTap(BuildContext context) {
    openUserProfile(context, authorUsername);
  }

  @override
  Widget build(BuildContext context) {
    final canNavigate =
        authorUsername != null && authorUsername!.trim().isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: canNavigate ? () => _onAvatarTap(context) : null,
          behavior:
              canNavigate ? HitTestBehavior.opaque : HitTestBehavior.deferToChild,
          child: UserAvatar(
            url: avatarUrl,
            name: name,
            size: HomeFeedTokens.avatarSize,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: HomeFeedTokens.textInverse,
                ),
              ),
              if (medium != null && medium!.isNotEmpty)
                Text(
                  medium!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w300,
                    color: HomeFeedTokens.textInverse.withValues(alpha: 0.6),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Bottom scrim + artist strip for API grid cards.
class FeedApiCardOverlay extends StatelessWidget {
  const FeedApiCardOverlay({
    super.key,
    required this.avatarUrl,
    required this.name,
    this.medium,
    this.authorUsername,
  });

  final String? avatarUrl;
  final String name;
  final String? medium;
  final String? authorUsername;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const FeedCardBottomScrim(),
        Positioned(
          left: 8,
          right: 8,
          bottom: 8,
          child: FeedCardArtistStrip(
            avatarUrl: avatarUrl,
            name: name,
            medium: medium,
            authorUsername: authorUsername,
          ),
        ),
      ],
    );
  }
}

class FeedPicsumImage extends StatelessWidget {
  const FeedPicsumImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
  });

  final String url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dpr = MediaQuery.devicePixelRatioOf(context);
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final cacheWidth = (maxWidth * dpr).round().clamp(1, 2048);
        return CachedNetworkImage(
          imageUrl: url,
          fit: fit,
          width: double.infinity,
          height: double.infinity,
          memCacheWidth: cacheWidth,
          progressIndicatorBuilder: (context, child, progress) => Container(
            color: Colors.grey.shade300,
            alignment: Alignment.center,
            child: const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          errorWidget: (context, error, stackTrace) => Container(
            color: Colors.grey.shade400,
            alignment: Alignment.center,
            child: Icon(
              Icons.image_not_supported_outlined,
              color: Colors.grey.shade600,
            ),
          ),
        );
      },
    );
  }
}

class FeedCardBottomScrim extends StatelessWidget {
  const FeedCardBottomScrim({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: 88,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              const Color(0xFF231F1B).withValues(alpha: 0.8),
            ],
          ),
        ),
      ),
    );
  }
}

