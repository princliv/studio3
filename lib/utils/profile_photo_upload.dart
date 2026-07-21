import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/api_exception.dart';
import '../services/media_service.dart';
import '../services/permission_service.dart';
import '../services/user_service.dart';
import '../widgets/permission_denied_sheet.dart';
import '../widgets/uploading_dialog.dart';

final _picker = ImagePicker();

/// Picks an image and uploads it for [purpose]. Does not persist profile fields.
Future<String?> pickAndUploadPhoto(
  BuildContext context,
  String purpose,
) async {
  final outcome = await PermissionService.instance
      .requestGalleryAccess(forVideo: false);
  if (outcome == GalleryPermissionOutcome.deniedForever) {
    if (context.mounted) {
      await showPermissionDeniedSheet(
        context,
        title: 'Photo access needed',
        message: 'Enable photo library access in Settings to upload photos.',
      );
    }
    return null;
  }
  if (outcome == GalleryPermissionOutcome.denied) {
    return null;
  }
  final picked = await _picker.pickImage(source: ImageSource.gallery);
  if (picked == null) return null;
  if (!context.mounted) return null;
  showUploadingDialog(context);
  try {
    final url = await MediaService.instance.uploadFile(
      purpose: purpose,
      file: File(picked.path),
    );
    // Profile/cover uploads reuse a stable per-user URL, so the new bytes
    // must be evicted from the image cache or the old photo keeps showing.
    PaintingBinding.instance.imageCache.evict(NetworkImage(url));
    return url;
  } catch (e) {
    if (!context.mounted) return null;
    final message = e is ApiException ? e.message : e.toString();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    return null;
  } finally {
    if (context.mounted) hideUploadingDialog(context);
  }
}

/// Picks a profile photo, uploads it, and persists via [UserService.updateMe].
Future<String?> pickAndUploadProfilePhoto(BuildContext context) async {
  final url = await pickAndUploadPhoto(context, 'profile');
  if (url == null) return null;
  try {
    await UserService.instance.updateMe(profilePhotoUrl: url);
    return url;
  } catch (e) {
    if (!context.mounted) return null;
    final message = e is ApiException ? e.message : e.toString();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    return null;
  }
}

/// Picks a cover photo and uploads it. Caller saves via updateMe.
Future<String?> pickAndUploadCoverPhoto(BuildContext context) {
  return pickAndUploadPhoto(context, 'cover');
}
