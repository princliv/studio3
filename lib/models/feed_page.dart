import 'feed_item.dart';

/// Cursor-paginated feed response from `/api/feed/*`.
class FeedPage {
  const FeedPage({
    required this.items,
    this.nextCursor,
    this.stub = false,
  });

  final List<FeedItem> items;
  final String? nextCursor;

  /// True when `/api/feed/for-you` is still an explore clone (not personalized).
  final bool stub;

  bool get hasMore => nextCursor != null && nextCursor!.isNotEmpty;
}
