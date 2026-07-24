// ignore_for_file: use_of_void_result

import 'package:dio/dio.dart';
import 'package:luminous/core/network/api.dart';
import 'package:luminous/core/network/map_utils.dart';
import 'package:luminous/features/scan/domain/entities/scan_result.dart';
import 'package:luminous/features/scan/domain/repositories/scan.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'scan.g.dart';

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
  Future<List<ScanSearchResult>> search(String query) async {
    final response = await api.medicinesControllerSearchV1(
      source: Source.cn,
      q: query,
      page: 1,
      pageSize: 20,
    );
    return response.data.items
        .map(
          (item) => ScanSearchResult(
            id: item.id,
            name: item.name,
            subtitle: item.subtitle?.toString(),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<String> uploadImage({
    required List<int> bytes,
    required String contentType,
    int? sizeBytes,
    String? fileName,
  }) async {
    final presignResponse = await dio.post<Object>(
      LucentApiPaths.filesUpload,
      data: <String, Object?>{
        'contentType': contentType,
        'sizeBytes': sizeBytes ?? bytes.length,
        if (fileName != null) 'fileName': fileName,
      },
    );
    final envelope = coerceToStringMap(presignResponse.data);
    if (envelope == null) {
      throw Exception('File upload presign response is empty.');
    }
    final uploadData = coerceToStringMap(envelope['data']) ?? const {};
    final uploadUrl = uploadData['uploadUrl']?.toString() ?? '';
    final headers = coerceToStringMap(uploadData['headers']) ?? const {};
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
  }

  @override
  Future<MedicineRecognitionResult> recognizeMedicine(String imageUrl) async {
    final response = await dio.post<Object>(
      LucentApiPaths.medicinesRecognize,
      data: <String, Object?>{'imageUrl': imageUrl},
    );
    final envelope = coerceToStringMap(response.data);
    if (envelope == null) {
      throw Exception('Recognize medicine response is empty.');
    }
    final data = Map<String, dynamic>.from(envelope['data'] as Map);
    return MedicineRecognitionResult(
      name: data['name'] as String? ?? '',
      approvalNumber: data['approvalNumber'] as String?,
    );
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
