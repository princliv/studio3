import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/feed_preview_item.dart';
import '../screens/available_piece_detail_page.dart';
import '../screens/piece_detail_page.dart';
import '../services/saved_content_store.dart';
import '../theme/home_feed_tokens.dart';
import '../utils/reels_route.dart';
import '../widgets/home_feed/home_feed_widgets.dart';

class SavedPage extends StatefulWidget {
  const SavedPage({super.key});

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  final _store = SavedContentStore.instance;
  SavedContentFilter _filter = SavedContentFilter.all;

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() => setState(() {});

  void _openEntry(SavedEntry entry) {
    if (entry.isVideoScene && entry.feedItem != null) {
      final videoItems = _store.videoSceneFeedItems;
      final index = videoItems.indexWhere((item) => item.id == entry.id);
      openReels(
        context,
        initialIndex: index >= 0 ? index : 0,
        items: videoItems,
      );
      return;
    }

    final preview = entry.preview;
    if (preview != null) {
      final page = preview.isAvailable
          ? AvailablePieceDetailPage(item: preview)
          : PieceDetailPage(item: preview);
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => page,
        ),
      );
    }
  }

  Future<void> _confirmUnsave(SavedEntry entry) async {
    final remove = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: HomeFeedTokens.detailBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.bookmark_remove_outlined),
                title: Text(
                  'Remove from saved',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: HomeFeedTokens.textPrimary,
                  ),
                ),
                onTap: () => Navigator.pop(context, true),
              ),
            ],
          ),
        ),
      ),
    );
    if (remove == true) {
      _store.unsave(entry.id);
    }
  }

  String _emptyMessage() {
    switch (_filter) {
      case SavedContentFilter.all:
        return 'Saved pieces and scenes will appear here';
      case SavedContentFilter.piece:
        return 'No saved pieces yet';
      case SavedContentFilter.scene:
        return 'No saved scenes yet';
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _store.entries(filter: _filter);

    return Scaffold(
      backgroundColor: HomeFeedTokens.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                'Saved',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: HomeFeedTokens.textPrimary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FeedFilterTab(
                    label: 'All',
                    active: _filter == SavedContentFilter.all,
                    onTap: () =>
                        setState(() => _filter = SavedContentFilter.all),
                  ),
                  const SizedBox(width: 24),
                  FeedFilterTab(
                    label: 'Piece',
                    active: _filter == SavedContentFilter.piece,
                    onTap: () =>
                        setState(() => _filter = SavedContentFilter.piece),
                  ),
                  const SizedBox(width: 24),
                  FeedFilterTab(
                    label: 'Scene',
                    active: _filter == SavedContentFilter.scene,
                    onTap: () =>
                        setState(() => _filter = SavedContentFilter.scene),
                  ),
                ],
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Text(
                        _emptyMessage(),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: HomeFeedTokens.textSecondary,
                        ),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 120),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                        childAspectRatio: 1,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final entry = items[index];
                        return _SavedGridCard(
                          entry: entry,
                          onTap: () => _openEntry(entry),
                          onLongPress: () => _confirmUnsave(entry),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedGridCard extends StatelessWidget {
  const _SavedGridCard({
    required this.entry,
    required this.onTap,
    required this.onLongPress,
  });

  final SavedEntry entry;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  String? get _imageUrl {
    final preview = entry.preview;
    if (preview != null) {
      return preview.heroImageUrl ?? feedPreviewImageUrl(preview);
    }
    return entry.feedItem?.mediaUrl;
  }

  @override
  Widget build(BuildContext context) {
    final isVideo = entry.isVideoScene;
    final imageUrl = _imageUrl;

    return Material(
      color: HomeFeedTokens.textPrimary.withValues(alpha: 0.06),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl != null && imageUrl.isNotEmpty)
              FeedPicsumImage(url: imageUrl)
            else
              ColoredBox(
                color: HomeFeedTokens.textPrimary.withValues(alpha: 0.08),
                child: Icon(
                  Icons.image_outlined,
                  color: HomeFeedTokens.textSecondary.withValues(alpha: 0.7),
                  size: 28,
                ),
              ),
            if (isVideo) ...[
              ColoredBox(
                color: Colors.black.withValues(alpha: 0.28),
              ),
              const Center(
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
