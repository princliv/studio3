import 'package:flutter/material.dart';

import '../models/feed_item.dart';
import '../screens/reels_page.dart';
import '../services/feed_service.dart';

Future<void> openReels(
  BuildContext context, {
  int initialIndex = 0,
  List<FeedItem>? items,
}) async {
  List<FeedItem> reelsItems = items ?? const [];
  if (reelsItems.isEmpty) {
    reelsItems = await FeedService.instance.getVideoScenes();
  }

  var index = initialIndex;
  if (index < 0 || index >= reelsItems.length) {
    index = 0;
  }

  if (!context.mounted) return;
  await Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => ReelsPage(
        initialIndex: index,
        initialItems: reelsItems,
      ),
    ),
  );
}

Future<void> openReelsForItem(BuildContext context, FeedItem item) async {
  final reelsItems = await FeedService.instance.getVideoScenes();
  if (!context.mounted) return;
  final index = reelsItems.indexWhere((entry) => entry.id == item.id);
  await openReels(
    context,
    initialIndex: index >= 0 ? index : 0,
    items: reelsItems,
  );
}

Future<void> openReelsForPosts(
  BuildContext context,
  List<FeedItem> posts,
  FeedItem item,
) async {
  final videoPosts = posts
      .where((entry) => entry.type == FeedItemType.post && entry.isVideo)
      .toList();
  if (videoPosts.isEmpty) {
    await openReelsForItem(context, item);
    return;
  }
  if (!context.mounted) return;
  final index = videoPosts.indexWhere((entry) => entry.id == item.id);
  await openReels(
    context,
    initialIndex: index >= 0 ? index : 0,
    items: videoPosts,
  );
}
