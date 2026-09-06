import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../theme/home_feed_tokens.dart';
import '../profile_constants.dart';

class ProfileTabs extends StatefulWidget {
  const ProfileTabs({
    super.key,
    required this.currentTab,
    required this.onTabChanged,
    this.showCollect = false,
    this.collectSegment = 'all',
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
  bool _collectMenuOpen = false;

  Future<void> _openCollectFilterMenu() async {
    final collectBox =
        _collectTabKey.currentContext?.findRenderObject() as RenderBox?;
    final barBox = _tabsBarKey.currentContext?.findRenderObject() as RenderBox?;
    if (collectBox == null || barBox == null || !mounted) return;

    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final collectRight = collectBox.localToGlobal(
      collectBox.size.topRight(Offset.zero),
      ancestor: overlay,
    );
    final barBottom = barBox.localToGlobal(
      barBox.size.bottomLeft(Offset.zero),
      ancestor: overlay,
    );

    setState(() => _collectMenuOpen = true);
    widget.onTabChanged('collect');
    final selected = await showCollectFilterMenu(
      context: context,
      right: collectRight.dx,
      top: barBottom.dy + 9,
      currentSegment: widget.collectSegment,
    );
    if (!mounted) return;
    setState(() => _collectMenuOpen = false);

    if (selected != null) {
      widget.onTabChanged('collect');
      widget.onCollectSegmentChanged?.call(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = <({String id, String label})>[
      (id: 'pieces', label: 'Pieces'),
      (id: 'scenes', label: 'Scenes'),
      (id: 'series', label: 'Series'),
      if (widget.showCollect) (id: 'collect', label: 'Collect'),
    ];

    return ColoredBox(
      key: _tabsBarKey,
      color: kProfilePageBackground,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              kProfileHorizontalPad,
              24,
              kProfileHorizontalPad,
              0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final tab in tabs)
                  if (tab.id == 'collect')
                    _CollectTabItem(
                      key: _collectTabKey,
                      active: widget.currentTab == tab.id,
                      menuOpen: _collectMenuOpen,
                      onTabTap: () {
                        if (widget.currentTab == 'collect') {
                          _openCollectFilterMenu();
                        } else {
                          widget.onTabChanged(tab.id);
                        }
                      },
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
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ColoredBox(
              color: kProfileTabRule,
              child: SizedBox(height: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// Figma 2652:2859 — Collect filter list under the Collect tab.
Future<String?> showCollectFilterMenu({
  required BuildContext context,
  required double right,
  required double top,
  required String currentSegment,
}) {
  const menuWidth = 112.0;

  return showGeneralDialog<String>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Collect filter',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 140),
    pageBuilder: (context, animation, secondaryAnimation) {
      final screenWidth = MediaQuery.sizeOf(context).width;
      var left = right - menuWidth;
      left = left.clamp(10.0, screenWidth - menuWidth - 10.0);

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
              child: _CollectFilterMenu(
                currentSegment: currentSegment,
                onSelected: (value) => Navigator.pop(context, value),
              ),
            ),
          ),
        ],
      );
    },
  );
}

class _CollectFilterMenu extends StatelessWidget {
  const _CollectFilterMenu({
    required this.currentSegment,
    required this.onSelected,
  });

  final String currentSegment;
  final ValueChanged<String> onSelected;

  static const _options = [
    (id: 'all', label: 'All'),
    (id: 'available', label: 'Available'),
    (id: 'sold', label: 'Sold'),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: ColoredBox(
          color: kProfileCollectMenuFill,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < _options.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  _CollectFilterOption(
                    label: _options[i].label,
                    selected: currentSegment == _options[i].id,
                    onTap: () => onSelected(_options[i].id),
                  ),
                ],
              ],
            ),
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

  static const _dotAsset = 'assets/profile/icon_collect_dot_on.svg';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80,
        height: 20,
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.clip,
                textHeightBehavior: const TextHeightBehavior(
                  applyHeightToFirstAscent: false,
                  applyHeightToLastDescent: false,
                ),
                style: kProfileGeist(
                  fontSize: 12,
                  height: 1,
                  color: selected
                      ? HomeFeedTokens.textInverse
                      : kProfileTextDisabled,
                ),
              ),
            ),
            if (selected)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: SvgPicture.asset(_dotAsset, width: 4, height: 4),
              ),
          ],
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              label,
              style: kProfileGeist(
                fontSize: 13,
                fontWeight: active ? FontWeight.w500 : FontWeight.w400,
                color: active
                    ? HomeFeedTokens.textPrimary
                    : HomeFeedTokens.textSecondary,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: -0.5,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                height: 2,
                width: _indicatorWidth(label, active),
                decoration: BoxDecoration(
                  color: active
                      ? HomeFeedTokens.textPrimary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _indicatorWidth(String label, bool active) {
    if (!active) return 0;
    final painter = TextPainter(
      text: TextSpan(
        text: label,
        style: kProfileGeist(fontSize: 13, fontWeight: FontWeight.w500),
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
    required this.menuOpen,
    required this.onTabTap,
    required this.onFilterTap,
  });

  final bool active;
  final bool menuOpen;
  final VoidCallback onTabTap;
  final VoidCallback onFilterTap;

  static const _chevronAsset = 'assets/profile/icon_collect_chevron.svg';

  @override
  Widget build(BuildContext context) {
    final labelColor = active
        ? HomeFeedTokens.textPrimary
        : HomeFeedTokens.textSecondary;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: onTabTap,
                behavior: HitTestBehavior.opaque,
                child: Text(
                  'Collect',
                  style: kProfileGeist(
                    fontSize: 13,
                    fontWeight: active ? FontWeight.w500 : FontWeight.w400,
                    color: labelColor,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onFilterTap,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 4, 0, 4),
                  child: AnimatedRotation(
                    duration: const Duration(milliseconds: 160),
                    turns: menuOpen ? 0.5 : 0,
                    child: SvgPicture.asset(
                      _chevronAsset,
                      width: 8,
                      height: 4,
                      colorFilter: ColorFilter.mode(
                        labelColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: -0.5,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              height: 2,
              width: _collectIndicatorWidth(active),
              decoration: BoxDecoration(
                color: active ? HomeFeedTokens.textPrimary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
      ],
    );
  }

  double _collectIndicatorWidth(bool active) {
    if (!active) return 0;
    const chevronWidth = 12.0;
    final painter = TextPainter(
      text: TextSpan(
        text: 'Collect',
        style: kProfileGeist(fontSize: 13, fontWeight: FontWeight.w500),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    return painter.width + chevronWidth;
  }
}
