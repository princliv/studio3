import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/home_feed_tokens.dart';
import 'glass_card.dart';
import 'studio_loading.dart';

/// Shows a centered, non-dismissible "Uploading…" card that blocks the
/// screen until [hideUploadingDialog] is called. Callers must always pair
/// this with a `finally` block that hides it, on success or error alike.
Future<void> showUploadingDialog(
  BuildContext context, {
  String message = 'Uploading…',
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: (context) => PopScope(
      canPop: false,
      child: Center(
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const StudioLoadingAnimation(iconSize: 44),
              const SizedBox(height: 16),
              Text(
                message,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: HomeFeedTokens.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Dismisses a dialog previously shown by [showUploadingDialog].
void hideUploadingDialog(BuildContext context) {
  Navigator.of(context, rootNavigator: true).pop();
}
