import 'package:flutter/material.dart';

import '../../theme/explore_tokens.dart';

class ExploreSearchBar extends StatelessWidget {
  const ExploreSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onFilterTap,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ExploreTokens.searchHeight,
      decoration: BoxDecoration(
        color: ExploreTokens.searchFill,
        borderRadius: BorderRadius.circular(ExploreTokens.searchRadius),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.search,
            size: 22,
            color: ExploreTokens.textSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              maxLines: 1,
              textAlignVertical: TextAlignVertical.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.2,
                color: ExploreTokens.textPrimary,
              ),
              decoration: const InputDecoration(
                isDense: true,
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                hintText: 'Search artists, pieces, genres',
                hintStyle: TextStyle(
                  fontSize: 14,
                  height: 1.2,
                  color: ExploreTokens.textSecondary,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: onFilterTap,
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.tune,
                size: 22,
                color: ExploreTokens.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
