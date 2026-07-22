import 'dart:math' as math;
import 'dart:ui' show Offset;

/// Crop frame aspect ratios (width / height).
enum CropAspectRatio {
  ratio3x4(3 / 4, '3:4'),
  ratio16x9(16 / 9, '16:9');

  const CropAspectRatio(this.value, this.label);

  final double value;
  final String label;
}

/// How the image fills the crop frame: [fill] crops to cover the frame
/// (existing behavior), [fit] shows the whole image, letterboxed.
enum CropFitMode { fill, fit }

/// Shared geometry for the crop transform — cover scale, contain scale, and
/// pan bounds — all normalized so the crop frame has unit width (cropW=1.0).
abstract final class CropCoverMath {
  CropCoverMath._();

  /// Pre-rotation size (crop-frame-width units) an image of [imageAspect]
  /// must be drawn at so it exactly covers a [cropAspect] frame — the
  /// baseline both cover- and contain-scale, and the pan clamp, build on.
  static (double imgW, double imgH) _coverImageSize(
    double cropAspect,
    double imageAspect,
  ) {
    const cropW = 1.0;
    final cropH = 1.0 / cropAspect;
    if (imageAspect >= cropAspect) {
      return (cropH * imageAspect, cropH);
    }
    return (cropW, cropW / imageAspect);
  }

  static (double bboxW, double bboxH) _rotatedBounds({
    required double imgW,
    required double imgH,
    required double rotationDegrees,
  }) {
    final rad = rotationDegrees * math.pi / 180;
    final c = math.cos(rad).abs();
    final s = math.sin(rad).abs();
    return (imgW * c + imgH * s, imgW * s + imgH * c);
  }

  /// Minimum scale so a rotated image covers the crop frame with no gaps.
  static double minCoverScale({
    required double rotationDegrees,
    required double cropAspect,
    required double imageAspect,
  }) {
    const cropW = 1.0;
    final cropH = 1.0 / cropAspect;
    final (imgW, imgH) = _coverImageSize(cropAspect, imageAspect);
    final (bboxW, bboxH) =
        _rotatedBounds(imgW: imgW, imgH: imgH, rotationDegrees: rotationDegrees);
    return math.max(cropW / bboxW, cropH / bboxH);
  }

  /// Maximum scale so a rotated image still fits entirely inside the crop
  /// frame with no cropping ("Fit" mode) — the complement of [minCoverScale].
  static double maxContainScale({
    required double rotationDegrees,
    required double cropAspect,
    required double imageAspect,
  }) {
    const cropW = 1.0;
    final cropH = 1.0 / cropAspect;
    final (imgW, imgH) = _coverImageSize(cropAspect, imageAspect);
    final (bboxW, bboxH) =
        _rotatedBounds(imgW: imgW, imgH: imgH, rotationDegrees: rotationDegrees);
    return math.min(cropW / bboxW, cropH / bboxH);
  }

  /// Clamps a proposed pan (translation, crop-frame-width units, frame axes)
  /// so the image — rendered at [scale] and [rotationDegrees] — always fully
  /// covers the crop rect. Clamps independently along the image's own
  /// (rotated) axes: exact at rotation 0, and a close approximation of true
  /// rotated-rectangle containment at the small rotations this editor's
  /// dial supports. Validate visually at extreme rotation + max zoom if this
  /// is ever loosened, since it could in theory admit a sliver of gap.
  static Offset clampPan({
    required Offset pan,
    required double scale,
    required double rotationDegrees,
    required double cropAspect,
    required double imageAspect,
  }) {
    final cropH = 1.0 / cropAspect;
    final (imgW, imgH) = _coverImageSize(cropAspect, imageAspect);
    final rad = rotationDegrees * math.pi / 180;
    final c = math.cos(rad);
    final s = math.sin(rad);
    final cAbs = c.abs();
    final sAbs = s.abs();

    final halfImgW = imgW * scale / 2;
    final halfImgH = imgH * scale / 2;
    final halfCropOnImgX = 0.5 * cAbs + (cropH / 2) * sAbs;
    final halfCropOnImgY = 0.5 * sAbs + (cropH / 2) * cAbs;

    final limitX = math.max(0.0, halfImgW - halfCropOnImgX);
    final limitY = math.max(0.0, halfImgH - halfCropOnImgY);

    // Rotate the requested pan into the image's local axes, clamp, rotate back.
    final localX = pan.dx * c + pan.dy * s;
    final localY = -pan.dx * s + pan.dy * c;
    final clampedX = localX.clamp(-limitX, limitX);
    final clampedY = localY.clamp(-limitY, limitY);

    return Offset(
      clampedX * c - clampedY * s,
      clampedX * s + clampedY * c,
    );
  }
}
