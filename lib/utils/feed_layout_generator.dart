import 'dart:math';

import '../data/home_feed_dummy.dart';
import '../models/feed_item.dart';

/// Produces feed items with portrait 3:4 or landscape 16:9 aspect ratios.
class FeedLayoutGenerator {
  FeedLayoutGenerator([int? seed]) : _random = Random(seed);

  final Random _random;
  int _idCounter = 1;
  int _seedCounter = 1;

  int _nextImageSeed() => _seedCounter++;

  FeedItem nextItem() {
    final artistIndex = _random.nextInt(kHomeFeedArtists.length);
    final artist = kHomeFeedArtists[artistIndex];
    final mediumIndex = _random.nextInt(kHomeFeedMediums.length);
    final titleIndex = _random.nextInt(kFeedPieceTitles.length);
    final storyIndex = _random.nextInt(kFeedStories.length);
    final dimIndex = _random.nextInt(kFeedDimensions.length);
    final seriesIndex = _random.nextInt(kFeedSeriesNames.length);
    final isPortrait = _random.nextBool();
    final isProcess = !isPortrait && _random.nextDouble() < 0.3;
    final n = 1 + _random.nextInt(4);
    final seeds = List<int>.generate(n, (_) => _nextImageSeed());
    final seriesCount = 3 + _random.nextInt(3);
    final seriesThumbs = List<int>.generate(
      seriesCount,
      (_) => _nextImageSeed(),
    );
    final sceneCount = 1 + _random.nextInt(3);
    final relatedScenes = List<RelatedScene>.generate(sceneCount, (i) {
      final durations = ['1:03', '0:53', '2:14', null];
      return RelatedScene(
        imageSeed: _nextImageSeed(),
        duration: durations[_random.nextInt(durations.length)],
      );
    });

    return FeedItem(
      id: 'feed_${_idCounter++}',
      imageSeeds: seeds,
      artistIndex: artistIndex,
      title: kFeedPieceTitles[titleIndex],
      medium: kHomeFeedMediums[mediumIndex],
      year: 2023 + _random.nextInt(3),
      dimensions: kFeedDimensions[dimIndex],
      story: kFeedStories[storyIndex],
      handle: artistHandle(artist),
      isAvailable: _random.nextBool(),
      aspectRatio: isPortrait
          ? FeedAspectRatio.portrait3x4
          : FeedAspectRatio.landscape16x9,
      isProcess: isProcess,
      seriesName: kFeedSeriesNames[seriesIndex],
      seriesThumbs: seriesThumbs,
      relatedScenes: relatedScenes,
    );
  }

  List<FeedItem> nextBatch(int count) =>
      List<FeedItem>.generate(count, (_) => nextItem());
}
