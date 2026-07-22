import '../models/explore_feed_block.dart';
import '../models/feed_item.dart';

/// Maps explore items into repeating cycles:
/// | 3:4 | 1:1 |
/// | 1:1 | 3:4 |
/// |     16:9     |
class ExploreLayoutEngine {
  static const tilesPerCycle = 5;
  static const maxCycles = 10;

  static const _quadSlots = <ExploreTileRatio>[
    ExploreTileRatio.portrait3x4,
    ExploreTileRatio.square1x1,
    ExploreTileRatio.square1x1,
    ExploreTileRatio.portrait3x4,
  ];

  static List<ExploreFeedBlock> buildBlocks(
    List<FeedItem> items, {
    int maxCycles = 2,
  }) {
    if (items.isEmpty) return const [];
    final cycleCap = maxCycles.clamp(0, ExploreLayoutEngine.maxCycles);

    final blocks = <ExploreFeedBlock>[];
    var index = 0;
    var cycles = 0;

    while (cycles < cycleCap && index + tilesPerCycle <= items.length) {
      blocks.add(
        ExploreQuadBlock(
          topLeft: ExploreFeedTile(
            item: items[index],
            ratio: _quadSlots[0],
          ),
          topRight: ExploreFeedTile(
            item: items[index + 1],
            ratio: _quadSlots[1],
          ),
          bottomLeft: ExploreFeedTile(
            item: items[index + 2],
            ratio: _quadSlots[2],
          ),
          bottomRight: ExploreFeedTile(
            item: items[index + 3],
            ratio: _quadSlots[3],
          ),
        ),
      );
      blocks.add(
        ExploreFullWidthBlock(
          tile: ExploreFeedTile(
            item: items[index + 4],
            ratio: ExploreTileRatio.landscape16x9,
          ),
        ),
      );
      index += tilesPerCycle;
      cycles++;
    }

    // Leftover items that can't form another full cycle (as opposed to a
    // full cycle simply being held back by `cycleCap` for progressive
    // reveal) used to be silently dropped, which made the whole section
    // read as empty whenever fewer than `tilesPerCycle` items were
    // available. Render them in a smaller layout instead.
    final remainder = items.length - index;
    if (remainder > 0 && remainder < tilesPerCycle) {
      blocks.addAll(_buildRemainderBlocks(items.sublist(index)));
    }

    return blocks;
  }

  static List<ExploreFeedBlock> _buildRemainderBlocks(List<FeedItem> rest) {
    ExploreFeedTile squareTile(FeedItem item) =>
        ExploreFeedTile(item: item, ratio: ExploreTileRatio.square1x1);
    ExploreFeedTile wideTile(FeedItem item) => ExploreFeedTile(
          item: item,
          ratio: ExploreTileRatio.landscape16x9,
        );

    switch (rest.length) {
      case 1:
        return [ExploreFullWidthBlock(tile: wideTile(rest[0]))];
      case 2:
        return [
          ExploreTwoUpBlock(
            left: squareTile(rest[0]),
            right: squareTile(rest[1]),
          ),
        ];
      case 3:
        return [
          ExploreTwoUpBlock(
            left: squareTile(rest[0]),
            right: squareTile(rest[1]),
          ),
          ExploreFullWidthBlock(tile: wideTile(rest[2])),
        ];
      case 4:
        return [
          ExploreQuadBlock(
            topLeft: ExploreFeedTile(item: rest[0], ratio: _quadSlots[0]),
            topRight: ExploreFeedTile(item: rest[1], ratio: _quadSlots[1]),
            bottomLeft: ExploreFeedTile(item: rest[2], ratio: _quadSlots[2]),
            bottomRight: ExploreFeedTile(item: rest[3], ratio: _quadSlots[3]),
          ),
        ];
      default:
        return const [];
    }
  }

  static int cycleCountForItems(int itemCount) {
    if (itemCount < tilesPerCycle) return 0;
    final cycles = itemCount ~/ tilesPerCycle;
    return cycles > maxCycles ? maxCycles : cycles;
  }
}
