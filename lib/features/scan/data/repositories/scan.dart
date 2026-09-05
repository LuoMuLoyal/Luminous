// ignore_for_file: use_of_void_result

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/network/api.dart';
import 'package:luminous/core/network/contract/error_code.dart';
import 'package:luminous/core/network/map_utils.dart';
import 'package:luminous/features/scan/domain/entities/scan_result.dart';
import 'package:luminous/features/scan/domain/repositories/scan.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'scan.g.dart';

/// Lucent-backed scan repository.
///
/// Repository boundary: every expected recoverable failure (network, server
/// business failure) is a `TaskEither` Left produced via
/// `LucentErrorMapper.fromObject`; a legal empty result set stays a Right.
/// An empty success response body is a `LucentFailure.network(emptyResponse)`
/// (auth `_requireBody` precedent). Protocol violations — a response body that
/// does not match the generated-client structure — stay thrown `StateError` /
/// `FormatException` (logged via [appTalker] for diagnosability) and surface
/// as a Left carrying `LucentFailureKind.unknown`.
class LucentScanRepository implements ScanRepository {
  const LucentScanRepository({
    required this.api,
    required this.dio,
    required this.filesApi,
  });

  final MedicinesApi api;
  final Dio dio;
  final FilesApi filesApi;

  @override
  TaskEither<LucentFailure, List<ScanSearchResult>> search(String query) {
    return TaskEither.tryCatch(() async {
      final response = await api.search(
        source_: 'cn',
        q: query,
        page: 1,
        pageSize: 20,
      );
      if (response.data == null) {
        throw LucentFailure.network(
          message: 'Medicine search response was empty.',
          networkErrorCode: NetworkErrorCode.emptyResponse,
        );
      }
      return response.data!.items
          .map(
            (item) => ScanSearchResult(
              id: item.id,
              name: item.name,
              subtitle: item.subtitle?.toString(),
            ),
          )
          .toList(growable: false);
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, String> uploadImage({
    required List<int> bytes,
    required String contentType,
    int? sizeBytes,
    String? fileName,
  }) {
    return TaskEither.tryCatch(() async {
      final presignResponse = await dio.post<Object>(
        LucentApiPaths.filesUpload,
        data: <String, Object?>{
          'contentType': contentType,
          'sizeBytes': sizeBytes ?? bytes.length,
          if (fileName != null) 'fileName': fileName,
        },
      );
      final uploadData = coerceToStringMap(presignResponse.data);
      if (uploadData == null) {
        // Empty success body: transport-level failure (auth precedent).
        throw LucentFailure.network(
          message: 'File upload presign response was empty.',
          networkErrorCode: NetworkErrorCode.emptyResponse,
        );
      }
      final uploadUrl = uploadData['uploadUrl']?.toString() ?? '';
      if (uploadUrl.isEmpty) {
        // Protocol violation: presign body does not match the expected
        // generated-client structure. Logged for diagnosability and kept as
        // a thrown protocol exception (mapped to Left(unknown)).
        appTalker.error(
          'LucentScanRepository.uploadImage: presign response missing '
          'uploadUrl: $uploadData',
        );
        throw StateError('File upload presign response is missing uploadUrl.');
      }
      final headersRaw = uploadData['headers'];
      final headersMap = coerceToStringMap(headersRaw);
      if (headersRaw != null && headersMap == null) {
        // Protocol violation: headers must be a map when present. Logged for
        // diagnosability and kept as a thrown protocol exception.
        appTalker.error(
          'LucentScanRepository.uploadImage: presign response headers is '
          'not a map: $headersRaw',
        );
        throw StateError('File upload presign response headers must be a map.');
      }
      final headers = headersMap ?? const <String, dynamic>{};
      final publicUrl = uploadData['publicUrl']?.toString();

      await dio.put(
        uploadUrl,
        data: bytes,
        options: Options(
          headers: <String, Object?>{
            ...headers,
            'Content-Length': (sizeBytes ?? bytes.length).toString(),
          },
          extra: const <String, Object?>{
            'skipAuthorization': true,
            'skipAuthRefresh': true,
          },
        ),
      );

      return publicUrl ?? uploadUrl;
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, MedicineRecognitionResult> recognizeMedicine(
    String imageUrl,
  ) {
    return TaskEither.tryCatch(() async {
      final response = await dio.post<Object>(
        LucentApiPaths.medicinesRecognize,
        data: <String, Object?>{'imageUrl': imageUrl},
      );
      final data = coerceToStringMap(response.data);
      if (data == null) {
        // Empty success body: transport-level failure (auth precedent).
        throw LucentFailure.network(
          message: 'Recognize medicine response was empty.',
          networkErrorCode: NetworkErrorCode.emptyResponse,
        );
      }
      final name = data['name'];
      final approvalNumber = data['approvalNumber'];
      if (name != null && name is! String) {
        appTalker.error(
          'LucentScanRepository.recognizeMedicine: name is not a string: '
          '$name',
        );
        throw const FormatException(
          'Recognize medicine response name must be a string.',
        );
      }
      if (approvalNumber != null && approvalNumber is! String) {
        appTalker.error(
          'LucentScanRepository.recognizeMedicine: approvalNumber is not a '
          'string: $approvalNumber',
        );
        throw const FormatException(
          'Recognize medicine response approvalNumber must be a string.',
        );
      }
      return MedicineRecognitionResult(
        name: name as String? ?? '',
        approvalNumber: approvalNumber as String?,
      );
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }
}

@riverpod
ScanRepository scanRepository(Ref ref) {
  return LucentScanRepository(
    api: ref.watch(lucentClientProvider).medicines,
    dio: ref.watch(lucentDioClientProvider).dio,
    filesApi: ref.watch(lucentClientProvider).files,
  );
}
