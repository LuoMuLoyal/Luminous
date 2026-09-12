import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/client/client_providers.dart';
import 'package:luminous/core/network/client/object_upload.dart';
import 'package:luminous/core/network/contract/error_code.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'avatar_uploader.g.dart';

@riverpod
AvatarUploader avatarUploader(Ref ref) {
  return AvatarUploader(
    filesApi: ref.watch(lucentClientProvider).files,
    dio: ref.watch(lucentDioClientProvider).dio,
  );
}

class AvatarUploader {
  const AvatarUploader({required this.filesApi, required this.dio});

  final FilesApi filesApi;
  final Dio dio;

  Future<String> upload({
    required String userId,
    required Uint8List bytes,
    required String contentType,
    required String fileName,
  }) async {
    if (bytes.isEmpty) throw _failure('Avatar file is empty.');
    if (!_allowedContentTypes.contains(contentType)) {
      throw _failure('Avatar file type is not supported.');
    }

    final extension = _extensionFor(contentType);
    final objectName = 'avatar-${_randomId()}.$extension';
    final upload = await presignFileUpload(
      filesApi,
      contentType: contentType,
      sizeBytes: bytes.length,
      fileName: 'avatars/$userId/$objectName',
    );
    if (bytes.length > upload.maxSizeBytes) {
      throw _failure('Avatar file is too large.');
    }
    await putPresignedObject(
      dio,
      upload: upload,
      bytes: bytes,
      contentType: contentType,
    );
    return upload.requirePublicUrl();
  }

  static const _allowedContentTypes = <String>{
    'image/jpeg',
    'image/png',
    'image/webp',
  };

  static String _randomId() {
    final random = Random.secure();
    return List<int>.generate(
      16,
      (_) => random.nextInt(256),
    ).map((value) => value.toRadixString(16).padLeft(2, '0')).join();
  }

  static String _extensionFor(String contentType) => switch (contentType) {
    'image/png' => 'png',
    'image/webp' => 'webp',
    _ => 'jpg',
  };

  static LucentFailure _failure(String message) => LucentFailure.network(
    message: message,
    networkErrorCode: NetworkErrorCode.unknown,
  );
}
