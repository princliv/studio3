import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Light glass card — for forms, overlays on light bg
class GlassCard extends StatelessWidget {
  const GlassCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDims.radiusLg),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding ?? const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.72),
            borderRadius: BorderRadius.circular(AppDims.radiusLg),
            border: Border.all(color: Colors.white.withOpacity(0.45)),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Dark glass strip — overlays on images
class GlassDark extends StatelessWidget {
  const GlassDark({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDims.radiusMd),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.slate900.withOpacity(0.55),
            borderRadius: BorderRadius.circular(AppDims.radiusMd),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: child,
        ),
      ),
    );
  }
}
