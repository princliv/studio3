import 'package:flutter/material.dart';

/// Bottom nav — neutral-950 surfaces (center pill + side circles).
/// Indices match [MainShell] / [_onNavTap].
abstract final class BottomNavIndex {
  static const int more = 0;
  static const int home = 1;
  static const int discover = 2;
  static const int post = 3;
  static const int bookmark = 4;
  static const int bell = 5;
  static const int profile = 6;
}

/// Dark floating pill / circles (spec ~#1A1A1A).
const Color _kNavSurface = Color(0xFF1A1A1A);

/// Side circles: match center pill height.
const double _kCircleSize = 60;
const double _kGap = 10;
const double _kIconSize = 28;
/// Center pill icons.
const double _kPillIconSize = 40;
const double _kPillIconHit = 56;
const double _kInactiveWhite = 0.4;

/// Center pill layout (background uses [_kNavSurface]).
const double _kCenterPillWidth = 256;
/// Fits [_kPillIconSize] with vertical padding.
const double _kCenterPillHeight = 60;
const double _kCenterPillRadius = 100;
const double _kCenterPillGap = 24;

class BottomNav extends StatelessWidget {
  const BottomNav({
    super.key,
    required this.selectedNavIndex,
    required this.onNavTap,
    this.avatar,
  });

  final int selectedNavIndex;
  final ValueChanged<int> onNavTap;
  final ImageProvider? avatar;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 12,
      right: 12,
      bottom: 16,
      child: SafeArea(
        top: false,
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _SideCircle(
                  selected: selectedNavIndex == BottomNavIndex.more,
                  onTap: () => onNavTap(BottomNavIndex.more),
                  child: Icon(
                    Icons.more_horiz_rounded,
                    size: _kIconSize,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: _kGap),
                _CenterPill(
                  selectedNavIndex: selectedNavIndex,
                  onNavTap: onNavTap,
                ),
                const SizedBox(width: _kGap),
                _SideCircle(
                  selected: selectedNavIndex == BottomNavIndex.profile,
                  onTap: () => onNavTap(BottomNavIndex.profile),
                  child: avatar != null
                      ? ClipOval(
                          child: Image(
                            image: avatar!,
                            width: _kCircleSize,
                            height: _kCircleSize,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          Icons.person_outline_rounded,
                          size: _kIconSize,
                          color: selectedNavIndex == BottomNavIndex.profile
                              ? Colors.white
                              : Colors.white.withValues(alpha: _kInactiveWhite),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SideCircle extends StatelessWidget {
  const _SideCircle({
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? Colors.white.withValues(alpha: 0.4)
        : Colors.white.withValues(alpha: 0.14);
    final double borderWidth = selected ? 1.5 : 1.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: ClipOval(
          child: Container(
            width: _kCircleSize,
            height: _kCircleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _kNavSurface,
              border: Border.all(color: borderColor, width: borderWidth),
            ),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

class _CenterPill extends StatelessWidget {
  const _CenterPill({
    required this.selectedNavIndex,
    required this.onNavTap,
  });

  final int selectedNavIndex;
  final ValueChanged<int> onNavTap;

  static const _slots = <({int index, IconData outline, IconData filled})>[
    (index: BottomNavIndex.home, outline: Icons.home_outlined, filled: Icons.home_rounded),
    (index: BottomNavIndex.discover, outline: Icons.explore_outlined, filled: Icons.explore_rounded),
    (index: BottomNavIndex.post, outline: Icons.add, filled: Icons.add),
    (index: BottomNavIndex.bookmark, outline: Icons.bookmark_border_rounded, filled: Icons.bookmark_rounded),
    (index: BottomNavIndex.bell, outline: Icons.notifications_outlined, filled: Icons.notifications_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_kCenterPillRadius),
      child: Container(
        width: _kCenterPillWidth,
        height: _kCenterPillHeight,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        color: _kNavSurface,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < _slots.length; i++) ...[
                if (i > 0) const SizedBox(width: _kCenterPillGap),
                _PillIconButton(
                  selected: selectedNavIndex == _slots[i].index,
                  outline: _slots[i].outline,
                  filled: _slots[i].filled,
                  onTap: () => onNavTap(_slots[i].index),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PillIconButton extends StatelessWidget {
  const _PillIconButton({
    required this.selected,
    required this.outline,
    required this.filled,
    required this.onTap,
  });

  final bool selected;
  final IconData outline;
  final IconData filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = selected ? filled : outline;
    final color =
        selected ? Colors.white : Colors.white.withValues(alpha: _kInactiveWhite);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: _kPillIconHit,
          height: _kPillIconHit,
          child: Icon(
            icon,
            size: _kPillIconSize,
            color: color,
            applyTextScaling: false,
          ),
        ),
      ),
    );
  }
}
