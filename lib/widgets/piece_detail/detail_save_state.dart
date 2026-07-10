import 'package:flutter/material.dart';

import '../../models/feed_preview_item.dart';
import '../../services/saved_content_store.dart';

/// Shared save-state wiring for piece detail pages.
mixin DetailSaveState<T extends StatefulWidget> on State<T> {
  final SavedContentStore savedStore = SavedContentStore.instance;
  bool saved = false;

  FeedPreviewItem get saveItem;

  @override
  void initState() {
    super.initState();
    saved = savedStore.isSaved(saveItem.id);
    savedStore.addListener(onSavedStoreChanged);
  }

  @override
  void dispose() {
    savedStore.removeListener(onSavedStoreChanged);
    super.dispose();
  }

  void onSavedStoreChanged() {
    final nextSaved = savedStore.isSaved(saveItem.id);
    if (nextSaved != saved && mounted) {
      setState(() => saved = nextSaved);
    }
  }

  void toggleSave() {
    if (saved) {
      savedStore.unsave(saveItem.id);
    } else {
      savedStore.savePreview(saveItem);
    }
  }
}
