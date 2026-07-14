import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/services.dart';

import '../models/post_image_transform.dart';
import 'image_adjust_math.dart';

/// Bakes a [PostImageTransform] (crop aspect ratio, rotation, flip, zoom,
/// brightness/contrast/exposure) into real image bytes, matching exactly
/// what the edit screen's live preview shows — so the uploaded image is
/// what the user actually chose, not the original untouched file.
abstract final class PostImageRenderer {
  static const double maxOutputLongSide = 1920;

  static Future<Uint8List> render({
    required String imagePath,
    required PostImageTransform transform,
  }) async {
    final sourceBytes = await _loadSourceBytes(imagePath);
    final codec = await ui.instantiateImageCodec(sourceBytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    try {
      return await _renderTransformed(image, transform);
    } finally {
      image.dispose();
    }
  }

  static Future<Uint8List> _loadSourceBytes(String path) async {
    if (path.startsWith('assets/')) {
      final data = await rootBundle.load(path);
      return data.buffer.asUint8List();
    }
    return File(path).readAsBytes();
  }

  static Future<Uint8List> _renderTransformed(
    ui.Image image,
    PostImageTransform transform,
  ) async {
    final imgW = image.width.toDouble();
    final imgH = image.height.toDouble();
    final imageAspect = imgW / imgH;
    final ratio = transform.aspectRatio.value;

    double outW;
    double outH;
    if (ratio >= 1) {
      outW = maxOutputLongSide;
      outH = outW / ratio;
    } else {
      outH = maxOutputLongSide;
      outW = outH * ratio;
    }

    final baseCoverScale = math.max(outW / imgW, outH / imgH);
    final totalScale = baseCoverScale * transform.effectiveScale(imageAspect);

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(
      recorder,
      ui.Rect.fromLTWH(0, 0, outW, outH),
    );
    canvas.clipRect(ui.Rect.fromLTWH(0, 0, outW, outH));
    canvas.translate(outW / 2, outH / 2);
    canvas.rotate(transform.rotationDegrees * math.pi / 180);
    canvas.scale(
      (transform.flipHorizontal ? -1.0 : 1.0) * totalScale,
      (transform.flipVertical ? -1.0 : 1.0) * totalScale,
    );

    final paint = ui.Paint();
    if (!ImageAdjustMath.isNeutral(
      brightness: transform.brightness,
      contrast: transform.contrast,
      exposure: transform.exposure,
    )) {
      paint.colorFilter = ui.ColorFilter.matrix(
        ImageAdjustMath.combinedMatrix(
          brightness: transform.brightness,
          contrast: transform.contrast,
          exposure: transform.exposure,
        ),
      );
    }

    canvas.drawImage(image, ui.Offset(-imgW / 2, -imgH / 2), paint);

    final picture = recorder.endRecording();
    try {
      final rendered = await picture.toImage(outW.round(), outH.round());
      try {
        final byteData =
            await rendered.toByteData(format: ui.ImageByteFormat.png);
        return byteData!.buffer.asUint8List();
      } finally {
        rendered.dispose();
      }
    } finally {
      picture.dispose();
    }
  }
}
