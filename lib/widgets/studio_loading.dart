import 'package:flutter/material.dart';

import '../theme/home_feed_tokens.dart';
import 'studio_logo.dart';

/// Blinking logo icon + three-dot wave — Studio 3 global loading indicator.
class StudioLoadingAnimation extends StatefulWidget {
  const StudioLoadingAnimation({
    super.key,
    this.iconSize = 56,
    this.dotColor,
  });

  final double iconSize;
  final Color? dotColor;

  @override
  State<StudioLoadingAnimation> createState() => _StudioLoadingAnimationState();
}

class _StudioLoadingAnimationState extends State<StudioLoadingAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _blinkController;
  late final Animation<double> _blinkAnimation;
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _blinkAnimation = Tween<double>(begin: 0.22, end: 1.0).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _blinkController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dotColor = widget.dotColor ?? HomeFeedTokens.textPrimary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FadeTransition(
          opacity: _blinkAnimation,
          child: Image.asset(
            StudioLogoPaths.iconBlack,
            width: widget.iconSize,
            height: widget.iconSize,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 20),
        AnimatedBuilder(
          animation: _waveController,
          builder: (context, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                final phase = (_waveController.value + index * 0.2) % 1.0;
                final lift = (phase < 0.5 ? phase * 2 : (1 - phase) * 2);
                final opacity = 0.35 + lift * 0.65;
                return Padding(
                  padding: EdgeInsets.only(left: index == 0 ? 0 : 8),
                  child: Transform.translate(
                    offset: Offset(0, -lift * 6),
                    child: Opacity(
                      opacity: opacity,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }
}

/// Full-screen loading layer with centered Studio loading animation.
class StudioLoadingOverlay extends StatelessWidget {
  const StudioLoadingOverlay({
    super.key,
    this.backgroundColor,
    this.dotColor,
  });

  final Color? backgroundColor;
  final Color? dotColor;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor ?? HomeFeedTokens.background,
      child: Center(
        child: StudioLoadingAnimation(dotColor: dotColor),
      ),
    );
  }
}

/// Dark variant for auth screens.
class StudioLoadingOverlayDark extends StatelessWidget {
  const StudioLoadingOverlayDark({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFF000000),
      child: Center(
        child: StudioLoadingAnimation(
          dotColor: Color(0xFFFFFFFF),
        ),
      ),
    );
  }
}

/// When [loading] is true, covers the entire page with [StudioLoadingOverlay].
class StudioLoadingGate extends StatelessWidget {
  const StudioLoadingGate({
    super.key,
    required this.loading,
    required this.child,
    this.dark = false,
    this.backgroundColor,
  });

  final bool loading;
  final Widget child;
  final bool dark;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (loading)
          Positioned.fill(
            child: dark
                ? const StudioLoadingOverlayDark()
                : StudioLoadingOverlay(backgroundColor: backgroundColor),
          ),
      ],
    );
  }
}
