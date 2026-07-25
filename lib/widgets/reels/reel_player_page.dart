import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
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

  /// Android Impeller + texture-backed video often produces green macroblock
  /// tearing on MediaTek/Mali devices. Platform views avoid that path.
  static VideoViewType get _viewType {
    if (kIsWeb) return VideoViewType.textureView;
    return Platform.isAndroid
        ? VideoViewType.platformView
        : VideoViewType.textureView;
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
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(url),
      formatHint: VideoFormat.mp4,
      viewType: _viewType,
    );
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
            // Explicit cover layout (not FittedBox scale) so Android platform
            // views fill the frame correctly without texture-transform glitches.
            LayoutBuilder(
              builder: (context, constraints) {
                final size = _controller!.value.size;
                final videoAspect =
                    size.width == 0 ? 9 / 16 : size.width / size.height;
                final frameAspect =
                    constraints.maxWidth / constraints.maxHeight;
                late final double width;
                late final double height;
                if (videoAspect > frameAspect) {
                  height = constraints.maxHeight;
                  width = height * videoAspect;
                } else {
                  width = constraints.maxWidth;
                  height = width / videoAspect;
                }
                return SizedBox.expand(
                  child: ClipRect(
                    child: Center(
                      child: SizedBox(
                        width: width,
                        height: height,
                        child: VideoPlayer(_controller!),
                      ),
                    ),
                  ),
                );
              },
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
