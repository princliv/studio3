import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/feed_preview_item.dart';

String buildPieceShareText(FeedPreviewItem item, {int imageIndex = 0}) {
  final imageUrl =
      item.heroImageUrl ?? feedPreviewImageUrl(item, imageIndex: imageIndex);
  final lines = <String>[
    '${item.title} by ${item.displayName} on Studio',
    if (item.story.trim().isNotEmpty) item.story,
    imageUrl,
  ];
  return lines.join('\n\n');
}

Future<void> shareFeedPreviewItem(
  BuildContext context,
  FeedPreviewItem item, {
  int imageIndex = 0,
}) async {
  await Clipboard.setData(
    ClipboardData(text: buildPieceShareText(item, imageIndex: imageIndex)),
  );
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Link copied')),
  );
}
