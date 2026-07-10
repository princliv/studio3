import 'package:flutter/material.dart';

/// Profile cover banner — network URL or bundled art default.
class ProfileCoverImage extends StatelessWidget {
  const ProfileCoverImage({
    super.key,
    this.url,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.topCenter,
  });

  static const defaultAsset = 'assets/profile/default_cover.jpg';

  final String? url;
  final double width;
  final double height;
  final BoxFit fit;
  final Alignment alignment;

  bool get _hasUrl => url != null && url!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: _hasUrl ? _networkImage() : _defaultImage(),
    );
  }

  Widget _networkImage() {
    return Image.network(
      url!,
      fit: fit,
      alignment: alignment,
      width: width,
      height: height,
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) => _defaultImage(),
    );
  }

  Widget _defaultImage() {
    return Image.asset(
      defaultAsset,
      fit: fit,
      alignment: alignment,
      width: width,
      height: height,
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) => ColoredBox(
        color: Colors.grey.shade300,
        child: Icon(
          Icons.palette_outlined,
          size: 48,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}
