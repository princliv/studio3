import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/profile_series_data.dart';
import '../profile_constants.dart';
import 'profile_masonry_grid.dart';
import 'profile_series_grid.dart';

class ProfileTabContent extends StatelessWidget {
  const ProfileTabContent({
    super.key,
    required this.currentTab,
    required this.leftMasonry,
    required this.rightMasonry,
    required this.seriesItems,
  });

  final String currentTab;
  final List<({int seed, double h})> leftMasonry;
  final List<({int seed, double h})> rightMasonry;
  final List<ProfileSeriesData> seriesItems;

  @override
  Widget build(BuildContext context) {
    if (currentTab == 'series') {
      return ProfileSeriesGrid(items: seriesItems);
    }

    if (currentTab == 'pieces' || currentTab == 'scenes') {
      return ProfileMasonryGrid(
        leftItems: leftMasonry,
        rightItems: rightMasonry,
      );
    }

    if (currentTab == 'collect') {
      return const _ComingSoon(label: 'Collect — coming soon');
    }

    return const _ComingSoon(label: 'Coming soon');
  }
}

class _ComingSoon extends StatelessWidget {
  const _ComingSoon({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Text(
          label,
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
