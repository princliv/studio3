import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/feed_preview_item.dart';

Future<void> shareFeedPreviewItem(
  BuildContext context,
  FeedPreviewItem item, {
  int imageIndex = 0,
}) async {
  final imageUrl =
      item.heroImageUrl ?? feedPreviewImageUrl(item, imageIndex: imageIndex);
  final lines = <String>[
    '${item.title} by ${item.artist.name} on Studio',
    if (item.story.trim().isNotEmpty) item.story,
    imageUrl,
  ];
  await Clipboard.setData(ClipboardData(text: lines.join('\n\n')));
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Link copied')),
  );
}
