import 'feed_item.dart';

/// Cursor-paginated comments from piece/scene comment endpoints.
class CommentPage {
  const CommentPage({
    required this.items,
    this.nextCursor,
  });

  final List<CommentSummary> items;
  final String? nextCursor;

  bool get hasMore => nextCursor != null && nextCursor!.isNotEmpty;
}
