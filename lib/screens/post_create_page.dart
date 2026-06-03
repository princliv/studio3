import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/post_location_options.dart';
import '../data/post_picker_options.dart';
import '../data/post_media_assets.dart';
import '../models/post_image_transform.dart';
import '../theme/home_feed_tokens.dart';
import '../utils/image_adjust_math.dart';
import '../widgets/choose_location_sheet.dart';
import '../widgets/post_create_option_sheet.dart';

/// Create post details — posting flow (Figma 1995:1486).
class PostCreatePage extends StatefulWidget {
  const PostCreatePage({
    super.key,
    required this.postType,
    required this.selectedCellIndices,
    required this.imagePaths,
    required this.transforms,
    required this.previewImageIndex,
  });

  final String postType;
  final List<int> selectedCellIndices;
  final List<String> imagePaths;
  final List<PostImageTransform> transforms;
  final int previewImageIndex;

  @override
  State<PostCreatePage> createState() => _PostCreatePageState();
}

class _PostCreatePageState extends State<PostCreatePage> {
  static const _textDisabled = Color(0xFFC8C5BC);
  static const _textSecondary = Color(0xFF8C8880);
  static const _neutral700 = Color(0xFF4A4843);
  static const _neutral300 = Color(0xFFC8C5BC);

  static const _horizontalInset = 15.0;

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _aiToolsUsed = false;
  final List<PostLocationOption> _selectedLocations = [];
  String? _selectedMediumId;
  final Set<String> _selectedStyleIds = {};

  void _openLocationPicker() {
    ChooseLocationSheet.show(
      context,
      selectedIds: _selectedLocations.map((l) => l.id).toSet(),
      onLocationSelected: (location) {
        setState(() {
          if (_selectedLocations.any((l) => l.id == location.id)) return;
          _selectedLocations.add(location);
        });
      },
    );
  }

  void _openMediumPicker() {
    PostCreateOptionSheet.show(
      context,
      title: 'Select medium',
      searchHint: 'Search medium',
      options: PostMediumOptions.all,
      selectedIds:
          _selectedMediumId != null ? {_selectedMediumId!} : const {},
      mode: PostPickerSelectionMode.singleRadio,
      closeOnSelection: true,
      onSelectionChanged: (ids) {
        setState(() {
          _selectedMediumId = ids.isEmpty ? null : ids.first;
        });
      },
    );
  }

  void _openStylePicker() {
    PostCreateOptionSheet.show(
      context,
      title: 'Select style',
      searchHint: 'Search style',
      options: PostStyleOptions.all,
      selectedIds: Set<String>.from(_selectedStyleIds),
      mode: PostPickerSelectionMode.multiCheckbox,
      maxSelections: PostStyleOptions.maxSelections,
      onSelectionChanged: (ids) {
        setState(() {
          _selectedStyleIds
            ..clear()
            ..addAll(ids);
        });
      },
    );
  }

  String? get _mediumTrailing =>
      PostMediumOptions.byId(_selectedMediumId ?? '')?.name;

  String? get _styleTrailing {
    if (_selectedStyleIds.isEmpty) return null;
    if (_selectedStyleIds.length == 1) {
      return PostStyleOptions.byId(_selectedStyleIds.first)?.name;
    }
    return '${_selectedStyleIds.length}/${PostStyleOptions.maxSelections}';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String get _title =>
      widget.postType == 'scene' ? 'Create scene' : 'Create piece';

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          _CreateBanner(
            topInset: topInset,
            title: _title,
            onClose: () => Navigator.pop(context),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 13),
                  Center(
                    child: _PreviewCard(
                      imagePath: widget.imagePaths[widget.previewImageIndex],
                      transform: widget.transforms[widget.previewImageIndex],
                      onEdit: () => Navigator.pop(context, true),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _nameController,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: HomeFeedTokens.textInverse,
                      ),
                      cursorColor: HomeFeedTokens.textInverse,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        hintText: widget.postType == 'scene'
                            ? 'Give this scene a name'
                            : 'Give this piece a name',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _textDisabled,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: _horizontalInset),
                    child: _CreateDivider(),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                    child: TextField(
                      controller: _descriptionController,
                      maxLines: 4,
                      minLines: 3,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: HomeFeedTokens.textInverse,
                        height: 1.35,
                      ),
                      cursorColor: HomeFeedTokens.textInverse,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        hintText:
                            'Tell us what was happening in the studio. The more you share,\nthe further it travels.',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: _textSecondary,
                          height: 1.35,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: _horizontalInset),
                    child: _CreateDivider(),
                  ),
                  const SizedBox(height: 4),
                  _MetadataRow(
                    iconAsset: PostMediaAssets.createLocationIcon,
                    iconWidth: 12,
                    iconHeight: 16,
                    label: 'Location',
                    trailing: _selectedLocations.isNotEmpty
                        ? _selectedLocations.last.name
                        : null,
                    onTap: _openLocationPicker,
                  ),
                  if (_selectedLocations.isNotEmpty)
                    SizedBox(
                      height: 26,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(28, 4, 16, 4),
                        itemCount: _selectedLocations.length,
                        separatorBuilder: (context, _) =>
                            const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final location = _selectedLocations[index];
                          return _LocationChip(
                            label: location.name,
                            onRemove: () => setState(
                              () => _selectedLocations.removeAt(index),
                            ),
                          );
                        },
                      ),
                    ),
                  _MetadataRow(
                    iconAsset: PostMediaAssets.createMediumIcon,
                    iconWidth: 12,
                    iconHeight: 11,
                    label: 'Medium',
                    trailing: _mediumTrailing,
                    onTap: _openMediumPicker,
                  ),
                  _MetadataRow(
                    iconAsset: PostMediaAssets.createStyleIcon,
                    iconWidth: 12,
                    iconHeight: 12,
                    label: 'Style',
                    trailing: _styleTrailing,
                    onTap: _openStylePicker,
                  ),
                  _MetadataRow(
                    iconAsset: PostMediaAssets.createMaterialsIcon,
                    iconWidth: 12,
                    iconHeight: 11,
                    label: 'Materials used',
                    onTap: () {},
                  ),
                  _MetadataRow(
                    iconAsset: PostMediaAssets.createSeriesIcon,
                    iconWidth: 13,
                    iconHeight: 13,
                    label: 'Series',
                    onTap: () {},
                  ),
                  _MetadataRow(
                    iconAsset: PostMediaAssets.createScenesIcon,
                    iconWidth: 12,
                    iconHeight: 11,
                    label: 'Related scenes',
                    onTap: () {},
                  ),
                  _AiToolsRow(
                    value: _aiToolsUsed,
                    onChanged: (value) => setState(() => _aiToolsUsed = value),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, bottomInset + 16),
            child: Row(
              children: [
                _BottomButton(
                  label: 'Save',
                  backgroundColor: _neutral700,
                  textColor: HomeFeedTokens.textInverse,
                  width: 68,
                  onTap: () {},
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _BottomButton(
                    label: 'Create',
                    backgroundColor: _neutral300,
                    textColor: HomeFeedTokens.textPrimary,
                    onTap: () {},
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

class _CreateBanner extends StatelessWidget {
  const _CreateBanner({
    required this.topInset,
    required this.title,
    required this.onClose,
  });

  final double topInset;
  final String title;
  final VoidCallback onClose;

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
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: onClose,
                    behavior: HitTestBehavior.opaque,
                    child: SvgPicture.asset(
                      PostMediaAssets.createCloseIcon,
                      width: 14,
                      height: 14,
                    ),
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: HomeFeedTokens.textInverse,
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

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.imagePath,
    required this.transform,
    required this.onEdit,
  });

  static const _cardWidth = 200.0;
  static const _cardHeight = 266.0;
  static const _cardRadius = 8.0;

  final String imagePath;
  final PostImageTransform transform;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    Widget image = Image.asset(
      imagePath,
      width: _cardWidth,
      height: _cardHeight,
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

    return SizedBox(
      width: _cardWidth,
      height: _cardHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(_cardRadius),
            child: image,
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onEdit,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  PostMediaAssets.createPencilIcon,
                  width: 12,
                  height: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateDivider extends StatelessWidget {
  const _CreateDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.5,
      color: const Color(0xFF2E2C28),
    );
  }
}

class _MetadataRow extends StatelessWidget {
  const _MetadataRow({
    required this.iconAsset,
    required this.iconWidth,
    required this.iconHeight,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  final String iconAsset;
  final double iconWidth;
  final double iconHeight;
  final String label;
  final VoidCallback onTap;
  final String? trailing;

  static const _textSecondary = Color(0xFF8C8880);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          children: [
            SvgPicture.asset(
              iconAsset,
              width: iconWidth,
              height: iconHeight,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: HomeFeedTokens.textInverse,
                ),
              ),
            ),
            if (trailing != null) ...[
              Text(
                trailing!,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: _textSecondary,
                ),
              ),
              const SizedBox(width: 10),
            ],
            SvgPicture.asset(
              PostMediaAssets.createChevronRight,
              width: 8,
              height: 13,
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationChip extends StatelessWidget {
  const _LocationChip({
    required this.label,
    this.onRemove,
  });

  static const _neutral700 = Color(0xFF4A4843);
  static const _textSecondary = Color(0xFF8C8880);

  final String label;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRemove,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 18,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _neutral700,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w400,
            color: _textSecondary,
          ),
        ),
      ),
    );
  }
}

class _AiToolsRow extends StatelessWidget {
  const _AiToolsRow({
    required this.value,
    required this.onChanged,
  });

  static const _neutral700 = Color(0xFF4A4843);
  static const _neutral300 = Color(0xFFC8C5BC);

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(
        children: [
          SvgPicture.asset(
            PostMediaAssets.createAiToolsIcon,
            width: 12,
            height: 12,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'AI tools used',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: HomeFeedTokens.textInverse,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => onChanged(!value),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 30,
              height: 14,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: _neutral700,
                borderRadius: BorderRadius.circular(100),
              ),
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: value ? HomeFeedTokens.textInverse : _neutral300,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomButton extends StatelessWidget {
  const _BottomButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
    this.width,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          width: width,
          height: 32,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
