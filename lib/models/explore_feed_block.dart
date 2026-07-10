import '../models/feed_item.dart';

enum ExploreCategory { pieces, scenes, events }

enum ExploreTileRatio {
  portrait3x4,
  square1x1,
  landscape16x9;

  double get aspectValue {
    switch (this) {
      case ExploreTileRatio.portrait3x4:
        return 3 / 4;
      case ExploreTileRatio.square1x1:
        return 1;
      case ExploreTileRatio.landscape16x9:
        return 16 / 9;
    }
  }
}

class ExploreFeedTile {
  const ExploreFeedTile({
    required this.item,
    required this.ratio,
  });

  final FeedItem item;
  final ExploreTileRatio ratio;
}

sealed class ExploreFeedBlock {
  const ExploreFeedBlock();
}

class ExploreQuadBlock extends ExploreFeedBlock {
  const ExploreQuadBlock({
    required this.topLeft,
    required this.bottomLeft,
    required this.topRight,
    required this.bottomRight,
  });

  /// 3:4 — top of left column
  final ExploreFeedTile topLeft;

  /// 1:1 — bottom of left column
  final ExploreFeedTile bottomLeft;

  /// 1:1 — top of right column
  final ExploreFeedTile topRight;

  /// 3:4 — bottom of right column
  final ExploreFeedTile bottomRight;
}

class ExploreTwoUpBlock extends ExploreFeedBlock {
  const ExploreTwoUpBlock({
    required this.left,
    required this.right,
  });

  final ExploreFeedTile left;
  final ExploreFeedTile right;
}

class ExploreFullWidthBlock extends ExploreFeedBlock {
  const ExploreFullWidthBlock({required this.tile});

  final ExploreFeedTile tile;
}
