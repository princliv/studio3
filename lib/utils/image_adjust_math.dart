import 'dart:math' as math;

/// Builds a [ColorFilter.matrix] for brightness / contrast / exposure.
/// Each value is 0–100 with 50 as neutral (no change).
abstract final class ImageAdjustMath {
  ImageAdjustMath._();

  static List<double> combinedMatrix({
    required double brightness,
    required double contrast,
    required double exposure,
  }) {
    final brightnessOffset = (brightness - 50) / 50 * 0.55;
    final contrastScale = 1 + (contrast - 50) / 50 * 1.4;
    final exposureScale = math.pow(2, (exposure - 50) / 18).toDouble();

    final scale = contrastScale * exposureScale;
    final offset = brightnessOffset + (1 - contrastScale) * 0.5;

    return [
      scale, 0, 0, 0, offset,
      0, scale, 0, 0, offset,
      0, 0, scale, 0, offset,
      0, 0, 0, 1, 0,
    ];
  }

  static bool isNeutral({
    required double brightness,
    required double contrast,
    required double exposure,
  }) =>
      (brightness - 50).abs() < 0.01 &&
      (contrast - 50).abs() < 0.01 &&
      (exposure - 50).abs() < 0.01;
}
