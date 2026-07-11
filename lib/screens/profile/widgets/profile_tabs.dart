import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/home_feed_tokens.dart';
import '../profile_constants.dart';

class ProfileTabs extends StatefulWidget {
  const ProfileTabs({
    super.key,
    required this.currentTab,
    required this.onTabChanged,
    this.showCollect = false,
    this.collectSegment = 'available',
    this.onCollectSegmentChanged,
  });

  final String currentTab;
  final ValueChanged<String> onTabChanged;
  final bool showCollect;
  final String collectSegment;
  final ValueChanged<String>? onCollectSegmentChanged;

  @override
  State<ProfileTabs> createState() => _ProfileTabsState();
}

class _ProfileTabsState extends State<ProfileTabs> {
  final _collectTabKey = GlobalKey();
  final _tabsBarKey = GlobalKey();

  Future<void> _openCollectFilterMenu() async {
    final collectBox =
        _collectTabKey.currentContext?.findRenderObject() as RenderBox?;
    final barBox = _tabsBarKey.currentContext?.findRenderObject() as RenderBox?;
    if (collectBox == null || barBox == null || !mounted) return;

    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final collectCenter = collectBox.localToGlobal(
      collectBox.size.center(Offset.zero),
      ancestor: overlay,
    );
    final barBottom = barBox.localToGlobal(
      barBox.size.bottomLeft(Offset.zero),
      ancestor: overlay,
    );

    final selected = await showCollectFilterMenu(
      context: context,
      anchorCenterX: collectCenter.dx,
      top: barBottom.dy + 6,
      currentSegment: widget.collectSegment,
    );

    if (selected != null && mounted) {
      widget.onTabChanged('collect');
      widget.onCollectSegmentChanged?.call(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = <({String id, String label})>[
      (id: 'pieces', label: 'Pieces'),
      (id: 'series', label: 'Series'),
      (id: 'scenes', label: 'Scenes'),
      if (widget.showCollect) (id: 'collect', label: 'Collect'),
    ];

    return Column(
      key: _tabsBarKey,
      mainAxisSize: MainAxisSize.min,
      children: [
        ColoredBox(
          color: HomeFeedTokens.background,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              kProfileHorizontalPad,
              4,
              kProfileHorizontalPad,
              0,
            ),
            child: Row(
              children: [
                for (final tab in tabs)
                  if (tab.id == 'collect')
                    _CollectTabItem(
                      key: _collectTabKey,
                      active: widget.currentTab == tab.id,
                      onTabTap: () => widget.onTabChanged(tab.id),
                      onFilterTap: _openCollectFilterMenu,
                    )
                  else
                    _TabItem(
                      label: tab.label,
                      active: widget.currentTab == tab.id,
                      onTap: () => widget.onTabChanged(tab.id),
                    ),
              ],
            ),
          ),
        ),
        ColoredBox(
          color: HomeFeedTokens.background,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              kProfileHorizontalPad,
              0,
              kProfileHorizontalPad,
              4,
            ),
            child: Divider(
              height: 1,
              thickness: 1,
              color: HomeFeedTokens.textPrimary.withValues(alpha: 0.12),
            ),
          ),
        ),
      ],
    );
  }
}

/// Glass filter menu shown below the tab bar, not over the Collect label.
Future<String?> showCollectFilterMenu({
  required BuildContext context,
  required double anchorCenterX,
  required double top,
  required String currentSegment,
}) {
  const menuWidth = 148.0;

  return showGeneralDialog<String>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Collect filter',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 160),
    pageBuilder: (context, animation, secondaryAnimation) {
      final screenWidth = MediaQuery.sizeOf(context).width;
      var left = anchorCenterX - menuWidth / 2;
      left = left.clamp(12.0, screenWidth - menuWidth - 12.0);

      return Stack(
        children: [
          Positioned(
            left: left,
            top: top,
            width: menuWidth,
            child: FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.96, end: 1).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
                alignment: Alignment.topCenter,
                child: _CollectFilterGlassMenu(
                  currentSegment: currentSegment,
                  onSelected: (value) => Navigator.pop(context, value),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

class _CollectFilterGlassMenu extends StatelessWidget {
  const _CollectFilterGlassMenu({
    required this.currentSegment,
    required this.onSelected,
  });

  final String currentSegment;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.14),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CollectFilterOption(
                label: 'Available',
                selected: currentSegment == 'available',
                onTap: () => onSelected('available'),
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: Colors.white.withValues(alpha: 0.1),
              ),
              _CollectFilterOption(
                label: 'Sold',
                selected: currentSegment == 'sold',
                onTap: () => onSelected('sold'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CollectFilterOption extends StatelessWidget {
  const _CollectFilterOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: Colors.white.withValues(alpha: selected ? 1 : 0.88),
                  ),
                ),
              ),
              if (selected)
                Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  height: 1.1,
                  color:
                      active ? HomeFeedTokens.textPrimary : kProfileTextMuted,
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  height: 2,
                  width: _indicatorWidth(label, active),
                  decoration: BoxDecoration(
                    color: active
                        ? HomeFeedTokens.textPrimary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _indicatorWidth(String label, bool active) {
    if (!active) return 0;
    final painter = TextPainter(
      text: TextSpan(
        text: label,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          height: 1.1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    return painter.width;
  }
}

class _CollectTabItem extends StatelessWidget {
  const _CollectTabItem({
    super.key,
    required this.active,
    required this.onTabTap,
    required this.onFilterTap,
  });

  final bool active;
  final VoidCallback onTabTap;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    final labelColor =
        active ? HomeFeedTokens.textPrimary : kProfileTextMuted;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: onTabTap,
                  child: Text(
                    'Collect',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                      height: 1.1,
                      color: labelColor,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onFilterTap,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 2, 4, 2),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: labelColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                height: 2,
                width: _collectIndicatorWidth(active),
                decoration: BoxDecoration(
                  color: active
                      ? HomeFeedTokens.textPrimary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _collectIndicatorWidth(bool active) {
    if (!active) return 0;
    const chevronWidth = 20.0;
    final painter = TextPainter(
      text: TextSpan(
        text: 'Collect',
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          height: 1.1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    return painter.width + chevronWidth;
  }
}
