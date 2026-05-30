import '../utils/crop_cover_math.dart';

/// Per-image crop transform state for the posting edit flow.
class PostImageTransform {
  PostImageTransform({
    this.aspectRatio = CropAspectRatio.ratio2x3,
    this.rotationDegrees = 0,
    this.zoomFactor = 1,
    this.flipVertical = false,
    this.flipHorizontal = false,
  });

  CropAspectRatio aspectRatio;
  double rotationDegrees;
  /// User pinch zoom multiplier applied on top of auto cover scale (min 1.0).
  double zoomFactor;
  bool flipVertical;
  bool flipHorizontal;

  void reset() {
    rotationDegrees = 0;
    zoomFactor = 1;
    flipVertical = false;
    flipHorizontal = false;
  }

  double effectiveScale(double imageAspect) {
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
