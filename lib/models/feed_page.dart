import 'feed_item.dart';

/// Cursor-paginated feed response from `/api/feed/*`.
class FeedPage {
  const FeedPage({
    required this.items,
    this.nextCursor,
  });

  final List<FeedItem> items;
  final String? nextCursor;

  bool get hasMore => nextCursor != null && nextCursor!.isNotEmpty;
}
