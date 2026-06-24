import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';

import '../data/post_location_options.dart';
import '../data/post_material_options.dart';
import '../models/listing_details.dart';
import '../services/media_service.dart';
import '../services/piece_service.dart';
import '../services/post_service.dart';

/// Draft state carried through the posting flow.
class PostDraft {
  const PostDraft({
    required this.postType,
    required this.imagePaths,
    this.title = '',
    this.description = '',
    this.mediumId,
    this.styleIds = const [],
    this.locations = const [],
    this.materials = const [],
    this.listingDetails,
  });

  final String postType;
  final List<String> imagePaths;
  final String title;
  final String description;
  final String? mediumId;
  final List<String> styleIds;
  final List<PostLocationOption> locations;
  final List<PostMaterialOption> materials;
  final ListingDetails? listingDetails;

  PostDraft copyWith({
    String? postType,
    List<String>? imagePaths,
    String? title,
    String? description,
    String? mediumId,
    List<String>? styleIds,
    List<PostLocationOption>? locations,
    List<PostMaterialOption>? materials,
    ListingDetails? listingDetails,
  }) {
    return PostDraft(
      postType: postType ?? this.postType,
      imagePaths: imagePaths ?? this.imagePaths,
      title: title ?? this.title,
      description: description ?? this.description,
      mediumId: mediumId ?? this.mediumId,
      styleIds: styleIds ?? this.styleIds,
      locations: locations ?? this.locations,
      materials: materials ?? this.materials,
      listingDetails: listingDetails ?? this.listingDetails,
    );
  }
}

class PostPublishService {
  PostPublishService._();
  static final PostPublishService instance = PostPublishService._();

  final _media = MediaService.instance;
  final _pieces = PieceService.instance;
  final _posts = PostService.instance;

  Future<void> publish(PostDraft draft) async {
    if (draft.imagePaths.isEmpty) {
      throw Exception('No image selected');
    }
    final bytes = await _loadImageBytes(draft.imagePaths.first);
    final isListing = draft.postType == 'listing';
    final isScene = draft.postType == 'scene';
    final purpose = isScene ? 'post' : 'piece';
    final mediaUrl = await _media.uploadBytes(
      purpose: purpose,
      bytes: bytes,
      contentType: 'image/jpeg',
    );

    if (isScene) {
      await _posts.create({
        'mediaUrl': mediaUrl,
        'mediaType': 'image',
        if (draft.description.trim().isNotEmpty) 'caption': draft.description.trim(),
      });
      return;
    }

    final caption = isListing
        ? draft.listingDetails?.buildCaptionExtras(baseCaption: draft.description.trim()) ??
            draft.description.trim()
        : draft.description.trim();

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
      },
    };

    await _pieces.create(body);
  }

  Future<Uint8List> _loadImageBytes(String path) async {
    if (path.startsWith('assets/')) {
      final data = await rootBundle.load(path);
      return data.buffer.asUint8List();
    }
    return File(path).readAsBytes();
  }
}
