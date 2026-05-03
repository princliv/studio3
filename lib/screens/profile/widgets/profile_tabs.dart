import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/home_feed_tokens.dart';
import '../profile_constants.dart';

class ProfileTabs extends StatelessWidget {
  const ProfileTabs({
    super.key,
    required this.currentTab,
    required this.onTabChanged,
  });

  final String currentTab;
  final ValueChanged<String> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ColoredBox(
          color: HomeFeedTokens.background,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              kProfileHorizontalPad,
              8,
              kProfileHorizontalPad,
              0,
            ),
            child: Row(
              children: [
                _TabItem(
                  label: 'Pieces',
                  active: currentTab == 'pieces',
                  onTap: () => onTabChanged('pieces'),
                ),
                _TabItem(
                  label: 'Series',
                  active: currentTab == 'series',
                  onTap: () => onTabChanged('series'),
                ),
                _TabItem(
                  label: 'Scenes',
                  active: currentTab == 'scenes',
                  onTap: () => onTabChanged('scenes'),
                ),
                _TabItem(
                  label: 'Collect',
                  active: currentTab == 'collect',
                  onTap: () => onTabChanged('collect'),
                ),
              ],
            ),
          ),
        ),
        ColoredBox(
          color: HomeFeedTokens.background,
          child: Padding(
            padding: const EdgeInsets.only(
              left: kProfileHorizontalPad,
              right: kProfileHorizontalPad,
              top: 4,
              bottom: 12,
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
      child: Center(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 10),
            child: IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                      color: active ? HomeFeedTokens.textPrimary : kProfileTextMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    height: 2,
                    decoration: BoxDecoration(
                      color: active ? HomeFeedTokens.textPrimary : Colors.transparent,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
