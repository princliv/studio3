import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';



import '../../../models/piece_summary.dart';

import '../../../models/post_summary.dart';

import '../../../theme/home_feed_tokens.dart';

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

    this.collected = const [],

    this.sellerMode = false,

    this.loading = false,

    this.leftMasonry = const [],

    this.rightMasonry = const [],

  });



  final String currentTab;

  final List<ProfileSeriesData> seriesItems;

  final List<PieceSummary> pieces;

  final List<PostSummary> scenes;

  final List<PieceSummary> collected;

  final bool sellerMode;

  final bool loading;

  final List<({int seed, double h})> leftMasonry;

  final List<({int seed, double h})> rightMasonry;



  @override

  Widget build(BuildContext context) {

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

        return ProfileContentGrid.fromPosts(scenes);

      }

      return ProfileMasonryGrid(

        leftItems: leftMasonry,

        rightItems: rightMasonry,

      );

    }



    if (currentTab == 'collect') {

      if (!sellerMode) {

        return const _EmptyState(

          label: 'Switch to Seller to manage your collection',

        );

      }

      if (collected.isEmpty) {

        return const _EmptyState(label: 'No collected pieces yet');

      }

      return ProfileContentGrid.fromPieces(collected);

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


