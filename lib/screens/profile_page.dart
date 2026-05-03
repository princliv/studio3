import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/home_feed_dummy.dart';
import '../theme/home_feed_tokens.dart';

const Color _kProfileTextMuted = Color(0xFF6B6560);
const double _kProfileGutter = 10;
const double _kProfileHorizontalPad = 12;

/// Artist profile — Studio 3 Discover mobile (Figma-aligned).
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  /// pieces | series | scenes | collect
  String _tab = 'pieces';

  static const _heroSeed = 901;
  static const _avatarSeed = 902;

  static const _name = 'Sarah Olson';
  static const _handle = '@sarahsunnyart';
  static const _followingFollowers = '100 following · 89 followers';
  static const _bioLine1 = 'Oil on canvas · Dallas, TX';
  static const _bioLine2 =
      'Figurative oil painter exploring memory, identity, and the in-between.';

  /// Left column: (seed, height).
  static const _leftMasonry = <({int seed, double h})>[
    (seed: 301, h: 292),
    (seed: 302, h: 168),
    (seed: 303, h: 174),
    (seed: 304, h: 318),
  ];

  /// Right column: (seed, height).
  static const _rightMasonry = <({int seed, double h})>[
    (seed: 311, h: 182),
    (seed: 312, h: 132),
    (seed: 313, h: 302),
    (seed: 314, h: 156),
    (seed: 315, h: 278),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final heroH = (width * 0.68).clamp(260.0, 340.0);
    final bottomPad = MediaQuery.paddingOf(context).bottom + 100;

    return Scaffold(
      backgroundColor: HomeFeedTokens.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              width: width,
              height: heroH,
              child: Image.network(
                picsumUrl(_heroSeed, 800, (heroH * 2).round()),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return ColoredBox(
                    color: Colors.grey.shade300,
                    child: Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: HomeFeedTokens.textPrimary.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => ColoredBox(
                  color: Colors.grey.shade400,
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    size: 48,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ColoredBox(
              color: HomeFeedTokens.background,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  _kProfileHorizontalPad,
                  18,
                  _kProfileHorizontalPad,
                  12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _ProfileAvatar(seed: _avatarSeed),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _name,
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: HomeFeedTokens.textPrimary,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _handle,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: _kProfileTextMuted,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatBlock(value: '6', label: 'pieces'),
                        const SizedBox(width: 10),
                        _StatBlock(value: '42', label: 'collected'),
                        const SizedBox(width: 10),
                        _StatBlock(value: '1.2k', label: 'saves'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _followingFollowers,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: _kProfileTextMuted,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _bioLine1,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: HomeFeedTokens.textPrimary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _bioLine2,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: HomeFeedTokens.textPrimary,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _FollowButton(onPressed: () {}),
                          const SizedBox(width: 10),
                          _MessageButton(onPressed: () {}),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ColoredBox(
              color: HomeFeedTokens.background,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  _kProfileHorizontalPad,
                  8,
                  _kProfileHorizontalPad,
                  0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: _ProfileTab(
                          label: 'Pieces',
                          active: _tab == 'pieces',
                          onTap: () => setState(() => _tab = 'pieces'),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: _ProfileTab(
                          label: 'Series',
                          active: _tab == 'series',
                          onTap: () => setState(() => _tab = 'series'),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: _ProfileTab(
                          label: 'Scenes',
                          active: _tab == 'scenes',
                          onTap: () => setState(() => _tab = 'scenes'),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: _ProfileTab(
                          label: 'Collect',
                          active: _tab == 'collect',
                          onTap: () => setState(() => _tab = 'collect'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ColoredBox(
              color: HomeFeedTokens.background,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: _kProfileHorizontalPad,
                  right: _kProfileHorizontalPad,
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
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(_kProfileHorizontalPad, 0, _kProfileHorizontalPad, bottomPad),
            sliver: SliverToBoxAdapter(
              child: _TabContent(
                tab: _tab,
                leftMasonry: _leftMasonry,
                rightMasonry: _rightMasonry,
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.seed});

  final int seed;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.network(
        picsumAvatarUrl(seed),
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 56,
          height: 56,
          color: Colors.grey.shade300,
          child: Icon(Icons.person_rounded, color: Colors.grey.shade600),
        ),
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: HomeFeedTokens.textPrimary,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: _kProfileTextMuted,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}

class _FollowButton extends StatelessWidget {
  const _FollowButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HomeFeedTokens.textPrimary,
      borderRadius: BorderRadius.circular(HomeFeedTokens.cardRadius),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(HomeFeedTokens.cardRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 28),
          child: Text(
            'Follow',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: HomeFeedTokens.textInverse,
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageButton extends StatelessWidget {
  const _MessageButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(HomeFeedTokens.cardRadius),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(HomeFeedTokens.cardRadius),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(HomeFeedTokens.cardRadius),
            border: Border.all(
              color: HomeFeedTokens.textPrimary.withValues(alpha: 0.35),
              width: 1,
            ),
            color: HomeFeedTokens.background,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 28),
            child: Text(
              'Message',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: HomeFeedTokens.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
                  color: active ? HomeFeedTokens.textPrimary : _kProfileTextMuted,
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
    );
  }
}

class _TabContent extends StatelessWidget {
  const _TabContent({
    required this.tab,
    required this.leftMasonry,
    required this.rightMasonry,
  });

  final String tab;
  final List<({int seed, double h})> leftMasonry;
  final List<({int seed, double h})> rightMasonry;

  @override
  Widget build(BuildContext context) {
    if (tab != 'pieces') {
      final message = switch (tab) {
        'series' => 'Series — coming soon',
        'scenes' => 'Scenes — coming soon',
        'collect' => 'Collect — coming soon',
        _ => 'Coming soon',
      };
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: _kProfileTextMuted,
            ),
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _MasonryColumn(items: leftMasonry),
        ),
        const SizedBox(width: _kProfileGutter),
        Expanded(
          child: _MasonryColumn(items: rightMasonry),
        ),
      ],
    );
  }
}

class _MasonryColumn extends StatelessWidget {
  const _MasonryColumn({required this.items});

  final List<({int seed, double h})> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: _kProfileGutter),
          _MasonryTile(seed: items[i].seed, height: items[i].h),
        ],
      ],
    );
  }
}

class _MasonryTile extends StatelessWidget {
  const _MasonryTile({required this.seed, required this.height});

  final int seed;
  final double height;

  @override
  Widget build(BuildContext context) {
    final hPx = (height * MediaQuery.devicePixelRatioOf(context)).round().clamp(200, 1200);
    return ClipRRect(
      borderRadius: BorderRadius.circular(HomeFeedTokens.cardRadius),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Image.network(
          picsumUrl(seed, 400, hPx),
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return ColoredBox(
              color: Colors.grey.shade300,
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => ColoredBox(
            color: Colors.grey.shade300,
            child: Icon(Icons.broken_image_outlined, color: Colors.grey.shade500),
          ),
        ),
      ),
    );
  }
}
