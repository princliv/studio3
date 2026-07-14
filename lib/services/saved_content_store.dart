import 'package:flutter/foundation.dart';

import '../models/feed_item.dart';
import '../models/feed_preview_item.dart';
import '../models/post_summary.dart';

enum SavedContentKind { piece, scene }

enum SavedContentFilter { all, piece, scene }

class SavedEntry {
  const SavedEntry({
    required this.id,
    required this.kind,
    this.preview,
    this.feedItem,
  });

  final String id;
  final SavedContentKind kind;
  final FeedPreviewItem? preview;
  final FeedItem? feedItem;

  String get title =>
      preview?.title ?? feedItem?.title ?? feedItem?.post?.caption ?? 'Saved';

  String get authorName =>
      preview?.displayName ?? feedItem?.authorName ?? 'Artist';

  bool get isVideoScene =>
      feedItem?.isVideo == true || preview?.medium == 'Video';
}

/// Local store for pieces and scenes saved from For You and scene videos.
class SavedContentStore extends ChangeNotifier {
  SavedContentStore._();
  static final SavedContentStore instance = SavedContentStore._();

  final Map<String, SavedEntry> _entries = {};

  bool isSaved(String id) => _entries.containsKey(id);

  List<SavedEntry> entries({SavedContentFilter filter = SavedContentFilter.all}) {
    final all = _entries.values.toList(growable: false);
    switch (filter) {
      case SavedContentFilter.all:
        return all;
      case SavedContentFilter.piece:
        return all
            .where((entry) => entry.kind == SavedContentKind.piece)
            .toList(growable: false);
      case SavedContentFilter.scene:
        return all
            .where((entry) => entry.kind == SavedContentKind.scene)
            .toList(growable: false);
    }
  }

  List<FeedItem> get videoSceneFeedItems => _entries.values
      .where((entry) =>
          entry.kind == SavedContentKind.scene &&
          entry.feedItem != null &&
          entry.feedItem!.isVideo)
      .map((entry) => entry.feedItem!)
      .toList(growable: false);

  void savePreview(FeedPreviewItem item) {
    final kind =
        item.isScene ? SavedContentKind.scene : SavedContentKind.piece;
    FeedItem? feedItem;
    if (item.isScene && item.medium == 'Video') {
      feedItem = FeedItem.post(
        PostSummary(
          id: item.id,
          caption: item.title,
          mediaUrl: item.heroImageUrl,
          mediaType: 'video',
          authorName: item.displayName,
          authorAvatarUrl: item.authorAvatarUrl,
          authorUsername: item.handle.replaceFirst('@', ''),
        ),
      );
    }
    _entries[item.id] = SavedEntry(
      id: item.id,
      kind: kind,
      preview: item,
      feedItem: feedItem,
    );
    notifyListeners();
  }

  void saveFeedItem(FeedItem item) {
    FeedPreviewItem? preview;
    if (item.type == FeedItemType.post) {
      preview = FeedPreviewItem.fromFeedItem(item);
    }
    _entries[item.id] = SavedEntry(
      id: item.id,
      kind: SavedContentKind.scene,
      preview: preview,
      feedItem: item,
    );
    notifyListeners();
  }

  void unsave(String id) {
    if (_entries.remove(id) != null) {
      notifyListeners();
    }
  }
}
