import 'dart:io';
import 'dart:typed_data';

import 'api_client.dart';

class PresignResult {
  const PresignResult({
    required this.presignedPutUrl,
    required this.url,
    required this.key,
    this.devMode = false,
  });

  final String presignedPutUrl;
  final String url;
  final String key;
  final bool devMode;

  factory PresignResult.fromJson(Map<String, dynamic> json) {
    return PresignResult(
      presignedPutUrl: json['presignedPutUrl'] as String? ?? '',
      url: json['url'] as String? ?? '',
      key: json['key'] as String? ?? '',
      devMode: json['devMode'] as bool? ?? false,
    );
  }
}

class MediaService {
  MediaService._();
  static final MediaService instance = MediaService._();

  final _api = ApiClient.instance;

  Future<PresignResult> presign({
    required String purpose,
    required String contentType,
    String? pieceId,
    String? postId,
  }) async {
    final body = <String, dynamic>{
      'purpose': purpose,
      'contentType': contentType,
    };
    if (pieceId != null) body['pieceId'] = pieceId;
    if (postId != null) body['postId'] = postId;
    final json = await _api.post('/api/media/presign', body: body, auth: true);
    final data = _api.extractData(json) as Map<String, dynamic>;
    return PresignResult.fromJson(data);
  }

  Future<String> uploadBytes({
    required String purpose,
    required Uint8List bytes,
    required String contentType,
    String? pieceId,
    String? postId,
  }) async {
    final presign = await this.presign(
      purpose: purpose,
      contentType: contentType,
      pieceId: pieceId,
      postId: postId,
    );
    await _api.uploadToPresignedUrl(
      presignedPutUrl: presign.presignedPutUrl,
      bytes: bytes,
      contentType: contentType,
    );
    return presign.url;
  }

  Future<String> uploadFile({
    required String purpose,
    required File file,
    required String contentType,
    String? pieceId,
    String? postId,
  }) async {
    final bytes = await file.readAsBytes();
    return uploadBytes(
      purpose: purpose,
      bytes: bytes,
      contentType: contentType,
      pieceId: pieceId,
      postId: postId,
    );
  }
}
