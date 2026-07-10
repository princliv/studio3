import 'package:flutter/material.dart';

import '../data/home_feed_dummy.dart';

/// Circular profile photo with network URL or deterministic picsum fallback.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    this.url,
    required this.seed,
    required this.size,
  });

  final String? url;
  final int seed;
  final double size;

  @override
  Widget build(BuildContext context) {
    final image = url != null && url!.isNotEmpty
        ? Image.network(
            url!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _fallbackImage(),
          )
        : Image.network(
            picsumAvatarUrl(seed),
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _fallbackImage(),
          );

    return ClipOval(child: image);
  }

  Widget _fallbackImage() => Container(
        width: size,
        height: size,
        color: Colors.grey.shade300,
        child: Icon(
          Icons.person_rounded,
          color: Colors.grey.shade600,
          size: size * 0.5,
        ),
      );
}
