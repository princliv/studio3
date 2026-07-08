import 'package:flutter/material.dart';

/// Vertical slide route: enters from bottom, exits upward on pop.
class SlideUpPageRoute<T> extends PageRouteBuilder<T> {
  SlideUpPageRoute({
    required this.page,
    super.settings,
    this.duration = const Duration(milliseconds: 400),
  }) : super(
          opaque: true,
          barrierColor: Colors.black,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                final offset = animation.status == AnimationStatus.reverse
                    ? Offset(0, animation.value - 1)
                    : Offset(0, 1 - animation.value);
                return Transform.translate(
                  offset: offset * MediaQuery.sizeOf(context).height,
                  child: child,
                );
              },
              child: child,
            );
          },
        );

  final Widget page;
  final Duration duration;
}
