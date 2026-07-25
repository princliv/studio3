import 'package:flutter/foundation.dart';

import '../models/feed_preview_item.dart';
import 'saved_content_store.dart';

/// In-memory overrides for like/save so optimistic UI is not clobbered by
/// stale piece/post caches (the "heart disappears then comes back" bug).
class EngagementStore extends ChangeNotifier {
  EngagementStore._();
  static final EngagementStore instance = EngagementStore._();

  final Map<String, bool> _liked = {};
  final Map<String, bool> _saved = {};
  final Map<String, int> _likeCounts = {};

  bool? likedOverride(String id) => _liked[id];

  bool? savedOverride(String id) => _saved[id];

  int? likeCountOverride(String id) => _likeCounts[id];

  bool resolveLiked(String id, bool fallback) => _liked[id] ?? fallback;

  bool resolveSaved(String id, bool fallback) => _saved[id] ?? fallback;

  int resolveLikeCount(String id, int fallback) => _likeCounts[id] ?? fallback;

  void setLiked(String id, bool value, {int? likeCount}) {
    var changed = false;
    if (_liked[id] != value) {
      _liked[id] = value;
      changed = true;
    }
    if (likeCount != null && _likeCounts[id] != likeCount) {
      _likeCounts[id] = likeCount;
      changed = true;
    }
    if (changed) notifyListeners();
  }

  void setLikeCount(String id, int value) {
    if (_likeCounts[id] == value) return;
    _likeCounts[id] = value;
    notifyListeners();
  }

  void setSaved(String id, bool value) {
    if (_saved[id] == value) return;
    _saved[id] = value;
    notifyListeners();
  }

  /// Merge local overrides (and SavedContentStore) onto a freshly loaded item.
  FeedPreviewItem applyToPreview(FeedPreviewItem item) {
    final savedLocal = SavedContentStore.instance.isSaved(item.id);
    return item.copyWith(
      isLiked: resolveLiked(item.id, item.isLiked),
      isSaved: resolveSaved(item.id, item.isSaved || savedLocal),
      likeCount: resolveLikeCount(item.id, item.likeCount),
    );
  }

  void clear() {
    if (_liked.isEmpty && _saved.isEmpty && _likeCounts.isEmpty) return;
    _liked.clear();
    _saved.clear();
    _likeCounts.clear();
    notifyListeners();
  }
}
