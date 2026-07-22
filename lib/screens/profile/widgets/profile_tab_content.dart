import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import '../../../models/piece_summary.dart';
import '../../../models/post_summary.dart';
import '../../../widgets/feed_skeleton.dart';
import '../../../widgets/pill_chip.dart';
import '../profile_constants.dart';
import 'profile_masonry_grid.dart';
import 'profile_series_grid.dart';
import '../models/profile_series_data.dart';

bool _isVideoPost(PostSummary p) {
  final m = p.mediaType?.toLowerCase();
  return m == 'video' || m == 'reel' || m == 'reels';
}

class ProfileTabContent extends StatelessWidget {
  const ProfileTabContent({
    super.key,
    required this.currentTab,
    required this.seriesItems,
    this.pieces = const [],
    this.scenes = const [],
    this.listedPieces = const [],
    this.collectSegment = 'available',
    this.sellerMode = false,
    this.loading = false,
    this.isOwnProfile = false,
    this.onDeletePiece,
    this.onDeleteScene,
    this.sceneFilter = 'all',
    this.onSceneFilterChanged,
  });

  final String currentTab;
  final List<ProfileSeriesData> seriesItems;
  final List<PieceSummary> pieces;
  final List<PostSummary> scenes;
  final List<PieceSummary> listedPieces;
  final String collectSegment;
  final bool sellerMode;
  final bool loading;
  final bool isOwnProfile;
  final void Function(PieceSummary piece)? onDeletePiece;
  final void Function(PostSummary post)? onDeleteScene;
  final String sceneFilter;
  final ValueChanged<String>? onSceneFilterChanged;

  @override
  Widget build(BuildContext context) {
    if (loading &&
        (currentTab == 'pieces'
            ? pieces.isEmpty
            : currentTab == 'scenes'
                ? scenes.isEmpty
                : currentTab == 'collect'
                    ? listedPieces.isEmpty
                    : currentTab == 'series'
                        ? seriesItems.isEmpty
                        : true)) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: ProfileGridSkeleton(),
      );
    }

    if (currentTab == 'series') {
      return ProfileSeriesGrid(items: seriesItems, loading: loading);
    }

    if (currentTab == 'pieces') {
      if (pieces.isNotEmpty) {
        return ProfileContentGrid.fromPieces(
          pieces,
          onPieceTap: (piece) => openProfilePiece(context, piece),
          onDeletePiece: onDeletePiece,
          showOwnerActions: isOwnProfile,
        );
      }
      return const _EmptyState(label: 'No pieces yet');
    }

    if (currentTab == 'scenes') {
      final visibleScenes =
          sceneFilter == 'videos' ? scenes.where(_isVideoPost).toList() : scenes;
      final grid = visibleScenes.isNotEmpty
          ? ProfileContentGrid.fromPosts(
              visibleScenes,
              onPostTap: (post) => openProfileScene(context, visibleScenes, post),
              onDeletePost: onDeleteScene,
              showOwnerActions: isOwnProfile,
            )
          : _EmptyState(
              label: sceneFilter == 'videos' ? 'No videos yet' : 'No scenes yet',
            );
      if (scenes.isEmpty) return grid;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                PillChip(
                  label: 'All',
                  selected: sceneFilter != 'videos',
                  onTap: () => onSceneFilterChanged?.call('all'),
                ),
                const SizedBox(width: 8),
                PillChip(
                  label: 'Videos',
                  selected: sceneFilter == 'videos',
                  onTap: () => onSceneFilterChanged?.call('videos'),
                ),
              ],
            ),
          ),
          grid,
        ],
      );
    }

    if (currentTab == 'collect') {
      if (!sellerMode) {
        return const _EmptyState(
          label: 'Switch to Seller to list pieces for sale',
        );
      }

      if (collectSegment == 'sold') {
        return const _EmptyState(label: 'No sold pieces yet');
      }

      final available = listedPieces.where((p) => p.isForSale).toList();
      if (available.isEmpty) {
        return const _EmptyState(label: 'No pieces listed for sale yet');
      }

      return ProfileContentGrid.fromPieces(
        available,
        forSaleListing: true,
        onPieceTap: (piece) => openProfilePiece(context, piece),
      );
    }

    return const _EmptyState(label: 'Coming soon');
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: kProfileTextMuted,
          ),
        ),
      ),
    );
  }
}
