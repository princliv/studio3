import 'package:flutter/material.dart';

import '../models/feed_item.dart';
import '../models/feed_preview_item.dart';
import '../screens/available_piece_detail_page.dart';
import '../screens/piece_detail_page.dart';
import 'slide_up_page_route.dart';

Future<void> openExploreDetail(BuildContext context, FeedItem item) {
  final preview = FeedPreviewItem.fromFeedItem(item);
  final page = preview.isAvailable
      ? AvailablePieceDetailPage(item: preview)
      : PieceDetailPage(item: preview);

  return Navigator.of(context).push<void>(
    SlideUpPageRoute<void>(page: page),
  );
}
