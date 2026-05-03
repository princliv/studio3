import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/home_feed_dummy.dart';
import '../../../theme/home_feed_tokens.dart';
import '../profile_constants.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.name,
    required this.handle,
    required this.followingFollowers,
    required this.bioLine1,
    required this.bioLine2,
    required this.avatarSeed,
  });

  final String name;
  final String handle;
  final String followingFollowers;
  final String bioLine1;
  final String bioLine2;
  final int avatarSeed;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: HomeFeedTokens.background,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          kProfileHorizontalPad,
          18,
          kProfileHorizontalPad,
          12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _ProfileAvatar(seed: avatarSeed),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: HomeFeedTokens.textPrimary,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        handle,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: kProfileTextMuted,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const _StatBlock(value: '6', label: 'pieces'),
                const SizedBox(width: 10),
                const _StatBlock(value: '42', label: 'collected'),
                const SizedBox(width: 10),
                const _StatBlock(value: '1.2k', label: 'saves'),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              followingFollowers,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: kProfileTextMuted,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              bioLine1,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: HomeFeedTokens.textPrimary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              bioLine2,
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
            color: kProfileTextMuted,
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
