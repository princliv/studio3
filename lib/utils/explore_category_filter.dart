import '../models/explore_feed_block.dart';
import '../models/feed_item.dart';
List<FeedItem> filterExploreItems(
  List<FeedItem> items,
  ExploreCategory category,
) {
  switch (category) {
    case ExploreCategory.all:
      return items;
    case ExploreCategory.pieces:
      return items
          .where(
            (item) => item.type == FeedItemType.piece && !item.isVideo,
          )
          .toList();
    case ExploreCategory.scenes:
      return items
          .where(
            (item) => item.type == FeedItemType.post || item.isVideo,
          )
          .toList();
  }
}
