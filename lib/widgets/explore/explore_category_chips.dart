import 'package:flutter/material.dart';

import '../../models/explore_feed_block.dart';
import '../../theme/explore_tokens.dart';

class ExploreCategoryChips extends StatelessWidget {
  const ExploreCategoryChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final ExploreCategory selected;
  final ValueChanged<ExploreCategory> onSelected;

  static const _labels = {
    ExploreCategory.pieces: 'Pieces',
    ExploreCategory.scenes: 'Scenes',
    ExploreCategory.events: 'Events',
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: ExploreCategory.values.map((category) {
        final isSelected = category == selected;
        return Padding(
          padding: EdgeInsets.only(
            right: category != ExploreCategory.events ? 8 : 0,
          ),
          child: GestureDetector(
            onTap: () => onSelected(category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              height: ExploreTokens.chipHeight,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? ExploreTokens.chipActiveFill
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(ExploreTokens.chipRadius),
                border: Border.all(
                  color: ExploreTokens.chipBorder,
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                _labels[category]!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? ExploreTokens.textInverse
                      : ExploreTokens.textPrimary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
