import 'package:flutter/material.dart';

import '../../models/explore_feed_block.dart';
import '../../theme/explore_tokens.dart';
import 'explore_category_chips.dart';
import 'explore_search_bar.dart';

class ExploreStickyHeader extends SliverPersistentHeaderDelegate {
  ExploreStickyHeader({
    required this.searchController,
    required this.onSearchChanged,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.onFilterTap,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final ExploreCategory selectedCategory;
  final ValueChanged<ExploreCategory> onCategorySelected;
  final VoidCallback? onFilterTap;

  static double get headerHeight => ExploreTokens.stickyHeaderHeight;

  @override
  double get minExtent => headerHeight;

  @override
  double get maxExtent => headerHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(
      height: headerHeight,
      child: ColoredBox(
        color: ExploreTokens.background,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            ExploreTokens.sideMargin,
            ExploreTokens.stickyHeaderTopPadding,
            ExploreTokens.sideMargin,
            ExploreTokens.stickyHeaderBottomPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ExploreSearchBar(
                controller: searchController,
                onChanged: onSearchChanged,
                onFilterTap: onFilterTap,
              ),
              const SizedBox(height: ExploreTokens.stickyHeaderSectionGap),
              ExploreCategoryChips(
                selected: selectedCategory,
                onSelected: onCategorySelected,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant ExploreStickyHeader oldDelegate) {
    return oldDelegate.selectedCategory != selectedCategory;
  }
}
