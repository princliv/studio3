import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Artist profile (tab from bottom nav). Matches home app bar, then banner + bio + tabs.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const _artistName = 'Artist Name';
  static const _artistMeta = 'Oil · Mixed Media · Accra, Ghana';
  static const _bioFull =
      'Exploring the space between memory and material — layering oil glazes on raw linen to trace what the body holds and what it releases over time.';

  String _tab = 'posts';
  bool _bioExpanded = false;

  static const _readMoreBlue = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final bannerSize = width;

    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SafeArea(
            bottom: false,
            child: Container(
              color: Colors.white.withValues(alpha: 0.72),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: const Row(
                children: [
                  Text(
                    'Studio 3',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.slate900,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: bannerSize,
                    width: width,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _BannerBackground(width: width),
                        Positioned(
                          top: 12,
                          right: 16,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _FollowButton(onPressed: () {}),
                              const SizedBox(width: 10),
                              _InquireButton(onPressed: () {}),
                            ],
                          ),
                        ),
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 20,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: _AvatarFill(),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _artistName,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        height: 1.15,
                                        shadows: [
                                          Shadow(
                                            color: Color(0x66000000),
                                            blurRadius: 8,
                                            offset: Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _artistMeta,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white.withValues(alpha: 0.95),
                                        shadows: const [
                                          Shadow(
                                            color: Color(0x66000000),
                                            blurRadius: 6,
                                            offset: Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: ColoredBox(
                    color: AppColors.white,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _bioFull,
                            maxLines: _bioExpanded ? null : 3,
                            overflow: _bioExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.45,
                              color: AppColors.slate600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => setState(() => _bioExpanded = !_bioExpanded),
                            child: Text(
                              _bioExpanded ? 'Read less' : 'Read more',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: _readMoreBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    height: 1,
                    color: AppColors.slate200,
                  ),
                ),
                SliverToBoxAdapter(
                  child: ColoredBox(
                    color: AppColors.slate100,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      child: Row(
                        children: [
                          _ProfileTab(
                            label: 'Posts',
                            active: _tab == 'posts',
                            onTap: () => setState(() => _tab = 'posts'),
                          ),
                          _ProfileTab(
                            label: 'Process',
                            active: _tab == 'process',
                            onTap: () => setState(() => _tab = 'process'),
                          ),
                          _ProfileTab(
                            label: 'Collect',
                            active: _tab == 'collect',
                            onTap: () => setState(() => _tab = 'collect'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  sliver: SliverToBoxAdapter(
                    child: _TabBody(tab: _tab),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerBackground extends StatelessWidget {
  const _BannerBackground({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4A5568),
            Color(0xFF2D3748),
            Color(0xFF1A202C),
          ],
        ),
      ),
      child: Align(
        alignment: Alignment.center,
        child: Icon(
          Icons.image_outlined,
          size: width * 0.2,
          color: Colors.white.withValues(alpha: 0.12),
        ),
      ),
    );
  }
}

class _AvatarFill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.slate300,
      child: Icon(
        Icons.person_rounded,
        size: 40,
        color: Colors.white.withValues(alpha: 0.9),
      ),
    );
  }
}

class _FollowButton extends StatelessWidget {
  const _FollowButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Text(
            'Follow',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _InquireButton extends StatelessWidget {
  const _InquireButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white, width: 1.2),
          ),
          child: const Text(
            'Inquire',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
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
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? AppColors.slate900 : AppColors.slate500,
                ),
              ),
              if (active) ...[
                const SizedBox(height: 10),
                Container(
                  height: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: AppColors.slate900,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ] else
                const SizedBox(height: 13),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabBody extends StatelessWidget {
  const _TabBody({required this.tab});

  final String tab;

  @override
  Widget build(BuildContext context) {
    final label = switch (tab) {
      'posts' => 'Posts',
      'process' => 'Process',
      _ => 'Collect',
    };
    return LayoutBuilder(
      builder: (context, constraints) {
        final cell = (constraints.maxWidth - 8 * 2) / 3;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$label — coming soon',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.slate500,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                6,
                (i) => Container(
                  width: cell.clamp(0, double.infinity),
                  height: cell.clamp(0, double.infinity),
                  decoration: BoxDecoration(
                    color: AppColors.slate200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
