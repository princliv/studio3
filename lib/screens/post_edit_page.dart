import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/post_media_assets.dart';
import '../models/post_image_transform.dart';
import '../theme/home_feed_tokens.dart';
import '../utils/crop_cover_math.dart' show CropAspectRatio;

/// Image edit step — posting flow (Figma 1961:1453 / 1973:1223 / 1986:1416).
class PostEditPage extends StatefulWidget {
  const PostEditPage({
    super.key,
    required this.postType,
    required this.selectedCellIndices,
  });

  final String postType;
  final List<int> selectedCellIndices;

  @override
  State<PostEditPage> createState() => _PostEditPageState();
}

class _PostEditPageState extends State<PostEditPage> {
  static const _previewHorizontalInset = 6.0;
  static const _previewGapBelowBanner = 36.0;
  static const _previewRadius = 8.0;
  static const _thumbSize = 56.0;
  static const _thumbGap = 6.0;
  static const _thumbStripTopGap = 12.0;
  static const _bottomControlsOffset = 42.0;
  static const _cropToolsGapAboveSelector = 12.0;
  static const _errorRed = Color(0xFFC03030);
  static const _maxCropHeightFraction = 0.52;

  late final List<String> _imagePaths;
  late final List<PostImageTransform> _transforms;
  final Map<String, double> _imageAspects = {};

  int _activeImageIndex = 0;
  String? _editTool;
  CropSubTool? _activeCropSubTool;

  double _gestureBaseRotation = 0;
  double _gestureBaseZoom = 1;

  bool get _isCropMode => _editTool == 'crop';
  bool get _isRotateMode =>
      _isCropMode && _activeCropSubTool == CropSubTool.rotate;

  PostImageTransform get _currentTransform => _transforms[_activeImageIndex];

  double _aspectForPath(String path) => _imageAspects[path] ?? 1.0;

  @override
  void initState() {
    super.initState();
    _imagePaths = PostMediaAssets.assetPathsForCells(
      postType: widget.postType,
      cellIndices: widget.selectedCellIndices,
    );
    _transforms = List.generate(
      _imagePaths.length,
      (_) => PostImageTransform(),
    );
    for (final path in _imagePaths.toSet()) {
      _loadImageAspect(path);
    }
  }

  Future<void> _loadImageAspect(String path) async {
    if (_imageAspects.containsKey(path)) return;
    try {
      final data = await rootBundle.load(path);
      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
      );
      final frame = await codec.getNextFrame();
      final w = frame.image.width.toDouble();
      final h = frame.image.height.toDouble();
      if (!mounted || h == 0) return;
      setState(() => _imageAspects[path] = w / h);
    } catch (_) {
      if (mounted) setState(() => _imageAspects[path] = 1.0);
    }
  }

  void _applyRotation(double degrees) {
    setState(() => _currentTransform.rotationDegrees = degrees);
  }

  void _onCropSubToolTap(CropSubTool tool) {
    setState(() {
      _editTool = 'crop';
      if (tool == CropSubTool.rotate) {
        _activeCropSubTool = CropSubTool.rotate;
        return;
      }
      if (tool == CropSubTool.flipHorizontal) {
        _currentTransform.flipHorizontal = !_currentTransform.flipHorizontal;
      } else if (tool == CropSubTool.flipVertical) {
        _currentTransform.flipVertical = !_currentTransform.flipVertical;
      }
    });
  }

  void _resetCurrentTransform() {
    setState(() {
      _currentTransform.reset();
    });
  }

  void _finishRotateMode() {
    setState(() => _activeCropSubTool = null);
  }

  Size _cropFrameSize(double maxWidth, double maxHeight, CropAspectRatio ratio) {
    var width = maxWidth;
    var height = width / ratio.value;
    if (height > maxHeight) {
      height = maxHeight;
      width = height * ratio.value;
    }
    return Size(width, height);
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final hasMultiple = _imagePaths.length > 1;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final maxCropWidth =
        MediaQuery.sizeOf(context).width - (_previewHorizontalInset * 2);
    final maxCropHeight = screenHeight * _maxCropHeightFraction;
    final cropSize = _cropFrameSize(
      maxCropWidth,
      maxCropHeight,
      _currentTransform.aspectRatio,
    );
    final imageAspect = _aspectForPath(_imagePaths[_activeImageIndex]);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          _EditBanner(
            topInset: topInset,
            onClose: () => Navigator.pop(context),
            onNext: () {},
          ),
          const SizedBox(height: _previewGapBelowBanner),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: _previewHorizontalInset,
            ),
            child: SizedBox(
              width: maxCropWidth,
              height: maxCropHeight,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(_previewRadius),
                  child: SizedBox(
                    width: cropSize.width,
                    height: cropSize.height,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _CropPreviewImage(
                          assetPath: _imagePaths[_activeImageIndex],
                          transform: _currentTransform,
                          imageAspect: imageAspect,
                          gesturesEnabled: _isCropMode,
                          onScaleStart: () {
                            _gestureBaseRotation =
                                _currentTransform.rotationDegrees;
                            _gestureBaseZoom = _currentTransform.zoomFactor;
                          },
                          onScaleUpdate: (rotationDelta, scaleDelta) {
                            setState(() {
                              _currentTransform.rotationDegrees =
                                  _gestureBaseRotation + rotationDelta;
                              _currentTransform.zoomFactor =
                                  (_gestureBaseZoom * scaleDelta)
                                      .clamp(1.0, 4.0);
                            });
                          },
                        ),
                        if (_isCropMode)
                          const IgnorePointer(child: _RuleOfThirdsGrid()),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (hasMultiple && !_isCropMode) ...[
            const SizedBox(height: _thumbStripTopGap),
            SizedBox(
              height: _thumbSize,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _imagePaths.length,
                separatorBuilder: (context, _) =>
                    const SizedBox(width: _thumbGap),
                itemBuilder: (context, index) {
                  final active = index == _activeImageIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _activeImageIndex = index),
                    child: Container(
                      width: _thumbSize,
                      height: _thumbSize,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: active
                              ? HomeFeedTokens.textInverse
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.asset(
                          _imagePaths[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const Spacer(),
          if (_isCropMode) ...[
            _CropAspectSelector(
              selected: _currentTransform.aspectRatio,
              onSelected: (ratio) {
                setState(() => _currentTransform.aspectRatio = ratio);
              },
            ),
            const SizedBox(height: 16),
            if (_isRotateMode) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: _resetCurrentTransform,
                      behavior: HitTestBehavior.opaque,
                      child: Text(
                        'RESET',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: _errorRed,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _finishRotateMode,
                      behavior: HitTestBehavior.opaque,
                      child: Text(
                        'DONE',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: HomeFeedTokens.textInverse,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: _RotationDial(
                  rotationDegrees: _currentTransform.rotationDegrees,
                  onRotationChanged: _applyRotation,
                ),
              ),
              const SizedBox(height: 12),
            ],
            _CropTransformBar(
              selectedTool: _activeCropSubTool,
              onToolTap: _onCropSubToolTap,
            ),
            const SizedBox(height: _cropToolsGapAboveSelector),
          ],
          Center(
            child: _EditToolSelector(
              editTool: _editTool,
              onChanged: (tool) => setState(() {
                _editTool = tool;
                if (tool != 'crop') _activeCropSubTool = null;
              }),
            ),
          ),
          SizedBox(height: bottomInset + _bottomControlsOffset),
        ],
      ),
    );
  }
}

class _CropPreviewImage extends StatelessWidget {
  const _CropPreviewImage({
    required this.assetPath,
    required this.transform,
    required this.imageAspect,
    required this.gesturesEnabled,
    required this.onScaleStart,
    required this.onScaleUpdate,
  });

  final String assetPath;
  final PostImageTransform transform;
  final double imageAspect;
  final bool gesturesEnabled;
  final VoidCallback onScaleStart;
  final void Function(double rotationDelta, double scaleDelta) onScaleUpdate;

  @override
  Widget build(BuildContext context) {
    final scale = transform.effectiveScale(imageAspect);
    final radians = transform.rotationDegrees * math.pi / 180;
    final sx = (transform.flipHorizontal ? -1.0 : 1.0) * scale;
    final sy = (transform.flipVertical ? -1.0 : 1.0) * scale;

    final image = ColoredBox(
      color: Colors.black,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..rotateZ(radians)
          ..scaleByDouble(sx, sy, 1.0, 1),
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );

    if (!gesturesEnabled) return image;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onScaleStart: (_) => onScaleStart(),
      onScaleUpdate: (details) {
        onScaleUpdate(
          details.rotation * 180 / math.pi,
          details.scale,
        );
      },
      child: image,
    );
  }
}

class _CropAspectSelector extends StatelessWidget {
  const _CropAspectSelector({
    required this.selected,
    required this.onSelected,
  });

  static const _selectorBg = Color(0xE6231F1B);

  final CropAspectRatio selected;
  final ValueChanged<CropAspectRatio> onSelected;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: _selectorBg,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final ratio in CropAspectRatio.values) ...[
              _CropAspectChip(
                label: ratio.label,
                selected: selected == ratio,
                onTap: () => onSelected(ratio),
              ),
              if (ratio != CropAspectRatio.values.last)
                const SizedBox(width: 4),
            ],
          ],
        ),
      ),
    );
  }
}

class _CropAspectChip extends StatelessWidget {
  const _CropAspectChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  static const _textSecondary = Color(0xFF8C8880);

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
            color: selected ? HomeFeedTokens.textInverse : _textSecondary,
          ),
        ),
      ),
    );
  }
}

class _RotationDial extends StatelessWidget {
  const _RotationDial({
    required this.rotationDegrees,
    required this.onRotationChanged,
  });

  static const _dialWidth = 160.0;
  static const _dialHeight = 12.0;
  static const _degreesPerPixel = 0.35;

  final double rotationDegrees;
  final ValueChanged<double> onRotationChanged;

  @override
  Widget build(BuildContext context) {
    final dialOffset = -rotationDegrees / _degreesPerPixel;

    return SizedBox(
      width: _dialWidth,
      height: 28,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 28,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate: (details) {
                onRotationChanged(
                  rotationDegrees - details.delta.dx * _degreesPerPixel,
                );
              },
              child: ClipRect(
                child: CustomPaint(
                  size: const Size(_dialWidth, _dialHeight),
                  painter: _RotationDialPainter(offsetX: dialOffset),
                ),
              ),
            ),
          ),
          Positioned(
            top: _dialHeight + 2,
            child: Container(
              width: 2,
              height: 2,
              decoration: BoxDecoration(
                color: HomeFeedTokens.textInverse,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RotationDialPainter extends CustomPainter {
  const _RotationDialPainter({required this.offsetX});

  static const _tickSpacing = 6.0;
  static const _baselineY = 11.625;

  final double offsetX;

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final paint = Paint()
      ..strokeWidth = 0.75
      ..strokeCap = StrokeCap.round;

    for (var i = -14; i <= 14; i++) {
      final x = centerX + i * _tickSpacing + offsetX;
      if (x < 2 || x > size.width - 2) continue;

      final dist = (x - centerX).abs();
      final height = (11.0 - dist * 0.18).clamp(3.0, 11.0);
      final opacity = (1.0 - dist * 0.025).clamp(0.35, 1.0);
      paint.color = Colors.white.withValues(alpha: opacity);

      canvas.drawLine(
        Offset(x, _baselineY),
        Offset(x, _baselineY - height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RotationDialPainter oldDelegate) =>
      oldDelegate.offsetX != offsetX;
}

class _RuleOfThirdsGrid extends StatelessWidget {
  const _RuleOfThirdsGrid();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RuleOfThirdsPainter(),
      size: Size.infinite,
    );
  }
}

class _RuleOfThirdsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = 1;

    for (var i = 1; i <= 2; i++) {
      final x = size.width * i / 3;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CropTransformBar extends StatelessWidget {
  const _CropTransformBar({
    required this.selectedTool,
    required this.onToolTap,
  });

  static const _iconSize = 24.0;
  static const _barWidth = 140.0;
  static const _barHeight = 32.0;

  final CropSubTool? selectedTool;
  final ValueChanged<CropSubTool> onToolTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _barHeight,
      child: Center(
        child: SizedBox(
          width: _barWidth,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _CropToolButton(
                  asset: PostMediaAssets.cropRotate,
                  selected: selectedTool == CropSubTool.rotate,
                  onTap: () => onToolTap(CropSubTool.rotate),
                ),
                _CropToolButton(
                  asset: PostMediaAssets.cropPerspectiveH,
                  selected: false,
                  onTap: () => onToolTap(CropSubTool.flipHorizontal),
                ),
                _CropToolButton(
                  asset: PostMediaAssets.cropPerspectiveV,
                  selected: false,
                  onTap: () => onToolTap(CropSubTool.flipVertical),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CropToolButton extends StatelessWidget {
  const _CropToolButton({
    required this.asset,
    required this.selected,
    required this.onTap,
  });

  final String asset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            asset,
            width: _CropTransformBar._iconSize,
            height: _CropTransformBar._iconSize,
          ),
          if (selected) ...[
            const SizedBox(height: 4),
            Container(
              width: 2,
              height: 2,
              decoration: BoxDecoration(
                color: HomeFeedTokens.textInverse,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ] else
            const SizedBox(height: 6),
        ],
      ),
    );
  }
}

class _EditBanner extends StatelessWidget {
  const _EditBanner({
    required this.topInset,
    required this.onClose,
    required this.onNext,
  });

  static const _bannerHeight = 64.0;
  static const _neutral300 = Color(0xFFC8C5BC);

  final double topInset;
  final VoidCallback onClose;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Padding(
        padding: EdgeInsets.only(top: topInset),
        child: SizedBox(
          height: _bannerHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onClose,
                  behavior: HitTestBehavior.opaque,
                  child: SvgPicture.asset(
                    PostMediaAssets.closeIcon,
                    width: 14,
                    height: 14,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Edit',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: HomeFeedTokens.textInverse,
                      ),
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onNext,
                    borderRadius: BorderRadius.circular(100),
                    child: Container(
                      width: 60,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _neutral300,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        'Next',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: HomeFeedTokens.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EditToolSelector extends StatelessWidget {
  const _EditToolSelector({
    required this.editTool,
    required this.onChanged,
  });

  static const _selectorBg = Color(0xE6231F1B);

  final String? editTool;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _selectorBg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _EditToolTab(
            label: 'Crop',
            selected: editTool == 'crop',
            onTap: () => onChanged('crop'),
          ),
          _EditToolTab(
            label: 'Adjust',
            selected: editTool == 'adjust',
            onTap: () => onChanged('adjust'),
          ),
        ],
      ),
    );
  }
}

class _EditToolTab extends StatelessWidget {
  const _EditToolTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  static const _textSecondary = Color(0xFF8C8880);

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
          color: selected ? HomeFeedTokens.textInverse : _textSecondary,
        ),
      ),
    );
  }
}
