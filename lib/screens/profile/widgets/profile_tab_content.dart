import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import '../../../models/piece_summary.dart';
import '../../../models/post_summary.dart';
import '../../../theme/home_feed_tokens.dart';
import '../../../widgets/feed_skeleton.dart';
import '../profile_constants.dart';
import 'profile_masonry_grid.dart';
import 'profile_series_grid.dart';
import '../models/profile_series_data.dart';

class ProfileTabContent extends StatelessWidget {
  const ProfileTabContent({
    super.key,
    required this.currentTab,
    required this.seriesItems,
    this.pieces = const [],
    this.scenes = const [],
    this.listedPieces = const [],
    this.collectSegment = 'available',
    this.onCollectSegmentChanged,
    this.sellerMode = false,
    this.loading = false,
    this.leftMasonry = const [],
    this.rightMasonry = const [],
  });

  final String currentTab;
  final List<ProfileSeriesData> seriesItems;
  final List<PieceSummary> pieces;
  final List<PostSummary> scenes;
  final List<PieceSummary> listedPieces;
  final String collectSegment;
  final ValueChanged<String>? onCollectSegmentChanged;
  final bool sellerMode;
  final bool loading;
  final List<({int seed, double h})> leftMasonry;
  final List<({int seed, double h})> rightMasonry;

  @override
  Widget build(BuildContext context) {
    if (loading &&
        currentTab != 'series' &&
        (currentTab == 'pieces'
            ? pieces.isEmpty
            : currentTab == 'scenes'
                ? scenes.isEmpty
                : currentTab == 'collect'
                    ? listedPieces.isEmpty
                    : true)) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: ProfileGridSkeleton(),
      );
    }

    if (currentTab == 'series') {
      return ProfileSeriesGrid(items: seriesItems);
    }

    if (currentTab == 'pieces') {
      if (pieces.isNotEmpty) {
        return ProfileContentGrid.fromPieces(pieces);
      }
      return ProfileMasonryGrid(
        leftItems: leftMasonry,
        rightItems: rightMasonry,
      );
    }

    if (currentTab == 'scenes') {
      if (scenes.isNotEmpty) {
        return ProfileContentGrid.fromPosts(
          scenes,
          onPostTap: (post) => openProfileScene(context, scenes, post),
        );
      }
      return ProfileMasonryGrid(
        leftItems: leftMasonry,
        rightItems: rightMasonry,
      );
    }

    if (currentTab == 'collect') {
      if (!sellerMode) {
        return const _EmptyState(
          label: 'Switch to Seller to list pieces for sale',
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CollectSegmentControl(
            segment: collectSegment,
            onChanged: onCollectSegmentChanged,
          ),
          const SizedBox(height: 12),
          if (collectSegment == 'sold')
            const _EmptyState(label: 'No sold pieces yet')
          else if (listedPieces.where((p) => p.isForSale).isEmpty)
            const _EmptyState(label: 'No pieces listed for sale yet')
          else
            ProfileContentGrid.fromPieces(
              listedPieces.where((p) => p.isForSale).toList(),
            ),
        ],
      );
    }

    return const _EmptyState(label: 'Coming soon');
  }
}

class _CollectSegmentControl extends StatelessWidget {
  const _CollectSegmentControl({
    required this.segment,
    this.onChanged,
  });

  final String segment;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SegmentChip(
          label: 'Available',
          selected: segment == 'available',
          onTap: () => onChanged?.call('available'),
        ),
        const SizedBox(width: 8),
        _SegmentChip(
          label: 'Sold',
          selected: segment == 'sold',
          onTap: () => onChanged?.call('sold'),
        ),
      ],
    );
  }
}

class _SegmentChip extends StatelessWidget {
  const _SegmentChip({
    required this.label,
    required this.selected,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? HomeFeedTokens.textPrimary
              : HomeFeedTokens.textPrimary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: selected
                ? HomeFeedTokens.textInverse
                : HomeFeedTokens.textPrimary,
          ),
        ),
      ),
    );
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
