import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/home_feed_tokens.dart';

/// A label + bordered dropdown matching the plain `_Field` input style used
/// on `edit_profile_page.dart`, for the small enum settings (visibility,
/// message permission, banner rule).
class LabeledDropdown extends StatelessWidget {
  const LabeledDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;

  /// (value, display label) pairs.
  final List<(String, String)> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: HomeFeedTokens.textPrimary.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: HomeFeedTokens.textPrimary,
          ),
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: HomeFeedTokens.textPrimary.withValues(alpha: 0.15),
              ),
            ),
          ),
          items: [
            for (final option in options)
              DropdownMenuItem(value: option.$1, child: Text(option.$2)),
          ],
          onChanged: (next) {
            if (next != null) onChanged(next);
          },
        ),
      ],
    );
  }
}
