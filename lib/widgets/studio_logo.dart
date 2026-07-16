import 'package:flutter/material.dart';

/// Studio 3 logo asset paths.
abstract final class StudioLogoPaths {
  static const textBlack = 'assets/logo/logo_text_black.png';
  static const textWhite = 'assets/logo/logo_text_white.png';
  static const iconWhite = 'assets/logo/logo_icon_white.png';
  static const iconBlack = 'assets/logo/logo_icon_black.png';
}

/// Black wordmark for light app headers (home feed, etc.).
class StudioHeaderLogo extends StatelessWidget {
  const StudioHeaderLogo({super.key, this.height = 32});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      StudioLogoPaths.textBlack,
      height: height,
      fit: BoxFit.contain,
      alignment: Alignment.centerLeft,
    );
  }
}

/// White icon + wordmark stack for auth screens (login, signup, etc.).
class StudioAuthLogo extends StatelessWidget {
  const StudioAuthLogo({
    super.key,
    this.iconHeight = 64,
    this.textHeight = 40,
  });

  final double iconHeight;
  final double textHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          StudioLogoPaths.iconWhite,
          height: iconHeight,
          fit: BoxFit.contain,
        ),
        Image.asset(
          StudioLogoPaths.textWhite,
          height: textHeight,
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}
