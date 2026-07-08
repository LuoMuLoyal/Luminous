// ignore_for_file: use_of_void_result

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucent_api/api/export.dart';
import 'package:luminous/core/network/map_utils.dart';
import 'package:luminous/core/network/network_providers.dart';

class ScanRepository {
  const ScanRepository({
    required this.api,
    required this.dio,
    required this.filesApi,
  });

  final MedicinesApi api;
  final Dio dio;
  final FilesApi filesApi;

  Future<List<MedicineSearchItemDto>> search(String query) async {
    final response = await api.medicinesControllerSearchV1(
      source: Source.cn,
      q: query,
      page: 1,
      pageSize: 20,
    );
    return response.data;
  }

  Future<String> uploadImage({
    required List<int> bytes,
    required String contentType,
    int? sizeBytes,
    String? fileName,
  }) async {
    final presignResponse = await dio.post<Object>(
      '/api/v1/user/files/upload',
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

  Future<Map<String, dynamic>> recognizeMedicine(String imageUrl) async {
    final response = await dio.post<Object>(
      '/api/v1/medicines/recognize',
      data: <String, Object?>{'imageUrl': imageUrl},
    );
    final envelope = coerceToStringMap(response.data);
    if (envelope == null) {
      throw Exception('Recognize medicine response is empty.');
    }
    return Map<String, dynamic>.from(envelope['data'] as Map);
  }
}

final scanRepositoryProvider = Provider<ScanRepository>((ref) {
  return ScanRepository(
    api: ref.watch(lucentMedicinesApiProvider),
    dio: ref.watch(lucentDioClientProvider).dio,
    filesApi: ref.watch(lucentFilesApiProvider),
  );
});
