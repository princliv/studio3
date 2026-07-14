import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../theme/explore_tokens.dart';

class ExploreFeedImage extends StatelessWidget {
  const ExploreFeedImage({super.key, this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return const ColoredBox(color: ExploreTokens.skeleton);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final dpr = MediaQuery.devicePixelRatioOf(context);
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final cacheWidth = (maxWidth * dpr).round().clamp(1, 1200);
        return CachedNetworkImage(
          imageUrl: url!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          memCacheWidth: cacheWidth,
          fadeInDuration: const Duration(milliseconds: 280),
          placeholder: (context, url) =>
              const ColoredBox(color: ExploreTokens.skeleton),
          errorWidget: (context, error, stackTrace) =>
              const ColoredBox(color: ExploreTokens.skeleton),
        );
      },
    );
  }
}
