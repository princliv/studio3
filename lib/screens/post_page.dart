import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_manager/photo_manager.dart';

import '../data/post_media_assets.dart';
import '../models/post_image_transform.dart';
import '../theme/home_feed_tokens.dart';
import '../widgets/permission_denied_sheet.dart';
import '../widgets/post_gallery/post_gallery_picker.dart';
import 'post_create_page.dart';
import 'post_edit_page.dart';
import 'post_video_edit_page.dart';

enum _PostFlowStep { gallery, edit, videoEdit, details }

/// Single-route posting flow: gallery → edit → details (Figma 1609:1975).
class PostPage extends StatefulWidget {
  const PostPage({super.key, this.postType = 'piece'});

  final String postType;

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  static const _bannerHeight = 64.0;
  static const _maxPieceSelection = 5;
  static const _maxSceneSelection = 10;

  _PostFlowStep _step = _PostFlowStep.gallery;
  late final String _postType = widget.postType;
  List<AssetEntity> _pickedAssets = [];
  List<String>? _pickedImagePaths;
  String? _pickedVideoPath;
  Uint8List? _pickedVideoThumbnailBytes;
  final ValueNotifier<bool> _albumMenuOpen = ValueNotifier(false);
  String _selectedAlbumName = 'Recents';

  List<String> _editImagePaths = [];
  List<PostImageTransform> _editTransforms = [];
  int _previewImageIndex = 0;

  @override
  void dispose() {
    _albumMenuOpen.dispose();
    super.dispose();
  }

  void _exitFlow() => Navigator.pop(context);

  Future<void> _goToEdit() async {
    if (_pickedAssets.isEmpty) return;
    AssetEntity? video;
    for (final asset in _pickedAssets) {
      if (asset.type == AssetType.video) {
        video = asset;
        break;
      }
    }
    if (video != null) {
      final file = await video.file;
      // Same proven thumbnail source the gallery grid itself uses
      // (`_AssetThumbnail` in post_gallery_picker.dart) — captured now,
      // before the AssetEntity reference is gone, so both the compose
      // preview and the published thumbnail show a real poster frame
      // instead of a broken attempt to decode the video file as an image.
      final thumbnail = await video.thumbnailDataWithSize(
        const ThumbnailSize.square(720),
      );
      if (file == null || !mounted) return;
      setState(() {
        _pickedVideoPath = file.path;
        _pickedVideoThumbnailBytes = thumbnail;
        _pickedImagePaths = null;
        _step = _PostFlowStep.videoEdit;
      });
      return;
    }
    final paths = <String>[];
    for (final asset in _pickedAssets) {
      final file = await asset.file;
      if (file != null) paths.add(file.path);
    }
    if (!mounted || paths.isEmpty) return;
    setState(() {
      _pickedImagePaths = paths;
      _step = _PostFlowStep.edit;
    });
  }

  void _goToDetailsFromVideoEdit(String finalVideoPath) {
    setState(() {
      _pickedVideoPath = finalVideoPath;
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

  /// Piece flow's "+" tile (Figma 2716:5774): pushes the gallery picker as
  /// its own route, seeded with everything already picked, so the running
  /// edit session (crop/adjust work, reorder) never gets torn down the way
  /// switching `_step` back to `.gallery` would.
  Future<List<AssetEntity>?> _pickMoreImages(int remainingSlots) async {
    final result = await Navigator.push<List<AssetEntity>>(
      context,
      MaterialPageRoute(
        builder: (_) => _AddMorePickerPage(
          initialSelection: _pickedAssets,
          maxSelection: _pickedAssets.length + remainingSlots,
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() => _pickedAssets = result);
    }
    return result;
  }

  bool _handleBack() {
    switch (_step) {
      case _PostFlowStep.gallery:
        return true;
      case _PostFlowStep.edit:
      case _PostFlowStep.videoEdit:
        _backToGallery();
        return false;
      case _PostFlowStep.details:
        if (_pickedVideoPath != null) {
          setState(() => _step = _PostFlowStep.videoEdit);
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
        _PostFlowStep.videoEdit => _buildVideoEdit(),
        _PostFlowStep.details => _buildDetails(),
      },
    );
  }

  Widget _buildGallery() {
    final topInset = MediaQuery.paddingOf(context).top;
    final hasSelection = _pickedAssets.isNotEmpty || _pickedVideoPath != null;

    return Scaffold(
      backgroundColor: HomeFeedTokens.background,
      body: Stack(
        children: [
          Positioned(
            top: topInset + _bannerHeight,
            left: 0,
            right: 0,
            bottom: 0,
            child: PostGalleryPicker(
              key: ValueKey(_postType),
              openNotifier: _albumMenuOpen,
              maxSelection: _postType == 'piece'
                  ? _maxPieceSelection
                  : _maxSceneSelection,
              allowVideos: _postType == 'scene',
              initialSelection: _pickedAssets,
              onAlbumChanged: (name) =>
                  setState(() => _selectedAlbumName = name),
              onSelectionChanged: (assets) =>
                  setState(() => _pickedAssets = assets),
              onPermissionPermanentlyDenied: () {
                showPermissionDeniedSheet(
                  context,
                  title: 'Photo access needed',
                  message:
                      'Enable photo library access in Settings to continue.',
                );
              },
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
              albumName: _selectedAlbumName,
              menuOpen: _albumMenuOpen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEdit() {
    final isPicked = _pickedImagePaths != null && _pickedImagePaths!.isNotEmpty;
    return PostEditPage(
      key: ValueKey(
        'edit-$_postType-${(_pickedImagePaths ?? const []).join(",")}',
      ),
      postType: _postType,
      customImagePaths: isPicked ? _pickedImagePaths : null,
      initialImageIndex: _previewImageIndex,
      initialTransforms: _editTransforms.isNotEmpty ? _editTransforms : null,
      onClose: _postType == 'piece' ? _backToGallery : _exitFlow,
      onPickMore: _postType == 'piece' ? _pickMoreImages : null,
      onNext: _goToDetails,
    );
  }

  Widget _buildVideoEdit() {
    return PostVideoEditPage(
      key: ValueKey('video-edit-$_pickedVideoPath'),
      videoPath: _pickedVideoPath!,
      onClose: _exitFlow,
      onNext: _goToDetailsFromVideoEdit,
    );
  }

  Widget _buildDetails() {
    return PostCreatePage(
      key: const ValueKey('details'),
      postType: _postType,
      imagePaths: _editImagePaths,
      transforms: _editTransforms,
      previewImageIndex: _previewImageIndex,
      onClose: _exitFlow,
      onEdit: _pickedVideoPath != null
          ? () => setState(() => _step = _PostFlowStep.videoEdit)
          : _backToEdit,
      mediaKind: _pickedVideoPath != null ? 'video' : 'image',
      videoPath: _pickedVideoPath,
      videoThumbnailBytes: _pickedVideoThumbnailBytes,
    );
  }
}

class _PostingBanner extends StatelessWidget {
  const _PostingBanner({
    required this.topInset,
    required this.onClose,
    required this.hasSelection,
    required this.onNext,
    required this.albumName,
    required this.menuOpen,
  });

  final double topInset;
  final VoidCallback onClose;
  final bool hasSelection;
  final VoidCallback? onNext;
  final String albumName;
  final ValueNotifier<bool> menuOpen;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: HomeFeedTokens.background,
      child: Padding(
        padding: EdgeInsets.only(top: topInset),
        child: SizedBox(
          height: _PostPageState._bannerHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: onClose,
                      behavior: HitTestBehavior.opaque,
                      child: SvgPicture.asset(
                        PostMediaAssets.closeIcon,
                        width: 14,
                        height: 14,
                        colorFilter: const ColorFilter.mode(
                          HomeFeedTokens.textPrimary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Opacity(
                      opacity: hasSelection ? 1 : 0.3,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onNext,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                            ),
                            child: Text(
                              'Next',
                              style: GoogleFonts.inter(
                                fontSize: 16,
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
                ValueListenableBuilder<bool>(
                  valueListenable: menuOpen,
                  builder: (context, open, _) => GestureDetector(
                    onTap: () => menuOpen.value = !open,
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          albumName,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: HomeFeedTokens.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        AnimatedRotation(
                          turns: open ? 0.5 : 0,
                          duration: const Duration(milliseconds: 150),
                          child: SvgPicture.asset(
                            PostMediaAssets.chevronDown,
                            width: 9,
                            height: 9,
                            colorFilter: const ColorFilter.mode(
                              HomeFeedTokens.textPrimary,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ],
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

/// Modal "add more" gallery route used by the piece flow's "+" tile — the
/// same banner/grid as the initial gallery step, but as its own pushed
/// route (rather than a `_step` switch) so it never tears down the
/// in-progress edit session underneath it. Pops with the final selection,
/// or null if the user backs out without confirming.
class _AddMorePickerPage extends StatefulWidget {
  const _AddMorePickerPage({
    required this.initialSelection,
    required this.maxSelection,
  });

  final List<AssetEntity> initialSelection;
  final int maxSelection;

  @override
  State<_AddMorePickerPage> createState() => _AddMorePickerPageState();
}

class _AddMorePickerPageState extends State<_AddMorePickerPage> {
  late List<AssetEntity> _selected = List.of(widget.initialSelection);
  final ValueNotifier<bool> _albumMenuOpen = ValueNotifier(false);
  String _selectedAlbumName = 'Recents';

  @override
  void dispose() {
    _albumMenuOpen.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return Scaffold(
      backgroundColor: HomeFeedTokens.background,
      body: Stack(
        children: [
          Positioned(
            top: topInset + _PostPageState._bannerHeight,
            left: 0,
            right: 0,
            bottom: 0,
            child: PostGalleryPicker(
              openNotifier: _albumMenuOpen,
              maxSelection: widget.maxSelection,
              initialSelection: widget.initialSelection,
              onAlbumChanged: (name) =>
                  setState(() => _selectedAlbumName = name),
              onSelectionChanged: (assets) =>
                  setState(() => _selected = assets),
              onPermissionPermanentlyDenied: () {
                showPermissionDeniedSheet(
                  context,
                  title: 'Photo access needed',
                  message:
                      'Enable photo library access in Settings to continue.',
                );
              },
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _PostingBanner(
              topInset: topInset,
              onClose: () => Navigator.pop(context),
              hasSelection: _selected.isNotEmpty,
              onNext: _selected.isNotEmpty
                  ? () => Navigator.pop(context, _selected)
                  : null,
              albumName: _selectedAlbumName,
              menuOpen: _albumMenuOpen,
            ),
          ),
        ],
      ),
    );
  }
}
