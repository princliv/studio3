import 'dart:math';

import '../data/home_feed_dummy.dart';
import '../models/feed_row.dart';

/// Produces shuffled A–E layout rows with dummy card data.
class FeedLayoutGenerator {
  FeedLayoutGenerator([int? seed]) : _random = Random(seed) {
    _reshuffle();
  }

  final Random _random;
  final List<FeedLayoutKind> _pool = [];
  int _poolIndex = 0;
  int _seedCounter = 1;

  void _reshuffle() {
    _pool
      ..clear()
      ..addAll(FeedLayoutKind.values)
      ..shuffle(_random);
    _poolIndex = 0;
  }

  FeedLayoutKind _nextKind() {
    if (_poolIndex >= _pool.length) {
      _reshuffle();
    }
    return _pool[_poolIndex++];
  }

  int _nextImageSeed() => _seedCounter++;

  FeedCardData _randomCard() {
    final artistIndex = _random.nextInt(kHomeFeedArtists.length);
    final mediumIndex = _random.nextInt(kHomeFeedMediums.length);
    final n = 1 + _random.nextInt(5); // 1–5 photos per post
    final seeds = List<int>.generate(n, (_) => _nextImageSeed());
    return FeedCardData(
      imageSeeds: seeds,
      artistIndex: artistIndex,
      mediumIndex: mediumIndex,
    );
  }

  FeedRowModel nextRow() {
    final kind = _nextKind();
    switch (kind) {
      case FeedLayoutKind.a:
      case FeedLayoutKind.d:
        return FeedRowModel(kind: kind, cards: [_randomCard()]);
      case FeedLayoutKind.e:
        return FeedRowModel(kind: kind, cards: [_randomCard()]);
      case FeedLayoutKind.b:
        return FeedRowModel(
          kind: kind,
          cards: [_randomCard(), _randomCard()],
        );
      case FeedLayoutKind.c:
        return FeedRowModel(
          kind: kind,
          cards: [_randomCard(), _randomCard(), _randomCard()],
        );
    }
  }

  List<FeedRowModel> nextBatch(int count) =>
      List<FeedRowModel>.generate(count, (_) => nextRow());
}
