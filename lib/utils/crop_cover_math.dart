import 'dart:math' as math;

/// Crop frame aspect ratios (width / height).
enum CropAspectRatio {
  ratio3x4(3 / 4, '3:4'),
  ratio16x9(16 / 9, '16:9');

  const CropAspectRatio(this.value, this.label);

  final double value;
  final String label;
}

/// Computes minimum scale so a rotated image covers the crop frame with no gaps.
abstract final class CropCoverMath {
  CropCoverMath._();

  static double minCoverScale({
    required double rotationDegrees,
    required double cropAspect,
    required double imageAspect,
  }) {
    const cropW = 1.0;
    final cropH = 1.0 / cropAspect;

    late final double imgW;
    late final double imgH;
    if (imageAspect >= cropAspect) {
      imgH = cropH;
      imgW = cropH * imageAspect;
    } else {
      imgW = cropW;
      imgH = cropW / imageAspect;
    }

    final rad = rotationDegrees * math.pi / 180;
    final c = math.cos(rad).abs();
    final s = math.sin(rad).abs();
    final bboxW = imgW * c + imgH * s;
    final bboxH = imgW * s + imgH * c;

    return math.max(cropW / bboxW, cropH / bboxH);
  }
}
