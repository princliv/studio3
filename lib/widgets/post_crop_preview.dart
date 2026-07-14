import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/post_image_transform.dart';
import '../utils/image_adjust_math.dart';

/// True-to-output preview of a post image: same rotation/flip/zoom/aspect
/// ratio/color-adjust math as the edit screen's live preview, so every
/// "review" step in the posting flow honestly reflects what will be
/// uploaded — not a fixed-size, color-filter-only stand-in.
class PostCropPreview extends StatefulWidget {
  const PostCropPreview({
    super.key,
    required this.imagePath,
    required this.transform,
    this.borderRadius = BorderRadius.zero,
  });

  final String imagePath;
  final PostImageTransform transform;
  final BorderRadius borderRadius;

  /// The transformed (rotated/flipped/scaled/color-adjusted) image content,
  /// without any outer sizing — shared by the edit screen's gesture-enabled
  /// live preview and this read-only preview so the math lives in one place.
  static Widget buildTransformedContent({
    required String imagePath,
    required PostImageTransform transform,
    required double imageAspect,
  }) {
    final scale = transform.effectiveScale(imageAspect);
    final radians = transform.rotationDegrees * math.pi / 180;
    final sx = (transform.flipHorizontal ? -1.0 : 1.0) * scale;
    final sy = (transform.flipVertical ? -1.0 : 1.0) * scale;

    Widget image = Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..rotateZ(radians)
        ..scaleByDouble(sx, sy, 1.0, 1),
      child: sourceImage(imagePath),
    );

    if (!ImageAdjustMath.isNeutral(
      brightness: transform.brightness,
      contrast: transform.contrast,
      exposure: transform.exposure,
    )) {
      image = ColorFiltered(
        colorFilter: ColorFilter.matrix(
          ImageAdjustMath.combinedMatrix(
            brightness: transform.brightness,
            contrast: transform.contrast,
            exposure: transform.exposure,
          ),
        ),
        child: image,
      );
    }

    return ColoredBox(color: Colors.black, child: image);
  }

  /// Loads [path] as an asset (bundled dummy grid images) or a real file
  /// (gallery-picked photos), matching the dual-path handling used
  /// throughout the posting flow.
  static Widget sourceImage(String path) {
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    return Image.file(
      File(path),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }

  @override
  State<PostCropPreview> createState() => _PostCropPreviewState();
}

class _PostCropPreviewState extends State<PostCropPreview> {
  double? _imageAspect;

  @override
  void initState() {
    super.initState();
    _loadAspect();
  }

  @override
  void didUpdateWidget(covariant PostCropPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagePath != widget.imagePath) {
      _imageAspect = null;
      _loadAspect();
    }
  }

  Future<void> _loadAspect() async {
    final path = widget.imagePath;
    try {
      ui.Image decoded;
      if (path.startsWith('assets/')) {
        final data = await rootBundle.load(path);
        final codec = await ui.instantiateImageCodec(
          data.buffer.asUint8List(),
        );
        decoded = (await codec.getNextFrame()).image;
      } else {
        final bytes = await File(path).readAsBytes();
        final codec = await ui.instantiateImageCodec(bytes);
        decoded = (await codec.getNextFrame()).image;
      }
      final w = decoded.width.toDouble();
      final h = decoded.height.toDouble();
      if (!mounted || h == 0) return;
      setState(() => _imageAspect = w / h);
    } catch (_) {
      if (mounted) setState(() => _imageAspect = 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: AspectRatio(
        aspectRatio: widget.transform.aspectRatio.value,
        child: PostCropPreview.buildTransformedContent(
          imagePath: widget.imagePath,
          transform: widget.transform,
          imageAspect: _imageAspect ?? 1.0,
        ),
      ),
    );
  }
}
