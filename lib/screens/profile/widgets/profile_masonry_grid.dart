import 'package:flutter/material.dart';
import '../../../data/home_feed_dummy.dart';
import '../../../theme/home_feed_tokens.dart';
import '../profile_constants.dart';

class ProfileMasonryGrid extends StatelessWidget {
  const ProfileMasonryGrid({
    super.key,
    required this.leftItems,
    required this.rightItems,
  });

  final List<({int seed, double h})> leftItems;
  final List<({int seed, double h})> rightItems;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _MasonryColumn(items: leftItems),
        ),
        const SizedBox(width: kProfileGutter),
        Expanded(
          child: _MasonryColumn(items: rightItems),
        ),
      ],
    );
  }
}

class _MasonryColumn extends StatelessWidget {
  const _MasonryColumn({required this.items});

  final List<({int seed, double h})> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: kProfileGutter),
          _MasonryTile(seed: items[i].seed, height: items[i].h),
        ],
      ],
    );
  }
}

class _MasonryTile extends StatelessWidget {
  const _MasonryTile({required this.seed, required this.height});

  final int seed;
  final double height;

  @override
  Widget build(BuildContext context) {
    final hPx = (height * MediaQuery.devicePixelRatioOf(context)).round().clamp(200, 1200);
    return ClipRRect(
      borderRadius: BorderRadius.circular(HomeFeedTokens.cardRadius),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Image.network(
          picsumUrl(seed, 400, hPx),
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return ColoredBox(
              color: Colors.grey.shade300,
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => ColoredBox(
            color: Colors.grey.shade300,
            child: Icon(Icons.broken_image_outlined, color: Colors.grey.shade500),
          ),
        ),
      ),
    );
  }
}
