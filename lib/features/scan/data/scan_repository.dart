// ignore_for_file: use_of_void_result

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/core/network/lucent_network_providers.dart';

/// Helper to extract typed data from Dio Response.
dynamic _extractData(Response<void> r) => r.data;

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
      source_: 'cn',
      q: query,
      page: 1,
      pageSize: 20,
    );
    return response.data!.data;
  }

  Future<String> uploadImage({
    required List<int> bytes,
    required String contentType,
    int? sizeBytes,
    String? fileName,
  }) async {
    final presignResponse = await filesApi.filesControllerCreateUploadV1(
      createFileUploadDto: CreateFileUploadDto(
        contentType: contentType,
        sizeBytes: (sizeBytes ?? bytes.length) as num,
        fileName: fileName,
      ),
    );
    final envelope = _extractData(presignResponse) as Map<String, dynamic>;
    final uploadData = envelope['data'] as Map<String, dynamic>;
    final uploadUrl = uploadData['uploadUrl'] as String;
    final headers = uploadData['headers'] as Map<String, dynamic>? ?? {};
    final publicUrl = uploadData['publicUrl'] as String?;

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
    final response = await api.medicinesControllerRecognizeV1(
      recognizeMedicineDto: RecognizeMedicineDto(imageUrl: imageUrl),
    );
    final envelope = _extractData(response) as Map<String, dynamic>;
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
