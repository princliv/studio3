import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/post_material_options.dart';
import '../data/post_media_assets.dart';
import '../models/post_image_transform.dart';
import '../theme/home_feed_tokens.dart';
import '../utils/image_adjust_math.dart';
import 'pick_materials_page.dart';

/// Add materials — posting flow (Figma 2021:4128).
class AddMaterialsPage extends StatefulWidget {
  const AddMaterialsPage({
    super.key,
    required this.previewImagePath,
    required this.transform,
    required this.initialMaterials,
  });

  final String previewImagePath;
  final PostImageTransform transform;
  final List<PostMaterialOption> initialMaterials;

  @override
  State<AddMaterialsPage> createState() => _AddMaterialsPageState();
}

class _AddMaterialsPageState extends State<AddMaterialsPage> {
  static const _textSecondary = Color(0xFF8C8880);

  static const _previewWidth = 256.0;
  static const _previewHeight = 340.0;
  static const _previewRadius = 8.0;

  late List<PostMaterialOption> _selected;

  bool get _hasSelection => _selected.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _selected = List<PostMaterialOption>.from(widget.initialMaterials);
  }

  Future<void> _openPickMaterials() async {
    final result = await Navigator.push<List<PostMaterialOption>>(
      context,
      MaterialPageRoute<List<PostMaterialOption>>(
        builder: (_) => PickMaterialsPage(
          initialSelection: List<PostMaterialOption>.from(_selected),
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() => _selected = result);
    }
  }

  void _removeMaterial(PostMaterialOption material) {
    setState(() => _selected.removeWhere((m) => m.id == material.id));
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          _AddMaterialsBanner(
            topInset: topInset,
            hasSelection: _hasSelection,
            onClose: () => Navigator.pop(context),
            onDone: _hasSelection
                ? () => Navigator.pop(context, _selected)
                : null,
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(10, 12, 10, 0),
                    child: Column(
                      children: [
                        _MaterialsPreviewImage(
                          assetPath: widget.previewImagePath,
                          transform: widget.transform,
                          width: _previewWidth,
                          height: _previewHeight,
                          radius: _previewRadius,
                        ),
                        if (_selected.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          ..._selected.map(
                            (material) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: GestureDetector(
                                onTap: () => _removeMaterial(material),
                                behavior: HitTestBehavior.opaque,
                                child: _MaterialRow(material: material),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 16, 10, bottomInset + 24),
                  child: GestureDetector(
                    onTap: _openPickMaterials,
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Tap to add materials\n used on your piece',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: _textSecondary,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Icon(
                          Icons.add,
                          size: 30,
                          color: HomeFeedTokens.textInverse,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddMaterialsBanner extends StatelessWidget {
  const _AddMaterialsBanner({
    required this.topInset,
    required this.hasSelection,
    required this.onClose,
    required this.onDone,
  });

  static const _neutral300 = Color(0xFFC8C5BC);

  final double topInset;
  final bool hasSelection;
  final VoidCallback onClose;
  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Padding(
        padding: EdgeInsets.only(top: topInset),
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onClose,
                  behavior: HitTestBehavior.opaque,
                  child: SvgPicture.asset(
                    PostMediaAssets.createCloseIcon,
                    width: 14,
                    height: 14,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Add materials',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: HomeFeedTokens.textInverse,
                      ),
                    ),
                  ),
                ),
                Opacity(
                  opacity: hasSelection ? 1 : 0.3,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onDone,
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
                          'Done',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: HomeFeedTokens.textPrimary,
                          ),
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

class _MaterialsPreviewImage extends StatelessWidget {
  const _MaterialsPreviewImage({
    required this.assetPath,
    required this.transform,
    required this.width,
    required this.height,
    required this.radius,
  });

  final String assetPath;
  final PostImageTransform transform;
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    Widget image = Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: BoxFit.cover,
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: image,
    );
  }
}

class _MaterialRow extends StatelessWidget {
  const _MaterialRow({required this.material});

  static const _textSecondary = Color(0xFF8C8880);

  final PostMaterialOption material;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            material.imagePath,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  material.name,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: HomeFeedTokens.textInverse,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  material.price,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
