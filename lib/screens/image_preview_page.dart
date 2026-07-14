import 'package:flutter/material.dart';

import '../widgets/home_feed/home_feed_widgets.dart';

/// Full-screen pinch-to-zoom image viewer (Instagram-style preview).
class ImagePreviewPage extends StatefulWidget {
  const ImagePreviewPage({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  final List<String> imageUrls;
  final int initialIndex;

  @override
  State<ImagePreviewPage> createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewPage> {
  late final PageController _pageController;
  late double _page;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialIndex.clamp(0, widget.imageUrls.length - 1);
    _page = initial.toDouble();
    _pageController = PageController(initialPage: initial);
    _pageController.addListener(_onPageTick);
  }

  void _onPageTick() {
    final p = _pageController.page;
    if (p != null && mounted) setState(() => _page = p);
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageTick);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 1.0,
                maxScale: 4.0,
                child: FeedPicsumImage(
                  url: widget.imageUrls[index],
                  fit: BoxFit.contain,
                ),
              );
            },
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 8,
            left: 8,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
              color: Colors.white,
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.4),
              ),
            ),
          ),
          if (widget.imageUrls.length > 1)
            Positioned(
              bottom: MediaQuery.paddingOf(context).bottom + 16,
              left: 0,
              right: 0,
              child: Center(
                child: FeedDotIndicators(
                  count: widget.imageUrls.length,
                  page: _page,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
