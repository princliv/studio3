import 'package:flutter/material.dart';

import '../theme/home_feed_tokens.dart';
import 'profile_avatar.dart';
import 'profile_cover_image.dart';

/// Instagram/Facebook-style edit-profile header: a full-bleed cover photo
/// with the avatar overlapping its bottom edge, each with a tappable camera
/// badge to trigger the photo picker. Purely presentational — callers own
/// the actual upload flow via [onChangeCover]/[onChangeAvatar].
class ProfileEditHeader extends StatelessWidget {
  const ProfileEditHeader({
    super.key,
    required this.coverUrl,
    required this.avatarUrl,
    required this.onChangeCover,
    required this.onChangeAvatar,
  });

  final String? coverUrl;
  final String? avatarUrl;
  final VoidCallback onChangeCover;
  final VoidCallback onChangeAvatar;

  static const _coverHeight = 180.0;
  static const _avatarSize = 88.0;
  static const _avatarRing = 4.0;
  static const _avatarOuter = _avatarSize + _avatarRing * 2;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return SizedBox(
      height: _coverHeight + _avatarOuter / 2,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              child: ProfileCoverImage(
                url: coverUrl,
                width: width,
                height: _coverHeight,
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: _avatarOuter / 2 + 12,
            child: _EditBadge(
              icon: Icons.camera_alt_rounded,
              onTap: onChangeCover,
              size: 36,
              background: Colors.black.withValues(alpha: 0.45),
            ),
          ),
          Positioned(
            left: 20,
            bottom: 0,
            child: GestureDetector(
              onTap: onChangeAvatar,
              child: Container(
                padding: const EdgeInsets.all(_avatarRing),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: HomeFeedTokens.background,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ProfileAvatar(url: avatarUrl, size: _avatarSize),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: _EditBadge(
                        icon: Icons.camera_alt_rounded,
                        onTap: onChangeAvatar,
                        size: 28,
                        border: Border.all(
                          color: HomeFeedTokens.background,
                          width: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditBadge extends StatelessWidget {
  const _EditBadge({
    required this.icon,
    required this.onTap,
    required this.size,
    this.background,
    this.border,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final Color? background;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: border,
      ),
      child: Material(
        color: background ?? HomeFeedTokens.textPrimary,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(
              icon,
              size: size * 0.55,
              color: HomeFeedTokens.textInverse,
            ),
          ),
        ),
      ),
    );
  }
}
