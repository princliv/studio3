import 'package:flutter/material.dart';

import '../screens/image_preview_page.dart';

Future<void> openImagePreview(
  BuildContext context, {
  required List<String> imageUrls,
  required int initialIndex,
}) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => ImagePreviewPage(
        imageUrls: imageUrls,
        initialIndex: initialIndex,
      ),
    ),
  );
}
