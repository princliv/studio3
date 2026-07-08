import 'feed_preview_item.dart';

/// Result returned when detail page pops after scrolling past Related Scenes.
class FeedPopResult {
  const FeedPopResult({
    required this.nextIndex,
    required this.filter,
  });

  final int nextIndex;
  final FeedAvailabilityFilter filter;
}
