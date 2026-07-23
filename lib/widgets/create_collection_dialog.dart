import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/home_feed_tokens.dart';

/// Prompt for a new saved-collection name. Returns trimmed name or null if
/// cancelled.
class CreateCollectionDialog extends StatefulWidget {
  const CreateCollectionDialog({
    super.key,
    this.title = 'New collection',
  });

  final String title;

  static Future<String?> show(
    BuildContext context, {
    String title = 'New collection',
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) => CreateCollectionDialog(title: title),
    );
  }

  @override
  State<CreateCollectionDialog> createState() =>
      _CreateCollectionDialogState();
}

class _CreateCollectionDialogState extends State<CreateCollectionDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    Navigator.pop(context, name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: HomeFeedTokens.background,
      title: Text(
        widget.title,
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: HomeFeedTokens.textPrimary,
        ),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          hintText: 'Collection name',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: GoogleFonts.inter(color: HomeFeedTokens.textSecondary),
          ),
        ),
        TextButton(
          onPressed: _submit,
          child: Text(
            'Create',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: HomeFeedTokens.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
