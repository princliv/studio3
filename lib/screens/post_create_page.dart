import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:google_fonts/google_fonts.dart';

import '../data/post_material_options.dart';
import '../data/post_location_options.dart';
import '../data/post_picker_options.dart';
import '../data/post_media_assets.dart';
import '../models/listing_details.dart';
import '../models/piece_summary.dart';
import '../models/post_summary.dart';
import '../models/post_image_transform.dart';
import '../services/auth_session.dart';
import '../services/api_exception.dart';
import '../services/piece_service.dart';
import '../services/post_service.dart';
import '../services/post_publish_service.dart';
import '../theme/home_feed_tokens.dart';
import '../widgets/choose_location_sheet.dart';
import '../widgets/create_flow/create_flow_widgets.dart';
import '../widgets/create_flow/listing_details_form.dart';
import '../widgets/create_flow/piece_availability_form.dart';
import '../widgets/create_flow/piece_details_form.dart';
import '../widgets/create_flow/related_scenes_picker_page.dart';
import '../widgets/create_flow/series_picker_sheet.dart';
import '../widgets/post_create_option_sheet.dart';
import '../widgets/post_crop_preview.dart';
import '../utils/payout_setup.dart';
import '../widgets/uploading_dialog.dart';
import 'add_materials_page.dart';

/// Add Piece / Scene details — posting flow step (Figma 1995:1486).
class PostCreatePage extends StatefulWidget {
  const PostCreatePage({
    super.key,
    required this.postType,
    required this.imagePaths,
    required this.transforms,
    required this.previewImageIndex,
    required this.onClose,
    this.onEdit,
    this.mediaKind = 'image',
    this.videoPath,
    this.videoThumbnailBytes,
  });

  final String postType;
  final List<String> imagePaths;
  final List<PostImageTransform> transforms;
  final int previewImageIndex;
  final VoidCallback onClose;
  final VoidCallback? onEdit;
  final String mediaKind;
  final String? videoPath;
  final Uint8List? videoThumbnailBytes;

  @override
  State<PostCreatePage> createState() => _PostCreatePageState();
}

class _PostCreatePageState extends State<PostCreatePage> {
  static const _neutral700 = Color(0xFF4A4843);
  static const _neutral300 = Color(0xFFC8C5BC);

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _pieceDetailsKey = GlobalKey<PieceDetailsFormState>();
  final _listingFormKey = GlobalKey<ListingDetailsFormState>();
  bool _aiToolsUsed = false;
  bool _isProcess = false;
  bool _publishing = false;
  bool _listForSale = false;
  bool? _forSaleChoice;
  String? _sellMode;
  int _auctionDays = 3;
  int _pieceTab = 0;
  int _unlockedTab = 0;
  bool _reviewMode = false;
  PostLocationOption? _selectedLocation;
  String? _selectedMediumId;
  final Set<String> _selectedStyleIds = {};
  final List<PostMaterialOption> _selectedMaterials = [];
  String? _selectedSeriesId;
  String? _newSeriesName;
  String? _seriesLabel;
  String? _linkedPieceId;
  String? _linkedPieceLabel;
  final Set<String> _relatedSceneIds = {};

  bool get _isPiece => widget.postType == 'piece';

  @override
  void initState() {
    super.initState();
    _listForSale = false;
    _priceController.addListener(_onPriceChanged);
    _nameController.addListener(_onPriceChanged);
  }

  void _onPriceChanged() {
    if (_isPiece) setState(() {});
  }

  @override
  void dispose() {
    _priceController.removeListener(_onPriceChanged);
    _nameController.removeListener(_onPriceChanged);
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _onListForSaleChanged(bool value) async {
    if (!value) {
      setState(() {
        _listForSale = false;
        _listingFormKey.currentState?.clear();
      });
      return;
    }

    final allowed = await ensureCanListForSale(context);
    if (!mounted) return;
    if (allowed) setState(() => _listForSale = true);
  }

  Future<void> _onPieceForSaleChanged(bool value) async {
    if (!value) {
      setState(() {
        _forSaleChoice = false;
        _listForSale = false;
        _sellMode = null;
      });
      return;
    }
    final allowed = await ensureCanListForSale(context);
    if (!mounted) return;
    if (allowed) {
      setState(() {
        _forSaleChoice = true;
        _listForSale = true;
      });
    }
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

  String? get _pieceStyleTrailing {
    if (_selectedStyleIds.isEmpty) return null;
    final names = _selectedStyleIds
        .map((id) => PostStyleOptions.byId(id)?.name)
        .whereType<String>()
        .toList();
    if (names.isEmpty) return null;
    return names.join(', ');
  }

  String? get _pieceMaterialsTrailing {
    if (_selectedMaterials.isEmpty) return null;
    return '${_selectedMaterials.length} added';
  }

  String? get _relatedScenesTrailing {
    if (_relatedSceneIds.isEmpty) return null;
    return '${_relatedSceneIds.length} linked';
  }

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

  Future<void> _openRelatedScenesPicker() async {
    final username = AuthSession.instance.user?.username;
    if (username == null || username.isEmpty) return;
    List<PostSummary> scenes;
    try {
      scenes = await PostService.instance.getUserPosts(username);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load your scenes')),
      );
      return;
    }
    if (!mounted) return;
    final selected = await RelatedScenesPickerPage.show(
      context,
      scenes: scenes,
      selectedIds: Set<String>.from(_relatedSceneIds),
    );
    if (selected == null || !mounted) return;
    setState(() {
      _relatedSceneIds
        ..clear()
        ..addAll(selected);
    });
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
    if (_isPiece) {
      listingDetails = _pieceDetailsKey.currentState?.buildListingDetails() ??
          _listingFormKey.currentState?.buildListingDetails();
      final priceUsd = double.tryParse(_priceController.text.trim());
      if (listingDetails != null) {
        listingDetails = listingDetails.copyWith(
          priceUsd: priceUsd ?? listingDetails.priceUsd,
          listingType: _listForSale ? _sellMode : listingDetails.listingType,
          auctionDurationDays: _listForSale && _sellMode == 'auction'
              ? _auctionDays
              : listingDetails.auctionDurationDays,
          location: _selectedLocation?.name ?? listingDetails.location,
        );
      } else if (_listForSale) {
        listingDetails = ListingDetails(
          priceUsd: priceUsd,
          listingType: _sellMode,
          auctionDurationDays: _sellMode == 'auction' ? _auctionDays : null,
        );
      }
    }

    return PostDraft(
      postType: widget.postType,
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
      listingDetails: listingDetails,
      selectedSeriesId: _selectedSeriesId,
      newSeriesName: _newSeriesName,
      transforms: widget.transforms,
      previewImageIndex: widget.previewImageIndex,
      aiDisclosed: _aiToolsUsed,
      linkedPieceId: _linkedPieceId,
      relatedSceneIds: _relatedSceneIds.toList(),
      isProcess: _isProcess,
      isForSale: _isPiece && _listForSale,
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
      final message = draft.isForSale
          ? 'Piece listed for sale'
          : 'Published successfully';
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
                  message,
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

  bool get _priceValid {
    final price = double.tryParse(_priceController.text.trim());
    return price != null && price > 0;
  }

  bool get _detailsContinueEnabled {
    if (_nameController.text.trim().isEmpty) return false;
    if (!_listForSale) return true;
    return _selectedMediumId != null &&
        (_pieceDetailsKey.currentState?.hasDimensions ?? false);
  }

  bool get _availabilityComplete {
    if (_forSaleChoice == false) return true;
    if (_forSaleChoice != true) return false;
    if (_sellMode == 'fixed') return _priceValid;
    if (_sellMode == 'auction') {
      return _priceValid &&
          _auctionDays >= PieceAvailabilityForm.minAuctionDays &&
          _auctionDays <= PieceAvailabilityForm.maxAuctionDays;
    }
    return false;
  }

  bool _validate() {
    if (_isPiece && _listForSale) {
      if (!_priceValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a valid price to list for sale')),
        );
        return false;
      }
      if (_sellMode == 'auction' &&
          (_auctionDays < PieceAvailabilityForm.minAuctionDays ||
              _auctionDays > PieceAvailabilityForm.maxAuctionDays)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Auction duration must be 3–14 days')),
        );
        return false;
      }
    }
    return true;
  }

  bool _validateDetailsForContinue() {
    if (!_isPiece || !_listForSale) return true;
    if (_selectedMediumId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a medium to list for sale')),
      );
      return false;
    }
    final form = _pieceDetailsKey.currentState;
    if (form == null || !form.hasDimensions) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter width and height to list for sale')),
      );
      return false;
    }
    return true;
  }

  void _onSave() {
    if (!_validate()) return;
    _publish(_buildDraft().copyWith(status: 'draft'));
  }

  void _onNext() {
    if (!_validate()) return;
    setState(() => _reviewMode = true);
  }

  void _onBackToEdit() {
    setState(() => _reviewMode = false);
  }

  void _onCreate() {
    _publish(_buildDraft());
  }

  void _onPieceBannerBack() {
    if (_pieceTab > 0) {
      setState(() => _pieceTab -= 1);
      return;
    }
    (widget.onEdit ?? widget.onClose)();
  }

  void _onPieceContinue() {
    if (_pieceTab == 0) {
      if (!_availabilityComplete) return;
      setState(() {
        _pieceTab = 1;
        if (_unlockedTab < 1) _unlockedTab = 1;
      });
      return;
    }
    if (_pieceTab == 1) {
      if (!_validateDetailsForContinue()) return;
      setState(() {
        _pieceTab = 2;
        _unlockedTab = 2;
      });
      return;
    }
    _onCreate();
  }

  @override
  Widget build(BuildContext context) {
    if (_isPiece) return _buildPieceFlow(context);
    return _buildSceneFlow(context);
  }

  Widget _buildSceneFlow(BuildContext context) {
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
            title: _title,
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

  Widget _buildPieceFlow(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final continueEnabled = _pieceTab == 0
        ? _availabilityComplete
        : _pieceTab == 1
            ? _detailsContinueEnabled
            : !_publishing;
    final ctaLabel = _pieceTab == 2 ? 'Publish' : 'Save and continue';

    return PopScope(
      canPop: _pieceTab == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _onPieceBannerBack();
      },
      child: Scaffold(
        backgroundColor: HomeFeedTokens.background,
        body: Column(
          children: [
            CreateFlowBanner(
              topInset: topInset,
              title: 'Piece',
              onClose: _onPieceBannerBack,
              useBackChevron: true,
              height: 53,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildPieceCoverAndTabs(),
                    if (_pieceTab == 0)
                      PieceAvailabilityForm(
                        forSale: _forSaleChoice,
                        sellMode: _sellMode,
                        auctionDays: _auctionDays,
                        priceController: _priceController,
                        onForSaleChanged: _onPieceForSaleChanged,
                        onSellModeChanged: (mode) {
                          setState(() => _sellMode = mode);
                        },
                        onAuctionDaysChanged: (days) {
                          setState(() => _auctionDays = days);
                        },
                      ),
                    Visibility(
                      visible: _pieceTab == 1,
                      maintainState: true,
                      maintainAnimation: true,
                      child: PieceDetailsForm(
                        key: _pieceDetailsKey,
                        titleController: _nameController,
                        descriptionController: _descriptionController,
                        locationTrailing: _selectedLocation?.name,
                        mediumTrailing: _mediumTrailing,
                        styleTrailing: _pieceStyleTrailing,
                        materialsTrailing: _pieceMaterialsTrailing,
                        seriesTrailing: _seriesLabel,
                        relatedScenesTrailing: _relatedScenesTrailing,
                        onLocation: _openLocationPicker,
                        onMedium: _openMediumPicker,
                        onStyle: _openStylePicker,
                        onMaterials: _openMaterialsPage,
                        onSeries: _openSeriesPicker,
                        onRelatedScenes: _openRelatedScenesPicker,
                        onChanged: () {
                          if (mounted) setState(() {});
                        },
                      ),
                    ),
                    if (_pieceTab == 2)
                      _buildSummary(includePreview: false),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10, 24, 10, bottomInset + 24),
              child: Opacity(
                opacity: continueEnabled && !_publishing ? 1 : 0.4,
                child: CreateFlowBottomButton(
                  label: ctaLabel,
                  height: 40,
                  backgroundColor: HomeFeedTokens.neutral800,
                  textColor: HomeFeedTokens.textInverse,
                  onTap: _publishing || !continueEnabled
                      ? null
                      : _onPieceContinue,
                  child: _publishing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: HomeFeedTokens.textInverse,
                          ),
                        )
                      : Text(
                          ctaLabel,
                          style: GoogleFonts.geist(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: HomeFeedTokens.textInverse,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieceCoverAndTabs() {
    const tabLabels = ['Availability', 'Details', 'Review'];
    return Column(
      children: [
        const SizedBox(height: 11),
        Center(
          child: _PieceCoverPreview(
            imagePath: widget.imagePaths[widget.previewImageIndex],
            transform: widget.transforms[widget.previewImageIndex],
            onEdit: widget.onEdit,
            counterLabel:
                '${widget.previewImageIndex + 1}/${widget.imagePaths.length}',
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _pieceTabButton(
                    index: 0,
                    label: tabLabels[0],
                    alignment: Alignment.centerLeft,
                  ),
                  _pieceTabButton(
                    index: 1,
                    label: tabLabels[1],
                    alignment: Alignment.center,
                  ),
                  _pieceTabButton(
                    index: 2,
                    label: tabLabels[2],
                    alignment: Alignment.centerRight,
                  ),
                ],
              ),
              const Positioned(
                left: -24,
                right: -24,
                bottom: 0,
                child: ColoredBox(
                  color: Color(0xFFC8C5BC),
                  child: SizedBox(height: 0.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _pieceTabButton({
    required int index,
    required String label,
    required Alignment alignment,
  }) {
    final selected = index == _pieceTab;
    return Expanded(
      child: Align(
        alignment: alignment,
        child: GestureDetector(
          onTap: index <= _unlockedTab
              ? () => setState(() => _pieceTab = index)
              : null,
          behavior: HitTestBehavior.opaque,
          child: IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.geist(
                    fontSize: 13,
                    fontWeight:
                        selected ? FontWeight.w500 : FontWeight.w400,
                    color: selected
                        ? HomeFeedTokens.textPrimary
                        : HomeFeedTokens.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: selected
                        ? HomeFeedTokens.textPrimary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditableForm({
    bool includePreview = true,
    bool includeSaleToggle = true,
    bool includePrice = true,
  }) {
    return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (includePreview) ...[
                  const SizedBox(height: 13),
                  Center(
                    child: widget.mediaKind == 'video'
                        ? _VideoPreviewCard(
                            thumbnailBytes: widget.videoThumbnailBytes,
                            onEdit: widget.onEdit,
                          )
                        : _PreviewCard(
                            imagePath:
                                widget.imagePaths[widget.previewImageIndex],
                            transform:
                                widget.transforms[widget.previewImageIndex],
                            onEdit: widget.onEdit,
                          ),
                  ),
                  const SizedBox(height: 24),
                  ],
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
                    padding: EdgeInsets.symmetric(
                      horizontal: createFlowHorizontalInset,
                    ),
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
                    padding: EdgeInsets.symmetric(
                      horizontal: createFlowHorizontalInset,
                    ),
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
                  if (_isPiece) ...[
                    CreateFlowMetadataRow(
                      iconAsset: PostMediaAssets.createSeriesIcon,
                      iconWidth: 13,
                      iconHeight: 13,
                      label: 'Series',
                      trailing: _seriesLabel,
                      onTap: _openSeriesPicker,
                    ),
                    CreateFlowMetadataRow(
                      iconAsset: PostMediaAssets.createScenesIcon,
                      iconWidth: 12,
                      iconHeight: 11,
                      label: 'Related scenes',
                      onTap: () {},
                    ),
                  ] else ...[
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
                  ],
                  CreateFlowToggleRow(
                    label: 'AI tools used',
                    iconAsset: PostMediaAssets.createAiToolsIcon,
                    value: _aiToolsUsed,
                    onChanged: (value) => setState(() => _aiToolsUsed = value),
                  ),
                  if (_isPiece) ...[
                    if (includeSaleToggle)
                      CreateFlowToggleRow(
                        label: 'List for sale',
                        value: _listForSale,
                        onChanged: _onListForSaleChanged,
                      ),
                    ListingDetailsForm(
                      key: _listingFormKey,
                      showSaleFields: _listForSale,
                      includePrice: includePrice,
                    ),
                  ],
                ],
    );
  }

  /// Read-only recap of everything entered so far — reuses the same values
  /// as [_buildEditableForm] but as plain text (no fields, no chevrons, no
  /// toggles, no edit affordance on the preview image), so this reads as a
  /// summary to confirm rather than a second copy of the editable form.
  Widget _buildSummary({bool includePreview = true}) {
    ListingDetails? listingDetails;
    if (_isPiece) {
      listingDetails = _pieceDetailsKey.currentState?.buildListingDetails();
      if (_listForSale) {
        final priceUsd = double.tryParse(_priceController.text.trim());
        if (listingDetails != null && priceUsd != null) {
          listingDetails = listingDetails.copyWith(
            priceUsd: priceUsd,
            listingType: _sellMode,
            auctionDurationDays:
                _sellMode == 'auction' ? _auctionDays : null,
          );
        }
      }
    }
    final materialsLabel = _selectedMaterials.isEmpty
        ? null
        : _selectedMaterials.map((m) => m.name).join(', ');
    final title = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (includePreview) ...[
        const SizedBox(height: 13),
        Center(
          child: widget.mediaKind == 'video'
              ? _VideoPreviewCard(thumbnailBytes: widget.videoThumbnailBytes)
              : _PreviewCard(
                  imagePath: widget.imagePaths[widget.previewImageIndex],
                  transform: widget.transforms[widget.previewImageIndex],
                ),
        ),
        const SizedBox(height: 24),
        ],
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
        if (_isPiece) ...[
          if (_seriesLabel != null) _summaryRow('Series', _seriesLabel!),
          if (_relatedScenesTrailing != null)
            _summaryRow('Related scenes', _relatedScenesTrailing!),
        ] else ...[
          if (_linkedPieceLabel != null)
            _summaryRow('Link to piece', _linkedPieceLabel!),
          if (_isProcess) _summaryRow('Process / work-in-progress', 'Yes'),
        ],
        if (_aiToolsUsed) _summaryRow('AI tools used', 'Yes'),
        if (_isPiece && listingDetails?.dimensionsString != null)
          _summaryRow('Dimensions', listingDetails!.dimensionsString!),
        if (_isPiece && listingDetails?.yearCreated != null)
          _summaryRow('Year created', '${listingDetails!.yearCreated}'),
        if (_isPiece &&
            listingDetails?.framingMounting?.trim().isNotEmpty == true)
          _summaryRow(
            'Framing/mounting',
            listingDetails!.framingMounting!.trim(),
          ),
        if (_isPiece &&
            listingDetails?.handlingNotes?.trim().isNotEmpty == true)
          _summaryRow(
            'Handling notes',
            listingDetails!.handlingNotes!.trim(),
          ),
        if (_isPiece && !_listForSale && _forSaleChoice == false)
          _summaryRow('List for sale', 'No'),
        if (_isPiece && _listForSale) ...[
          _summaryRow('List for sale', 'Yes'),
          if (_sellMode == 'fixed') _summaryRow('Sale type', 'Fixed price'),
          if (_sellMode == 'auction') ...[
            _summaryRow('Sale type', 'Auction'),
            _summaryRow('Duration', '$_auctionDays days'),
          ],
          if (listingDetails?.priceUsd != null)
            _summaryRow(
              _sellMode == 'auction' ? 'Starting bid' : 'Price',
              '\$${listingDetails!.priceUsd!.toStringAsFixed(2)}',
            ),
        ],
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

class _PieceCoverPreview extends StatelessWidget {
  const _PieceCoverPreview({
    required this.imagePath,
    required this.transform,
    required this.counterLabel,
    this.onEdit,
  });

  static const _width = 156.0;
  static const _height = 197.0;
  static const _radius = 8.0;

  final String imagePath;
  final PostImageTransform transform;
  final String counterLabel;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _width,
      height: _height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          PostCropPreview(
            imagePath: imagePath,
            transform: transform,
            borderRadius: BorderRadius.circular(_radius),
            frameSize: const Size(_width, _height),
          ),
          if (onEdit != null)
            Positioned(
              top: 7,
              right: 11,
              child: GestureDetector(
                onTap: onEdit,
                behavior: HitTestBehavior.opaque,
                child: SvgPicture.asset(
                  PostMediaAssets.createCoverEditIcon,
                  width: 26,
                  height: 18,
                ),
              ),
            ),
          Positioned(
            left: 5,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0x4D231F1B),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Text(
                counterLabel,
                style: GoogleFonts.geist(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: HomeFeedTokens.textInverse,
                ),
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

/// Single-select picker for linking a scene to one of the user's pieces.
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
