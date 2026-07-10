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

    return Image.network(
      url!,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return AnimatedOpacity(
            opacity: 1,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOut,
            child: child,
          );
        }
        return const ColoredBox(color: ExploreTokens.skeleton);
      },
      errorBuilder: (context, error, stackTrace) =>
          const ColoredBox(color: ExploreTokens.skeleton),
    );
  }
}
