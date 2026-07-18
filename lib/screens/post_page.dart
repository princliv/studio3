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
  static const _gridGap = 3.0;
  static const _bottomControlsOffset = 42.0;
  static const _maxSelection = 10;

  _PostFlowStep _step = _PostFlowStep.gallery;
  String _postType = 'piece';
  final List<int> _selectedIndices = [];
  List<String>? _pickedImagePaths;
  String? _pickedVideoPath;
  final _picker = ImagePicker();

  List<String> _editImagePaths = [];
  List<PostImageTransform> _editTransforms = [];
  int _previewImageIndex = 0;

  void _exitFlow() => Navigator.pop(context);

  void _onPostTypeChanged(String type) {
    if (type == _postType) return;
    setState(() {
      _postType = type;
      _selectedIndices.clear();
      _pickedImagePaths = null;
      _pickedVideoPath = null;
    });
  }

  void _onCellTap(int cellIndex) {
    final position = _selectedIndices.indexOf(cellIndex);
    if (position >= 0) {
      setState(() => _selectedIndices.removeAt(position));
      return;
    }
    if (_selectedIndices.length >= _maxSelection) {
      _showMaxSelectionMessage();
      return;
    }
    setState(() => _selectedIndices.add(cellIndex));
  }

  void _showMaxSelectionMessage() {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          elevation: 0,
          padding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          duration: const Duration(seconds: 2),
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'You can select up to 10 photos at a time.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                height: 1.3,
              ),
            ),
          ),
        ),
      );
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

  Future<void> _pickFromGallery() async {
    if (!await _ensureGalleryAccess(forVideo: false)) return;
    final images = await _picker.pickMultiImage(limit: _maxSelection);
    if (images.isEmpty || !mounted) return;
    setState(() {
      _pickedImagePaths = images.map((x) => x.path).toList();
      _pickedVideoPath = null;
      _selectedIndices.clear();
      for (var i = 0; i < _pickedImagePaths!.length; i++) {
        _selectedIndices.add(i);
      }
    });
  }

  Future<void> _pickVideo() async {
    if (!await _ensureGalleryAccess(forVideo: true)) return;
    final video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video == null || !mounted) return;
    setState(() {
      _pickedVideoPath = video.path;
      _pickedImagePaths = null;
      _selectedIndices.clear();
    });
  }

  void _goToEdit() {
    if (_pickedVideoPath != null) {
      _goToDetailsFromVideo();
      return;
    }
    final isPicked = _pickedImagePaths != null && _pickedImagePaths!.isNotEmpty;
    if (!isPicked && _selectedIndices.isEmpty) return;
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

  int? _selectionOrder(int cellIndex) {
    final position = _selectedIndices.indexOf(cellIndex);
    return position >= 0 ? position + 1 : null;
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
        _selectedIndices.isNotEmpty || _pickedVideoPath != null;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned(
            top: topInset + _bannerHeight,
            left: 0,
            right: 0,
            bottom: 0,
            child: _MediaGrid(
              postType: _postType,
              selectionOrderFor: _selectionOrder,
              onSelect: _onCellTap,
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
              onPickGallery: _pickFromGallery,
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
      key: ValueKey('edit-$_postType-${_selectedIndices.join(",")}'),
      postType: _postType,
      selectedCellIndices: List<int>.from(_selectedIndices),
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
      selectedCellIndices: List<int>.from(_selectedIndices),
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

class _PostingBanner extends StatelessWidget {
  const _PostingBanner({
    required this.topInset,
    required this.onClose,
    required this.hasSelection,
    required this.onNext,
    this.onPickGallery,
    this.onPickVideo,
  });

  static const _neutral300 = Color(0xFFC8C5BC);

  final double topInset;
  final VoidCallback onClose;
  final bool hasSelection;
  final VoidCallback? onNext;
  final VoidCallback? onPickGallery;
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
                    child: GestureDetector(
                      onTap: onPickGallery,
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Recents',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: HomeFeedTokens.textInverse,
                            ),
                          ),
                          const SizedBox(width: 4),
                          SvgPicture.asset(
                            PostMediaAssets.chevronDown,
                            width: 9,
                            height: 5,
                          ),
                        ],
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

class _MediaGrid extends StatelessWidget {
  const _MediaGrid({
    required this.postType,
    required this.selectionOrderFor,
    required this.onSelect,
  });

  final String postType;
  final int? Function(int cellIndex) selectionOrderFor;
  final ValueChanged<int> onSelect;

  bool get _isScene => postType == 'scene';

  List<PostMediaGridRow> get _rows =>
      _isScene ? PostMediaAssets.sceneGridRows : PostMediaAssets.pieceGridRows;

  List<String> get _thumbs =>
      _isScene ? PostMediaAssets.sceneGridThumbs : PostMediaAssets.pieceGridThumbs;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _rows.length,
      itemBuilder: (context, rowIndex) {
        final row = _rows[rowIndex];
        final rowStartIndex = rowIndex * 3;

        return Padding(
          padding: EdgeInsets.only(
            bottom: rowIndex < _rows.length - 1 ? _PostPageState._gridGap : 0,
          ),
          child: SizedBox(
            height: row.height,
            child: Row(
              children: [
                for (var col = 0; col < row.thumbIndices.length; col++) ...[
                  if (col > 0) const SizedBox(width: _PostPageState._gridGap),
                  Expanded(
                    child: _MediaCell(
                      thumbs: _thumbs,
                      thumbIndex: row.thumbIndices[col],
                      cellIndex: rowStartIndex + col,
                      selectionOrder: selectionOrderFor(rowStartIndex + col),
                      onTap: onSelect,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MediaCell extends StatelessWidget {
  const _MediaCell({
    required this.thumbs,
    required this.thumbIndex,
    required this.cellIndex,
    required this.selectionOrder,
    required this.onTap,
  });

  final List<String> thumbs;
  final int thumbIndex;
  final int cellIndex;
  final int? selectionOrder;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final selected = selectionOrder != null;

    return GestureDetector(
      onTap: () => onTap(cellIndex),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            thumbs[thumbIndex],
            fit: BoxFit.cover,
          ),
          if (selected)
            ColoredBox(
              color: Colors.white.withValues(alpha: 0.5),
              child: Center(
                child: Text(
                  '$selectionOrder',
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.w400,
                    color: HomeFeedTokens.textPrimary,
                    height: 1,
                  ),
                ),
              ),
            ),
        ],
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
