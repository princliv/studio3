import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../data/post_material_options.dart';
import '../data/post_location_options.dart';
import '../data/post_picker_options.dart';
import '../data/post_media_assets.dart';
import '../models/listing_details.dart';
import '../models/post_image_transform.dart';
import '../services/auth_session.dart';
import '../services/api_exception.dart';
import '../services/post_publish_service.dart';
import '../theme/home_feed_tokens.dart';
import '../widgets/choose_location_sheet.dart';
import '../widgets/create_flow/create_flow_widgets.dart';
import '../widgets/create_flow/listing_details_form.dart';
import '../widgets/create_flow/series_picker_sheet.dart';
import '../widgets/post_create_option_sheet.dart';
import '../widgets/post_crop_preview.dart';
import '../widgets/seller_mode_required_dialog.dart';
import 'add_materials_page.dart';

/// Add Piece / Scene details — posting flow step (Figma 1995:1486).
class PostCreatePage extends StatefulWidget {
  const PostCreatePage({
    super.key,
    required this.postType,
    required this.selectedCellIndices,
    required this.imagePaths,
    required this.transforms,
    required this.previewImageIndex,
    required this.onClose,
    this.onEdit,
    this.mediaKind = 'image',
    this.videoPath,
  });

  final String postType;
  final List<int> selectedCellIndices;
  final List<String> imagePaths;
  final List<PostImageTransform> transforms;
  final int previewImageIndex;
  final VoidCallback onClose;
  final VoidCallback? onEdit;
  final String mediaKind;
  final String? videoPath;

  @override
  State<PostCreatePage> createState() => _PostCreatePageState();
}

class _PostCreatePageState extends State<PostCreatePage> {
  static const _neutral700 = Color(0xFF4A4843);
  static const _neutral300 = Color(0xFFC8C5BC);

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _listingFormKey = GlobalKey<ListingDetailsFormState>();
  bool _aiToolsUsed = false;
  bool _publishing = false;
  bool _listForSale = false;
  final List<PostLocationOption> _selectedLocations = [];
  String? _selectedMediumId;
  final Set<String> _selectedStyleIds = {};
  final List<PostMaterialOption> _selectedMaterials = [];
  String? _selectedSeriesId;
  String? _newSeriesName;
  String? _seriesLabel;

  bool get _isPiece => widget.postType == 'piece';

  @override
  void initState() {
    super.initState();
    _listForSale = _isPiece && AuthSession.instance.sellerEnabled;
    AuthSession.instance.addListener(_onSessionChanged);
  }

  @override
  void dispose() {
    AuthSession.instance.removeListener(_onSessionChanged);
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onSessionChanged() {
    if (!mounted) return;
    if (_isPiece && AuthSession.instance.sellerEnabled && !_listForSale) {
      setState(() => _listForSale = true);
    }
  }

  Future<void> _onListForSaleChanged(bool value) async {
    if (!value) {
      setState(() {
        _listForSale = false;
        _listingFormKey.currentState?.clear();
      });
      return;
    }

    if (AuthSession.instance.sellerEnabled) {
      setState(() => _listForSale = true);
      return;
    }

    final switchToSeller = await showSellerModeRequiredDialog(context);
    if (!mounted) return;
    if (switchToSeller == true) {
      await Navigator.pushNamed(context, '/profile-settings');
      if (!mounted) return;
      if (AuthSession.instance.sellerEnabled) {
        setState(() => _listForSale = true);
      }
    }
  }

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

  Future<void> _openMaterialsPage() async {
    final result = await Navigator.push<List<PostMaterialOption>>(
      context,
      MaterialPageRoute<List<PostMaterialOption>>(
        builder: (_) => AddMaterialsPage(
          previewImagePath: widget.imagePaths[widget.previewImageIndex],
          transform: widget.transforms[widget.previewImageIndex],
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

  Future<void> _openSeriesPicker() async {
    final result = await SeriesPickerSheet.show(
      context,
      selectedSeriesId: _selectedSeriesId,
      newSeriesName: _newSeriesName,
    );
    if (result == null || !mounted) return;
    setState(() {
      if (!result.hasSelection) {
        _selectedSeriesId = null;
        _newSeriesName = null;
        _seriesLabel = null;
      } else {
        _selectedSeriesId = result.selectedSeriesId;
        _newSeriesName = result.newSeriesName;
        _seriesLabel = result.displayLabel;
      }
    });
  }

  String get _title =>
      widget.postType == 'scene' ? 'Create scene' : 'Create piece';

  PostDraft _buildDraft() {
    ListingDetails? listingDetails;
    if (_isPiece && _listForSale) {
      listingDetails = _listingFormKey.currentState?.buildListingDetails();
    }

    return PostDraft(
      postType: widget.postType,
      imagePaths: widget.imagePaths,
      mediaKind: widget.mediaKind,
      videoPath: widget.videoPath,
      title: _nameController.text,
      description: _descriptionController.text,
      mediumId: _selectedMediumId,
      styleIds: _selectedStyleIds.toList(),
      locations: List<PostLocationOption>.from(_selectedLocations),
      materials: List<PostMaterialOption>.from(_selectedMaterials),
      listingDetails: listingDetails,
      selectedSeriesId: _selectedSeriesId,
      newSeriesName: _newSeriesName,
      transforms: widget.transforms,
      previewImageIndex: widget.previewImageIndex,
    );
  }

  Future<void> _publish(PostDraft draft) async {
    setState(() => _publishing = true);
    try {
      await PostPublishService.instance.publish(draft);
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
      final message = draft.listingDetails != null
          ? 'Piece listed for sale'
          : 'Published successfully';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;
      final message = e is ApiException ? e.message : e.toString();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  void _onCreate() {
    if (_isPiece && _listForSale) {
      final form = _listingFormKey.currentState;
      if (form == null || !form.isPriceValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a valid price to list for sale')),
        );
        return;
      }
    }
    _publish(_buildDraft());
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          CreateFlowBanner(
            topInset: topInset,
            title: _title,
            onClose: widget.onClose,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 13),
                  Center(
                    child: widget.mediaKind == 'video'
                        ? _VideoPreviewCard(videoPath: widget.videoPath)
                        : _PreviewCard(
                            imagePath: widget.imagePaths[widget.previewImageIndex],
                            transform: widget.transforms[widget.previewImageIndex],
                            onEdit: widget.onEdit,
                          ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: CreateFlowTextField(
                      controller: _nameController,
                      hint: widget.postType == 'scene'
                          ? 'Give this scene a name'
                          : 'Give this piece a name',
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
                          return CreateFlowLocationChip(
                            label: location.name,
                            onRemove: () => setState(
                              () => _selectedLocations.removeAt(index),
                            ),
                          );
                        },
                      ),
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
                  if (_isPiece) ...[
                    CreateFlowMetadataRow(
                      iconAsset: PostMediaAssets.createSeriesIcon,
                      iconWidth: 13,
                      iconHeight: 13,
                      label: 'Series',
                      trailing: _seriesLabel,
                      onTap: _openSeriesPicker,
                    ),
                  ],
                  CreateFlowMetadataRow(
                    iconAsset: PostMediaAssets.createScenesIcon,
                    iconWidth: 12,
                    iconHeight: 11,
                    label: 'Related scenes',
                    onTap: () {},
                  ),
                  CreateFlowToggleRow(
                    label: 'AI tools used',
                    iconAsset: PostMediaAssets.createAiToolsIcon,
                    value: _aiToolsUsed,
                    onChanged: (value) => setState(() => _aiToolsUsed = value),
                  ),
                  if (_isPiece) ...[
                    CreateFlowToggleRow(
                      label: 'List for sale',
                      value: _listForSale,
                      onChanged: _onListForSaleChanged,
                    ),
                    if (_listForSale)
                      ListingDetailsForm(key: _listingFormKey),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, bottomInset + 16),
            child: Row(
              children: [
                CreateFlowBottomButton(
                  label: 'Save',
                  backgroundColor: _neutral700,
                  textColor: HomeFeedTokens.textInverse,
                  width: 68,
                  onTap: _publishing ? null : _onCreate,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CreateFlowBottomButton(
                    label: 'Publish',
                    backgroundColor: _neutral300,
                    textColor: HomeFeedTokens.textPrimary,
                    onTap: _publishing ? null : _onCreate,
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
    );
  }
}

class _VideoPreviewCard extends StatelessWidget {
  const _VideoPreviewCard({this.videoPath});

  static const _cardWidth = 200.0;
  static const _cardHeight = 266.0;
  static const _cardRadius = 8.0;

  final String? videoPath;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _cardWidth,
      height: _cardHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_cardRadius),
        child: ColoredBox(
          color: const Color(0xFF4A4843),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (videoPath != null)
                Opacity(
                  opacity: 0.35,
                  child: Image.file(
                    File(videoPath!),
                    width: _cardWidth,
                    height: _cardHeight,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox.shrink(),
                  ),
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
