import 'package:flutter/material.dart';

/// Circular profile photo with network URL or Instagram-style empty placeholder.
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

  static const _emptyBackground = Color(0xFFEFEFEF);
  static const _emptyIconColor = Color(0xFF9E9E9E);

  bool get _hasUrl => url != null && url!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final child = _hasUrl
        ? Image.network(
            url!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _emptyAvatar(),
          )
        : _emptyAvatar();

    return ClipOval(child: child);
  }

  Widget _emptyAvatar() => Container(
        width: size,
        height: size,
        color: _emptyBackground,
        alignment: Alignment.center,
        child: Icon(
          Icons.person_rounded,
          color: _emptyIconColor,
          size: size * 0.52,
        ),
      );
}
