import 'dart:io';

import 'package:flutter/services.dart';

import '../data/post_location_options.dart';
import '../data/post_material_options.dart';
import '../models/listing_details.dart';
import '../services/api_exception.dart';
import '../services/media_service.dart';
import '../services/piece_service.dart';
import '../services/post_service.dart';
import '../services/series_service.dart';

/// Draft state carried through the posting flow.
class PostDraft {
  const PostDraft({
    required this.postType,
    required this.imagePaths,
    this.mediaKind = 'image',
    this.videoPath,
    this.title = '',
    this.description = '',
    this.mediumId,
    this.styleIds = const [],
    this.locations = const [],
    this.materials = const [],
    this.listingDetails,
    this.selectedSeriesId,
    this.newSeriesName,
  });

  final String postType;
  final List<String> imagePaths;
  final String mediaKind;
  final String? videoPath;
  final String title;
  final String description;
  final String? mediumId;
  final List<String> styleIds;
  final List<PostLocationOption> locations;
  final List<PostMaterialOption> materials;
  final ListingDetails? listingDetails;
  final String? selectedSeriesId;
  final String? newSeriesName;

  bool get isVideo => mediaKind == 'video';

  PostDraft copyWith({
    String? postType,
    List<String>? imagePaths,
    String? mediaKind,
    String? videoPath,
    String? title,
    String? description,
    String? mediumId,
    List<String>? styleIds,
    List<PostLocationOption>? locations,
    List<PostMaterialOption>? materials,
    ListingDetails? listingDetails,
    String? selectedSeriesId,
    String? newSeriesName,
  }) {
    return PostDraft(
      postType: postType ?? this.postType,
      imagePaths: imagePaths ?? this.imagePaths,
      mediaKind: mediaKind ?? this.mediaKind,
      videoPath: videoPath ?? this.videoPath,
      title: title ?? this.title,
      description: description ?? this.description,
      mediumId: mediumId ?? this.mediumId,
      styleIds: styleIds ?? this.styleIds,
      locations: locations ?? this.locations,
      materials: materials ?? this.materials,
      listingDetails: listingDetails ?? this.listingDetails,
      selectedSeriesId: selectedSeriesId ?? this.selectedSeriesId,
      newSeriesName: newSeriesName ?? this.newSeriesName,
    );
  }
}

class PostPublishService {
  PostPublishService._();
  static final PostPublishService instance = PostPublishService._();

  final _media = MediaService.instance;
  final _pieces = PieceService.instance;
  final _posts = PostService.instance;
  final _series = SeriesService.instance;

  Future<void> publish(PostDraft draft) async {
    final isScene = draft.postType == 'scene';
    final isVideo = draft.isVideo;
    final isListing = draft.listingDetails != null;
    final purpose = isScene ? 'post' : 'piece';

    if (isVideo) {
      if (draft.videoPath == null || draft.videoPath!.isEmpty) {
        throw Exception('No video selected');
      }
      if (!isScene) {
        throw Exception('Video upload is only supported for scenes');
      }
      final mediaUrl = await _media.uploadFile(
        purpose: purpose,
        file: File(draft.videoPath!),
      );
      await _posts.create({
        'mediaUrl': mediaUrl,
        'mediaType': 'video',
        if (draft.description.trim().isNotEmpty)
          'caption': draft.description.trim(),
      });
      return;
    }

    if (draft.imagePaths.isEmpty) {
      throw Exception('No image selected');
    }
    final imagePath = draft.imagePaths.first;
    final bytes = await _loadImageBytes(imagePath);
    final mediaUrl = await _media.uploadBytes(
      purpose: purpose,
      bytes: bytes,
      contentType: MediaService.contentTypeForPath(imagePath),
    );

    if (isScene) {
      await _posts.create({
        'mediaUrl': mediaUrl,
        'mediaType': 'image',
        if (draft.description.trim().isNotEmpty)
          'caption': draft.description.trim(),
      });
      return;
    }

    final caption = draft.description.trim();

    final body = <String, dynamic>{
      'title': draft.title.trim().isNotEmpty ? draft.title.trim() : 'Untitled',
      'mediaUrl': mediaUrl,
      'mediaType': 'image',
      if (caption.isNotEmpty) 'caption': caption,
      if (draft.mediumId != null) 'medium': draft.mediumId,
      if (isListing) ...{
        'isForSale': true,
        if (draft.listingDetails?.priceCents != null)
          'priceCents': draft.listingDetails!.priceCents,
        if (draft.listingDetails?.dimensionsString != null)
          'dimensions': draft.listingDetails!.dimensionsString,
        if (draft.listingDetails?.location != null)
          'shippingRegion': draft.listingDetails!.location,
        if (draft.listingDetails?.yearCreated != null)
          'yearCreated': draft.listingDetails!.yearCreated,
        if (draft.listingDetails?.framingMounting?.trim().isNotEmpty == true)
          'framingMounting': draft.listingDetails!.framingMounting!.trim(),
        if (draft.listingDetails?.provenance?.trim().isNotEmpty == true)
          'provenance': draft.listingDetails!.provenance!.trim(),
        if (draft.listingDetails?.handlingNotes?.trim().isNotEmpty == true)
          'handlingNotes': draft.listingDetails!.handlingNotes!.trim(),
      },
    };

    final piece = await _pieces.create(body);
    await _assignPieceToSeries(draft, piece.id);
  }

  Future<void> _assignPieceToSeries(PostDraft draft, String pieceId) async {
    final newName = draft.newSeriesName?.trim();
    if (newName != null && newName.isNotEmpty) {
      await _series.create(name: newName, pieceIds: [pieceId]);
      return;
    }

    final seriesId = draft.selectedSeriesId;
    if (seriesId == null || seriesId.isEmpty) return;

    try {
      await _series.addPiece(seriesId, pieceId);
    } on ApiException catch (e) {
      if (e.statusCode == 400) {
        throw ApiException(
          e.message.isNotEmpty
              ? e.message
              : 'This piece is already in another series.',
        );
      }
      rethrow;
    }
  }

  Future<Uint8List> _loadImageBytes(String path) async {
    if (path.startsWith('assets/')) {
      final data = await rootBundle.load(path);
      return data.buffer.asUint8List();
    }
    return File(path).readAsBytes();
  }
}
