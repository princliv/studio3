import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/feed_item.dart';
import '../models/feed_preview_item.dart';
import '../models/post_summary.dart';
import 'cache_service.dart';

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

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.name,
        if (preview != null) 'preview': preview!.toJson(),
        if (feedItem != null) 'feedItem': feedItem!.toJson(),
      };

  factory SavedEntry.fromJson(Map<String, dynamic> json) {
    final feedItemJson = json['feedItem'] as Map<String, dynamic>?;
    return SavedEntry(
      id: json['id'] as String? ?? '',
      kind: json['kind'] == 'piece'
          ? SavedContentKind.piece
          : SavedContentKind.scene,
      preview: json['preview'] != null
          ? FeedPreviewItem.fromCacheJson(json['preview'] as Map<String, dynamic>)
          : null,
      feedItem: feedItemJson != null ? FeedItem.fromJson(feedItemJson) : null,
    );
  }
}

/// Local store for pieces and scenes saved from For You and scene videos.
/// Persisted to disk (via [CacheService]) so saved items survive app
/// restarts instead of living only in memory.
class SavedContentStore extends ChangeNotifier {
  SavedContentStore._();
  static final SavedContentStore instance = SavedContentStore._();

  static const _storageKey = 'saved_content.entries';

  final Map<String, SavedEntry> _entries = {};

  /// Restores previously saved entries from disk. Call once at startup,
  /// before any screen that reads from this store builds.
  Future<void> load() async {
    final raw = CacheService.instance.readRaw(_storageKey);
    if (raw == null) return;
    try {
      final list = jsonDecode(raw) as List;
      for (final e in list) {
        final entry = SavedEntry.fromJson(e as Map<String, dynamic>);
        if (entry.id.isNotEmpty) _entries[entry.id] = entry;
      }
      notifyListeners();
    } catch (_) {
      // Corrupt/old-format cache entry — ignore and start empty rather
      // than crash the app on startup.
    }
  }

  Future<void> _persist() => CacheService.instance.writeRaw(
        _storageKey,
        jsonEncode(_entries.values.map((e) => e.toJson()).toList()),
      );

  /// Clears saved items on logout so a second account on the same device
  /// never sees the previous account's saved list.
  Future<void> clearLocal() async {
    _entries.clear();
    await CacheService.instance.invalidate(_storageKey);
    notifyListeners();
  }

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
    unawaited(_persist());
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
    unawaited(_persist());
  }

  void unsave(String id) {
    if (_entries.remove(id) != null) {
      notifyListeners();
      unawaited(_persist());
    }
  }
}
