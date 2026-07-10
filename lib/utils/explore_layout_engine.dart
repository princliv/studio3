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
    final cycleCap = maxCycles.clamp(0, ExploreLayoutEngine.maxCycles);
    if (items.length < tilesPerCycle || cycleCap == 0) return const [];

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

    return blocks;
  }

  static int cycleCountForItems(int itemCount) {
    if (itemCount < tilesPerCycle) return 0;
    final cycles = itemCount ~/ tilesPerCycle;
    return cycles > maxCycles ? maxCycles : cycles;
  }
}
