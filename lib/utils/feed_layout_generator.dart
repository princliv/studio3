import 'dart:math';

import '../data/home_feed_dummy.dart';
import '../models/feed_preview_item.dart';

/// Produces feed items with portrait 3:4 or landscape 16:9 aspect ratios.
class FeedLayoutGenerator {
  FeedLayoutGenerator([int? seed]) : _random = Random(seed);

  final Random _random;
  int _idCounter = 1;
  int _seedCounter = 1;

  int _nextImageSeed() => _seedCounter++;

  FeedPreviewItem nextItem() {
    final artistIndex = _random.nextInt(kHomeFeedArtists.length);
    final artist = kHomeFeedArtists[artistIndex];
    final mediumIndex = _random.nextInt(kHomeFeedMediums.length);
    final titleIndex = _random.nextInt(kFeedPieceTitles.length);
    final storyIndex = _random.nextInt(kFeedStories.length);
    final dimIndex = _random.nextInt(kFeedDimensions.length);
    final seriesIndex = _random.nextInt(kFeedSeriesNames.length);
    final isPortrait = _random.nextBool();
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

    final isAvailable = _random.nextBool();
    final priceCents = isAvailable
        ? (80000 + _random.nextInt(1120000))
        : null;
    const shippingRegions = [
      'Ships from Dallas, TX',
      'Ships from Brooklyn, NY',
      'Ships from Los Angeles, CA',
      'Ships from Chicago, IL',
    ];
    final framingNotes = [
      'Floated in natural wood frame',
      'Gallery wrapped, ready to hang',
      'Unframed on stretched canvas',
    ];
    final provenanceNotes = [
      'Acquired directly from the artist',
      'Exhibited at Studio 3 Discover 2024',
      'From a private collection in Austin, TX',
    ];

    return FeedPreviewItem(
      id: 'feed_${_idCounter++}',
      imageSeeds: seeds,
      artistIndex: artistIndex,
      title: kFeedPieceTitles[titleIndex],
      medium: kHomeFeedMediums[mediumIndex],
      year: 2023 + _random.nextInt(3),
      dimensions: kFeedDimensions[dimIndex],
      story: kFeedStories[storyIndex],
      handle: artistHandle(artist),
      isAvailable: isAvailable,
      priceCents: priceCents,
      shippingRegion: isAvailable
          ? shippingRegions[_random.nextInt(shippingRegions.length)]
          : null,
      framingNote: isAvailable
          ? framingNotes[_random.nextInt(framingNotes.length)]
          : null,
      provenanceNote: isAvailable
          ? provenanceNotes[_random.nextInt(provenanceNotes.length)]
          : null,
      aspectRatio: isPortrait
          ? FeedAspectRatio.portrait3x4
          : FeedAspectRatio.landscape16x9,
      seriesName: kFeedSeriesNames[seriesIndex],
      seriesThumbs: seriesThumbs,
      relatedScenes: relatedScenes,
    );
  }

  List<FeedPreviewItem> nextBatch(int count) =>
      List<FeedPreviewItem>.generate(count, (_) => nextItem());
}
