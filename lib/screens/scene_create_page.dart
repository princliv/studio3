import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/post_material_options.dart';
import '../data/post_location_options.dart';
import '../data/post_picker_options.dart';
import '../data/post_media_assets.dart';
import '../models/piece_summary.dart';
import '../models/post_image_transform.dart';
import '../services/auth_session.dart';
import '../services/api_exception.dart';
import '../services/piece_service.dart';
import '../services/post_publish_service.dart';
import '../theme/home_feed_tokens.dart';
import '../widgets/choose_location_sheet.dart';
import '../widgets/create_flow/create_flow_widgets.dart';
import '../widgets/post_create_option_sheet.dart';
import '../widgets/post_crop_preview.dart';
import '../utils/payout_setup.dart';
import '../widgets/uploading_dialog.dart';
import 'add_materials_page.dart';

/// Scene details step — independent of the piece create flow.
class SceneCreatePage extends StatefulWidget {
  const SceneCreatePage({
    super.key,
    required this.imagePaths,
    required this.transforms,
    required this.previewImageIndex,
    required this.onClose,
    this.onEdit,
    this.mediaKind = 'image',
    this.videoPath,
    this.videoThumbnailBytes,
  });

  final List<String> imagePaths;
  final List<PostImageTransform> transforms;
  final int previewImageIndex;
  final VoidCallback onClose;
  final VoidCallback? onEdit;
  final String mediaKind;
  final String? videoPath;
  final Uint8List? videoThumbnailBytes;

  @override
  State<SceneCreatePage> createState() => _SceneCreatePageState();
}

class _SceneCreatePageState extends State<SceneCreatePage> {
  static const _neutral700 = Color(0xFF4A4843);
  static const _neutral300 = Color(0xFFC8C5BC);

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _aiToolsUsed = false;
  bool _isProcess = false;
  bool _publishing = false;
  bool _reviewMode = false;
  PostLocationOption? _selectedLocation;
  String? _selectedMediumId;
  final Set<String> _selectedStyleIds = {};
  final List<PostMaterialOption> _selectedMaterials = [];
  String? _linkedPieceId;
  String? _linkedPieceLabel;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _openLocationPicker() {
    ChooseLocationSheet.show(
      context,
      onLocationSelected: (location) {
        setState(() => _selectedLocation = location);
      },
    );
  }

  void _openMediumPicker() {
    PostCreateOptionSheet.show(
      context,
      title: 'Medium',
      subtitle: 'Choose one',
      searchHint: 'Search medium',
      options: PostMediumOptions.all,
      selectedIds: _selectedMediumId != null ? {_selectedMediumId!} : const {},
      mode: PostPickerSelectionMode.singleRadio,
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
      title: 'Style',
      subtitle: 'Choose up to 3',
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

  Future<void> _openMaterialsPage() async {
    final result = await Navigator.push<List<PostMaterialOption>>(
      context,
      MaterialPageRoute<List<PostMaterialOption>>(
        builder: (_) => AddMaterialsPage(
          initialMaterials: List<PostMaterialOption>.from(_selectedMaterials),
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _selectedMaterials
          ..clear()
          ..addAll(result);
      });
    }
  }

  Future<void> _openLinkedPiecePicker() async {
    final username = AuthSession.instance.user?.username;
    if (username == null || username.isEmpty) return;
    List<PieceSummary> pieces;
    try {
      pieces = await PieceService.instance.getUserPieces(username);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load your pieces')),
      );
      return;
    }
    if (!mounted) return;
    final selected = await showModalBottomSheet<PieceSummary?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) =>
          _LinkedPiecePickerSheet(pieces: pieces, selectedId: _linkedPieceId),
    );
    if (!mounted) return;
    setState(() {
      _linkedPieceId = selected?.id;
      _linkedPieceLabel = selected?.title;
    });
  }

  PostDraft _buildDraft() {
    return PostDraft(
      postType: 'scene',
      imagePaths: widget.imagePaths,
      mediaKind: widget.mediaKind,
      videoPath: widget.videoPath,
      videoThumbnailBytes: widget.videoThumbnailBytes,
      title: _nameController.text,
      description: _descriptionController.text,
      mediumId: _selectedMediumId,
      styleTags: _selectedStyleIds.toList(),
      location: _selectedLocation?.displayName,
      materials: List<PostMaterialOption>.from(_selectedMaterials),
      transforms: widget.transforms,
      previewImageIndex: widget.previewImageIndex,
      aiDisclosed: _aiToolsUsed,
      linkedPieceId: _linkedPieceId,
      isProcess: _isProcess,
      isForSale: false,
    );
  }

  Future<void> _publish(PostDraft draft) async {
    setState(() => _publishing = true);
    showUploadingDialog(context, message: 'Publishing…');
    try {
      await PostPublishService.instance.publish(draft);
      if (!mounted) return;
      hideUploadingDialog(context);
      Navigator.of(context).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.white,
          elevation: 6,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFF3BA55D),
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Published successfully',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: HomeFeedTokens.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      hideUploadingDialog(context);
      final message = e is ApiException ? e.message : e.toString();
      if (e is ApiException && isPayoutSetupRequiredMessage(e.message)) {
        await openPayoutSetup(context);
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  void _onSave() {
    _publish(_buildDraft().copyWith(status: 'draft'));
  }

  void _onNext() {
    setState(() => _reviewMode = true);
  }

  void _onBackToEdit() {
    setState(() => _reviewMode = false);
  }

  void _onCreate() {
    _publish(_buildDraft());
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return PopScope(
      canPop: !_reviewMode,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _onBackToEdit();
      },
      child: Scaffold(
        backgroundColor: HomeFeedTokens.background,
        body: Column(
          children: [
            CreateFlowBanner(
              topInset: topInset,
              title: 'Create scene',
              onClose: widget.onClose,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 16),
                child: _reviewMode ? _buildSummary() : _buildEditableForm(),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, bottomInset + 16),
              child: Row(
                children: [
                  CreateFlowBottomButton(
                    label: _reviewMode ? 'Back' : 'Save',
                    backgroundColor: _neutral700,
                    textColor: HomeFeedTokens.textInverse,
                    width: 68,
                    onTap: _publishing
                        ? null
                        : (_reviewMode ? _onBackToEdit : _onSave),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CreateFlowBottomButton(
                      label: _reviewMode ? 'Publish' : 'Next',
                      backgroundColor: _neutral300,
                      textColor: HomeFeedTokens.textPrimary,
                      onTap: _publishing
                          ? null
                          : (_reviewMode ? _onCreate : _onNext),
                      child: _publishing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 13),
        Center(
          child: widget.mediaKind == 'video'
              ? _VideoPreviewCard(
                  thumbnailBytes: widget.videoThumbnailBytes,
                  onEdit: widget.onEdit,
                )
              : (widget.imagePaths.isNotEmpty && widget.transforms.isNotEmpty)
              ? _PreviewCard(
                  imagePath: widget.imagePaths[widget.previewImageIndex],
                  transform: widget.transforms[widget.previewImageIndex],
                  onEdit: widget.onEdit,
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: CreateFlowTextField(
            controller: _nameController,
            hint: 'Give this scene a name',
          ),
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: createFlowHorizontalInset),
          child: CreateFlowDivider(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: CreateFlowTextField(
            controller: _descriptionController,
            hint:
                'Tell us what was happening in the studio. The more you share,\nthe further it travels.',
            style: CreateFlowTextFieldStyle.body,
            maxLines: 4,
            minLines: 3,
          ),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: createFlowHorizontalInset),
          child: CreateFlowDivider(),
        ),
        const SizedBox(height: 4),
        CreateFlowMetadataRow(
          iconAsset: PostMediaAssets.createLocationIcon,
          iconWidth: 12,
          iconHeight: 16,
          label: 'Location',
          trailing: _selectedLocation?.name,
          onTap: _openLocationPicker,
        ),
        CreateFlowMetadataRow(
          iconAsset: PostMediaAssets.createMediumIcon,
          iconWidth: 12,
          iconHeight: 11,
          label: 'Medium',
          trailing: _mediumTrailing,
          onTap: _openMediumPicker,
        ),
        CreateFlowMetadataRow(
          iconAsset: PostMediaAssets.createStyleIcon,
          iconWidth: 12,
          iconHeight: 12,
          label: 'Style',
          trailing: _styleTrailing,
          onTap: _openStylePicker,
        ),
        CreateFlowMetadataRow(
          iconAsset: PostMediaAssets.createMaterialsIcon,
          iconWidth: 12,
          iconHeight: 11,
          label: 'Materials used',
          countBadge: _selectedMaterials.isEmpty
              ? null
              : _selectedMaterials.length,
          onTap: _openMaterialsPage,
        ),
        CreateFlowMetadataRow(
          iconAsset: PostMediaAssets.createScenesIcon,
          iconWidth: 12,
          iconHeight: 11,
          label: 'Link to piece',
          trailing: _linkedPieceLabel,
          onTap: _openLinkedPiecePicker,
        ),
        CreateFlowToggleRow(
          label: 'Process / work-in-progress scene',
          value: _isProcess,
          onChanged: (value) => setState(() => _isProcess = value),
        ),
        CreateFlowToggleRow(
          label: 'AI tools used',
          iconAsset: PostMediaAssets.createAiToolsIcon,
          value: _aiToolsUsed,
          onChanged: (value) => setState(() => _aiToolsUsed = value),
        ),
      ],
    );
  }

  Widget _buildSummary() {
    final materialsLabel = _selectedMaterials.isEmpty
        ? null
        : _selectedMaterials.map((m) => m.name).join(', ');
    final title = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 13),
        Center(
          child: widget.mediaKind == 'video'
              ? _VideoPreviewCard(thumbnailBytes: widget.videoThumbnailBytes)
              : (widget.imagePaths.isNotEmpty && widget.transforms.isNotEmpty)
              ? _PreviewCard(
                  imagePath: widget.imagePaths[widget.previewImageIndex],
                  transform: widget.transforms[widget.previewImageIndex],
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 24),
        if (title.isNotEmpty) _summaryRow('Name', title),
        if (description.isNotEmpty) _summaryRow('Description', description),
        const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: createFlowHorizontalInset,
            vertical: 8,
          ),
          child: CreateFlowDivider(),
        ),
        if (_selectedLocation != null)
          _summaryRow('Location', _selectedLocation!.name),
        if (_mediumTrailing != null) _summaryRow('Medium', _mediumTrailing!),
        if (_styleTrailing != null) _summaryRow('Style', _styleTrailing!),
        if (materialsLabel != null) _summaryRow('Materials', materialsLabel),
        if (_linkedPieceLabel != null)
          _summaryRow('Link to piece', _linkedPieceLabel!),
        if (_isProcess) _summaryRow('Process / work-in-progress', 'Yes'),
        if (_aiToolsUsed) _summaryRow('AI tools used', 'Yes'),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF8C8880),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: HomeFeedTokens.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoPreviewCard extends StatelessWidget {
  const _VideoPreviewCard({this.thumbnailBytes, this.onEdit});

  static const _cardWidth = 200.0;
  static const _cardHeight = 266.0;
  static const _cardRadius = 8.0;

  final Uint8List? thumbnailBytes;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _cardWidth,
      height: _cardHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(_cardRadius),
            child: ColoredBox(
              color: const Color(0xFF4A4843),
              child: Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  if (thumbnailBytes != null)
                    Image.memory(
                      thumbnailBytes!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox.shrink(),
                    ),
                  const Icon(
                    Icons.play_circle_fill,
                    color: Colors.white,
                    size: 56,
                  ),
                ],
              ),
            ),
          ),
          if (onEdit != null)
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

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.imagePath,
    required this.transform,
    this.onEdit,
  });

  static const _cardWidth = 200.0;
  static const _cardRadius = 8.0;

  final String imagePath;
  final PostImageTransform transform;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _cardWidth,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          PostCropPreview(
            imagePath: imagePath,
            transform: transform,
            borderRadius: BorderRadius.circular(_cardRadius),
          ),
          if (onEdit != null)
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

class _LinkedPiecePickerSheet extends StatelessWidget {
  const _LinkedPiecePickerSheet({required this.pieces, this.selectedId});

  final List<PieceSummary> pieces;
  final String? selectedId;

  @override
  Widget build(BuildContext context) {
    final safeAreaBottom = MediaQuery.paddingOf(context).bottom;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: DraggableScrollableSheet(
        initialChildSize: 0.45,
        minChildSize: 0.32,
        maxChildSize: 0.88,
        builder: (context, scrollController) {
          return DecoratedBox(
            decoration: const BoxDecoration(
              color: HomeFeedTokens.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC8C5BC),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text(
                    'Link to piece',
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: HomeFeedTokens.textPrimary,
                    ),
                  ),
                ),
                Expanded(
                  child: pieces.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'You don\'t have any pieces yet.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFF8C8880),
                              ),
                            ),
                          ),
                        )
                      : ListView(
                          controller: scrollController,
                          padding: EdgeInsets.fromLTRB(
                            8,
                            0,
                            8,
                            safeAreaBottom + 16,
                          ),
                          children: [
                            _LinkedPieceTile(
                              title: 'None',
                              selected: selectedId == null,
                              onTap: () => Navigator.pop(context),
                            ),
                            for (final piece in pieces)
                              _LinkedPieceTile(
                                title: piece.title,
                                selected: selectedId == piece.id,
                                onTap: () => Navigator.pop(context, piece),
                              ),
                          ],
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LinkedPieceTile extends StatelessWidget {
  const _LinkedPieceTile({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected
                    ? HomeFeedTokens.textPrimary
                    : HomeFeedTokens.textSecondary,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: HomeFeedTokens.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
