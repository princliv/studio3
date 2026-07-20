import 'package:flutter/material.dart';

import '../../models/feed_preview_item.dart';
import '../../services/saved_content_store.dart';
import '../../services/social_service.dart';

/// Shared save-state wiring for piece detail pages.
mixin DetailSaveState<T extends StatefulWidget> on State<T> {
  final SavedContentStore savedStore = SavedContentStore.instance;
  bool saved = false;
  bool _saveBusy = false;
  bool _ownStoreWrite = false;

  FeedPreviewItem get saveItem;

  @override
  void initState() {
    super.initState();
    saved = saveItem.isApiBacked
        ? saveItem.isSaved
        : savedStore.isSaved(saveItem.id);
    savedStore.addListener(onSavedStoreChanged);
  }

  @override
  void dispose() {
    savedStore.removeListener(onSavedStoreChanged);
    super.dispose();
  }

  void applySaveItem(FeedPreviewItem item) {
    if (!mounted) return;
    setState(() {
      saved = item.isApiBacked ? item.isSaved : savedStore.isSaved(item.id);
    });
  }

  void onSavedStoreChanged() {
    if (_ownStoreWrite) return;
    final nextSaved = saveItem.isApiBacked
        ? saveItem.isSaved
        : savedStore.isSaved(saveItem.id);
    if (nextSaved != saved && mounted) {
      setState(() => saved = nextSaved);
    }
  }

  Future<void> toggleSave() async {
    if (_saveBusy) return;
    final item = saveItem;
    final nextSaved = !saved;
    setState(() => saved = nextSaved);
    if (!item.isApiBacked) {
      if (nextSaved) {
        savedStore.savePreview(item);
      } else {
        savedStore.unsave(item.id);
      }
      return;
    }

    _saveBusy = true;
    try {
      if (nextSaved) {
        if (item.isScene) {
          await SocialService.instance.savePost(item.id);
        } else {
          await SocialService.instance.savePiece(item.id);
        }
        _ownStoreWrite = true;
        savedStore.savePreview(item);
        _ownStoreWrite = false;
      } else {
        if (item.isScene) {
          await SocialService.instance.unsavePost(item.id);
        } else {
          await SocialService.instance.unsavePiece(item.id);
        }
        _ownStoreWrite = true;
        savedStore.unsave(item.id);
        _ownStoreWrite = false;
      }
    } catch (_) {
      if (mounted) setState(() => saved = !nextSaved);
    } finally {
      _saveBusy = false;
    }
  }
}

/// Like toggle for API-backed piece/scene detail pages.
mixin DetailLikeState<T extends StatefulWidget> on State<T> {
  bool liked = false;
  bool _likeBusy = false;

  FeedPreviewItem get likeItem;

  void applyLikeItem(FeedPreviewItem item) {
    if (!mounted) return;
    setState(() => liked = item.isLiked);
  }

  Future<void> toggleLike() async {
    if (_likeBusy) return;
    final item = likeItem;
    if (!item.isApiBacked) {
      setState(() => liked = !liked);
      return;
    }

    final nextLiked = !liked;
    setState(() => liked = nextLiked);
    _likeBusy = true;
    try {
      if (item.isScene) {
        if (nextLiked) {
          await SocialService.instance.likePost(item.id);
        } else {
          await SocialService.instance.unlikePost(item.id);
        }
      } else {
        if (nextLiked) {
          await SocialService.instance.likePiece(item.id);
        } else {
          await SocialService.instance.unlikePiece(item.id);
        }
      }
    } catch (_) {
      if (mounted) setState(() => liked = !nextLiked);
    } finally {
      _likeBusy = false;
    }
  }
}
