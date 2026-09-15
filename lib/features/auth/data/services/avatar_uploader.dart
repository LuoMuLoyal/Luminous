import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/client/client_providers.dart';
import 'package:luminous/core/network/client/object_upload.dart';
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
    // 客户端校验必须在 presign 之前:先要签名再因超限拒绝,既白跑一次服务端,
    // 也把「用户选了过大的图」记成服务端错误。
    if (bytes.isEmpty) throw _failure('Avatar file is empty.');
    if (!_allowedContentTypes.contains(contentType)) {
      throw _failure('Avatar file type is not supported.');
    }
    if (bytes.length > _maxAvatarBytes) {
      throw _failure('Avatar file is too large.');
    }

    final extension = _extensionFor(contentType);
    final objectName = 'avatar-${_randomId()}.$extension';
    final upload = await presignFileUpload(
      filesApi,
      contentType: contentType,
      sizeBytes: bytes.length,
      fileName: 'avatars/$userId/$objectName',
    );
    // 服务端上限低于客户端预检时仍要拦住,失败语义与本地校验保持一类。
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

  /// 5 MB，与 profile 页的 UX 预检同一个上限。
  static const _maxAvatarBytes = 5 * 1024 * 1024;

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

  /// 本地校验失败归为 business：这是「用户选的图不符合要求」，不是网络故障。
  /// 归成 network 会把 HEIC/超大图计成服务端或网络异常，污染错误率与告警。
  static LucentFailure _failure(String message) =>
      LucentFailure.business(message: message);
}
