import 'package:flutter/material.dart';

import '../../models/feed_preview_item.dart';
import '../home_feed/home_feed_widgets.dart';

/// Hero image for detail pages — matches feed aspect ratio and carousel index.
class DetailHeroImage extends StatefulWidget {
  const DetailHeroImage({
    super.key,
    required this.item,
    this.initialImageIndex = 0,
  });

  final FeedPreviewItem item;
  final int initialImageIndex;

  @override
  State<DetailHeroImage> createState() => _DetailHeroImageState();
}

class _DetailHeroImageState extends State<DetailHeroImage> {
  late final PageController? _pageController;

  FeedPreviewItem get item => widget.item;

  @override
  void initState() {
    super.initState();
    final heroUrl = item.heroImageUrl;
    final useCarousel =
        (heroUrl == null || heroUrl.isEmpty) && item.imageCount > 1;
    _pageController = useCarousel
        ? PageController(initialPage: widget.initialImageIndex.clamp(
            0,
            item.imageCount - 1,
          ))
        : null;
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final heroUrl = item.heroImageUrl;
    if (heroUrl != null && heroUrl.isNotEmpty) {
      return FeedPicsumImage(url: heroUrl);
    }

    if (item.imageCount > 1 && _pageController != null) {
      return PageView.builder(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        itemCount: item.imageCount,
        itemBuilder: (context, index) {
          return FeedPicsumImage(
            url: feedPreviewImageUrl(item, imageIndex: index),
          );
        },
      );
    }

    return FeedPicsumImage(
      url: feedPreviewImageUrl(
        item,
        imageIndex: widget.initialImageIndex,
      ),
    );
  }
}
