import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../models/feed_item.dart';
import 'reel_overlay.dart';

class ReelPlayerPage extends StatefulWidget {
  const ReelPlayerPage({
    super.key,
    required this.item,
    required this.isActive,
    this.bottomOverlayPadding = 96,
  });

  final FeedItem item;
  final bool isActive;
  final double bottomOverlayPadding;

  @override
  State<ReelPlayerPage> createState() => _ReelPlayerPageState();
}

class _ReelPlayerPageState extends State<ReelPlayerPage> {
  VideoPlayerController? _controller;
  bool _initializing = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      _initController();
    }
  }

  @override
  void didUpdateWidget(covariant ReelPlayerPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _initController();
    } else if (!widget.isActive && oldWidget.isActive) {
      _disposeController();
    }
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  Future<void> _initController() async {
    final url = widget.item.mediaUrl;
    if (url == null || url.isEmpty) {
      setState(() => _failed = true);
      return;
    }
    if (_controller != null || _initializing) return;
    setState(() {
      _initializing = true;
      _failed = false;
    });
    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(1);
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _initializing = false;
      });
      if (widget.isActive) {
        await controller.play();
      }
    } catch (_) {
      await controller.dispose();
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _failed = true;
      });
    }
  }

  void _disposeController() {
    _controller?.pause();
    _controller?.dispose();
    _controller = null;
    _initializing = false;
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_controller != null && _controller!.value.isInitialized)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.size.width,
                height: _controller!.value.size.height,
                child: VideoPlayer(_controller!),
              ),
            )
          else if (_failed)
            const Center(
              child: Icon(Icons.videocam_off_outlined,
                  color: Colors.white54, size: 48),
            )
          else
            const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          ReelOverlay(
            item: widget.item,
            bottomPadding: widget.bottomOverlayPadding,
          ),
        ],
      ),
    );
  }
}
