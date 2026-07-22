import 'dart:ui' show Offset;

import '../utils/crop_cover_math.dart';

/// Per-image crop transform state for the posting edit flow.
class PostImageTransform {
  PostImageTransform({
    this.aspectRatio = CropAspectRatio.ratio3x4,
    this.rotationDegrees = 0,
    this.zoomFactor = 1,
    this.pan = Offset.zero,
    this.fitMode = CropFitMode.fill,
    this.flipVertical = false,
    this.flipHorizontal = false,
    this.brightness = 50,
    this.contrast = 50,
    this.exposure = 50,
  });

  CropAspectRatio aspectRatio;
  double rotationDegrees;
  /// User pinch zoom multiplier applied on top of auto cover scale (min 1.0).
  double zoomFactor;
  /// Translation in Fill mode, normalized to crop-frame width (frame axes).
  /// Ignored in Fit mode. Always kept within [CropCoverMath.clampPan] bounds.
  Offset pan;
  /// Fill crops to cover the frame; Fit shows the whole image, letterboxed.
  CropFitMode fitMode;
  bool flipVertical;
  bool flipHorizontal;
  /// Adjust sliders — 0–100, 50 is neutral.
  double brightness;
  double contrast;
  double exposure;

  void reset() {
    resetCrop();
    resetAdjust();
  }

  void resetCrop() {
    aspectRatio = CropAspectRatio.ratio3x4;
    rotationDegrees = 0;
    zoomFactor = 1;
    pan = Offset.zero;
    fitMode = CropFitMode.fill;
    flipVertical = false;
    flipHorizontal = false;
  }

  void resetAdjust() {
    brightness = 50;
    contrast = 50;
    exposure = 50;
  }

  PostImageTransform copy() => PostImageTransform(
        aspectRatio: aspectRatio,
        rotationDegrees: rotationDegrees,
        zoomFactor: zoomFactor,
        pan: pan,
        fitMode: fitMode,
        flipVertical: flipVertical,
        flipHorizontal: flipHorizontal,
        brightness: brightness,
        contrast: contrast,
        exposure: exposure,
      );

  double adjustValueFor(AdjustSubTool tool) => switch (tool) {
        AdjustSubTool.brightness => brightness,
        AdjustSubTool.contrast => contrast,
        AdjustSubTool.exposure => exposure,
      };

  void setAdjustValue(AdjustSubTool tool, double value) {
    final clamped = value.clamp(0.0, 100.0);
    switch (tool) {
      case AdjustSubTool.brightness:
        brightness = clamped;
      case AdjustSubTool.contrast:
        contrast = clamped;
      case AdjustSubTool.exposure:
        exposure = clamped;
    }
  }

  double effectiveScale(double imageAspect) {
    if (fitMode == CropFitMode.fit) {
      return CropCoverMath.maxContainScale(
        rotationDegrees: rotationDegrees,
        cropAspect: aspectRatio.value,
        imageAspect: imageAspect,
      );
    }
    final cover = CropCoverMath.minCoverScale(
      rotationDegrees: rotationDegrees,
      cropAspect: aspectRatio.value,
      imageAspect: imageAspect,
    );
    return cover * zoomFactor;
  }
}

/// Active crop sub-tool within crop mode.
enum CropSubTool {
  rotate,
  flipVertical,
  flipHorizontal,
}

/// Active adjust sub-tool within adjust mode.
enum AdjustSubTool {
  brightness,
  contrast,
  exposure,
}
