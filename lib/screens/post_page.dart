import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../data/post_media_assets.dart';
import '../models/post_image_transform.dart';
import '../services/permission_service.dart';
import '../theme/home_feed_tokens.dart';
import '../widgets/permission_denied_sheet.dart';
import 'post_create_page.dart';
import 'post_edit_page.dart';

enum _PostFlowStep { gallery, edit, details }

/// Single-route posting flow: gallery → edit → details (Figma 1609:1975).
class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  static const _bannerHeight = 64.0;
  static const _bottomControlsOffset = 42.0;
  static const _maxSelection = 10;

  _PostFlowStep _step = _PostFlowStep.gallery;
  String _postType = 'piece';
  List<String>? _pickedImagePaths;
  String? _pickedVideoPath;
  final _picker = ImagePicker();

  List<String> _editImagePaths = [];
  List<PostImageTransform> _editTransforms = [];
  int _previewImageIndex = 0;

  @override
  void initState() {
    super.initState();
    // Open the system photo picker as soon as the flow starts, so the user
    // lands directly on their own photos rather than an empty screen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _openGalleryPicker();
    });
  }

  void _exitFlow() => Navigator.pop(context);

  void _onPostTypeChanged(String type) {
    if (type == _postType) return;
    setState(() {
      _postType = type;
      _pickedImagePaths = null;
      _pickedVideoPath = null;
    });
  }

  Future<bool> _ensureGalleryAccess({required bool forVideo}) async {
    final outcome = await PermissionService.instance
        .requestGalleryAccess(forVideo: forVideo);
    if (outcome == GalleryPermissionOutcome.granted) return true;
    if (outcome == GalleryPermissionOutcome.deniedForever && mounted) {
      await showPermissionDeniedSheet(
        context,
        title: forVideo ? 'Video access needed' : 'Photo access needed',
        message:
            'Enable ${forVideo ? 'video' : 'photo'} library access in Settings to continue.',
      );
    }
    return false;
  }

  /// System photo picker (Android Photo Picker / iOS PHPicker) — native OS
  /// UI, includes its own Recents/album browsing for free.
  Future<void> _openGalleryPicker() async {
    if (!await _ensureGalleryAccess(forVideo: false)) return;
    final images = await _picker.pickMultiImage(limit: _maxSelection);
    if (images.isEmpty || !mounted) return;
    setState(() {
      _pickedImagePaths = images.map((x) => x.path).toList();
      _pickedVideoPath = null;
    });
  }

  Future<void> _openCamera() async {
    final photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo == null || !mounted) return;
    setState(() {
      _pickedImagePaths = [photo.path];
      _pickedVideoPath = null;
    });
  }

  Future<void> _pickVideo() async {
    if (!await _ensureGalleryAccess(forVideo: true)) return;
    final video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video == null || !mounted) return;
    setState(() {
      _pickedVideoPath = video.path;
      _pickedImagePaths = null;
    });
  }

  void _goToEdit() {
    if (_pickedVideoPath != null) {
      _goToDetailsFromVideo();
      return;
    }
    final isPicked = _pickedImagePaths != null && _pickedImagePaths!.isNotEmpty;
    if (!isPicked) return;
    setState(() => _step = _PostFlowStep.edit);
  }

  void _goToDetailsFromVideo() {
    if (_pickedVideoPath == null) return;
    setState(() {
      _editImagePaths = [];
      _editTransforms = [];
      _previewImageIndex = 0;
      _step = _PostFlowStep.details;
    });
  }

  void _goToDetails(
    List<String> imagePaths,
    List<PostImageTransform> transforms,
    int previewImageIndex,
  ) {
    setState(() {
      _editImagePaths = imagePaths;
      _editTransforms = transforms;
      _previewImageIndex = previewImageIndex;
      _step = _PostFlowStep.details;
    });
  }

  void _backToEdit() {
    setState(() => _step = _PostFlowStep.edit);
  }

  void _backToGallery() {
    setState(() => _step = _PostFlowStep.gallery);
  }

  bool _handleBack() {
    switch (_step) {
      case _PostFlowStep.gallery:
        return true;
      case _PostFlowStep.edit:
        _backToGallery();
        return false;
      case _PostFlowStep.details:
        if (_pickedVideoPath != null) {
          _backToGallery();
        } else {
          _backToEdit();
        }
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _step == _PostFlowStep.gallery,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: switch (_step) {
        _PostFlowStep.gallery => _buildGallery(),
        _PostFlowStep.edit => _buildEdit(),
        _PostFlowStep.details => _buildDetails(),
      },
    );
  }

  Widget _buildGallery() {
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final hasSelection =
        (_pickedImagePaths != null && _pickedImagePaths!.isNotEmpty) ||
            _pickedVideoPath != null;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned(
            top: topInset + _bannerHeight,
            left: 0,
            right: 0,
            bottom: 0,
            child: _GalleryLauncher(
              hasSelection: hasSelection,
              selectedCount: _pickedImagePaths?.length ?? 0,
              onChoosePhotos: _openGalleryPicker,
              onTakePhoto: _openCamera,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _PostingBanner(
              topInset: topInset,
              onClose: _exitFlow,
              hasSelection: hasSelection,
              onNext: hasSelection ? _goToEdit : null,
              onPickVideo: _postType == 'scene' ? _pickVideo : null,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomInset + _bottomControlsOffset,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _PostingSelector(
                  postType: _postType,
                  onChanged: _onPostTypeChanged,
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {},
                  child: SvgPicture.asset(
                    PostMediaAssets.filterButton,
                    width: 38,
                    height: 38,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEdit() {
    final isPicked = _pickedImagePaths != null && _pickedImagePaths!.isNotEmpty;
    return PostEditPage(
      key: ValueKey('edit-$_postType-${(_pickedImagePaths ?? const []).join(",")}'),
      postType: _postType,
      selectedCellIndices: const [],
      customImagePaths: isPicked ? _pickedImagePaths : null,
      initialImageIndex: _previewImageIndex,
      initialTransforms:
          _editTransforms.isNotEmpty ? _editTransforms : null,
      onClose: _exitFlow,
      onNext: _goToDetails,
    );
  }

  Widget _buildDetails() {
    return PostCreatePage(
      key: const ValueKey('details'),
      postType: _postType,
      selectedCellIndices: const [],
      imagePaths: _editImagePaths,
      transforms: _editTransforms,
      previewImageIndex: _previewImageIndex,
      onClose: _exitFlow,
      onEdit: _pickedVideoPath != null ? null : _backToEdit,
      mediaKind: _pickedVideoPath != null ? 'video' : 'image',
      videoPath: _pickedVideoPath,
    );
  }
}

class _GalleryLauncher extends StatelessWidget {
  const _GalleryLauncher({
    required this.hasSelection,
    required this.selectedCount,
    required this.onChoosePhotos,
    required this.onTakePhoto,
  });

  final bool hasSelection;
  final int selectedCount;
  final VoidCallback onChoosePhotos;
  final VoidCallback onTakePhoto;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasSelection
                ? Icons.check_circle_rounded
                : Icons.photo_library_outlined,
            color: Colors.white,
            size: 56,
          ),
          const SizedBox(height: 16),
          Text(
            hasSelection
                ? '$selectedCount photo${selectedCount == 1 ? '' : 's'} selected'
                : 'Add photos to your post',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton.icon(
                onPressed: onTakePhoto,
                icon: const Icon(Icons.camera_alt_rounded, color: Colors.white),
                label: Text(
                  'Camera',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white54),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: onChoosePhotos,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: Text(
                  hasSelection ? 'Change selection' : 'Choose Photos',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PostingBanner extends StatelessWidget {
  const _PostingBanner({
    required this.topInset,
    required this.onClose,
    required this.hasSelection,
    required this.onNext,
    this.onPickVideo,
  });

  static const _neutral300 = Color(0xFFC8C5BC);

  final double topInset;
  final VoidCallback onClose;
  final bool hasSelection;
  final VoidCallback? onNext;
  final VoidCallback? onPickVideo;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Padding(
        padding: EdgeInsets.only(top: topInset),
        child: SizedBox(
          height: _PostPageState._bannerHeight,
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
                      'New post',
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
                ),
                if (onPickVideo != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onPickVideo,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.videocam_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PostingSelector extends StatelessWidget {
  const _PostingSelector({
    required this.postType,
    required this.onChanged,
  });

  static const _selectorBg = Color(0xE6231F1B);

  final String postType;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const options = ['piece', 'scene'];

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
          for (final type in options)
            _SelectorTab(
              label: type == 'scene' ? 'Scene' : 'Piece',
              selected: postType == type,
              onTap: () => onChanged(type),
            ),
        ],
      ),
    );
  }
}

class _SelectorTab extends StatelessWidget {
  const _SelectorTab({
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
