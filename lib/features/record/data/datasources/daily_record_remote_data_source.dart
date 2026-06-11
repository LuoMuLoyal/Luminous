import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:lucent_openapi/lucent_openapi.dart' as lucent;
import 'package:luminous/features/record/domain/entities/daily_record.dart';
import 'package:luminous/features/record/domain/entities/daily_record_inputs.dart';

class DailyRecordRemoteDataSource {
  DailyRecordRemoteDataSource({required this.api, required this.dio});

  final lucent.DailyRecordsApi api;
  final Dio dio;

  Future<DailyRecordListData> fetchRecords(
    String date, {
    String? kind,
    int page = 1,
    int pageSize = 50,
  }) async {
    final response = await api.dailyRecordsControllerListV1(
      date: date,
      kind: kind,
      page: page.toString(),
      pageSize: pageSize.toString(),
    );
    final dto = response.data!.data;
    return DailyRecordListData(
      items: dto.items.map(_toItem).toList(),
      total: dto.total,
    );
  }

  Future<DailyRecordSummaryData> fetchSummary(String date) async {
    final response = await api.dailyRecordsControllerSummaryV1(date: date);
    final dto = response.data!.data;
    return DailyRecordSummaryData(
      summaries: dto.summaries
          .map(
            (s) => DailyRecordSummary(
              kind: _parseKind(s.kind.value),
              count: s.count,
              latest: s.latest != null ? _toItem(s.latest!) : null,
            ),
          )
          .toList(),
    );
  }

  Future<DailyRecordItem> get(String id) async {
    final response = await api.dailyRecordsControllerGetV1(id: id);
    return _toItem(response.data!.data);
  }

  Future<DailyRecordAttachmentInput> uploadImage(
    DailyRecordImageUploadInput input,
  ) async {
    final presignResponse = await api.dailyRecordsControllerCreateImageUploadV1(
      createDailyRecordImageUploadDto: lucent.CreateDailyRecordImageUploadDto(
        contentType: input.contentType,
        sizeBytes: input.sizeBytes,
        fileName: input.fileName,
      ),
    );
    final upload = presignResponse.data!.data;
    final headers = _coerceToStringMap(upload.headers);

    await dio.put<Object>(
      upload.uploadUrl,
      data: Uint8List.fromList(input.bytes),
      options: Options(
        headers: <String, Object?>{
          ...headers,
          Headers.contentLengthHeader: input.sizeBytes,
        },
        contentType: headers[Headers.contentTypeHeader] ?? input.contentType,
        extra: const <String, Object?>{
          'skipAuthorization': true,
          'skipAuthRefresh': true,
        },
      ),
    );

    return DailyRecordAttachmentInput(
      objectKey: upload.objectKey,
      bucket: upload.bucket,
      provider: upload.provider,
      fileName: input.fileName,
      contentType: input.contentType,
      sizeBytes: input.sizeBytes,
      publicUrl: _asStringOrNull(upload.publicUrl),
    );
  }

  Future<DailyRecordItem> create(DailyRecordCreateInput input) async {
    final payload = <String, dynamic>{
      'kind': input.kind.name,
      'occurredAt': input.occurredAt,
    };
    _putIfNotNull(payload, 'title', input.title);
    _putIfNotNull(payload, 'value', input.value);
    _putIfNotNull(payload, 'unit', input.unit);
    _putIfNotNull(payload, 'note', input.note);
    if (input.attachments.isNotEmpty) {
      payload['attachments'] = input.attachments
          .map(_attachmentToJson)
          .toList();
    }

    final response = await _write(
      'POST',
      '/api/v1/user/daily-records',
      payload,
    );
    return _toItem(response);
  }

  Future<DailyRecordItem> update(
    String id,
    DailyRecordUpdateInput input,
  ) async {
    final payload = <String, dynamic>{};
    _putIfChanged(
      payload,
      'kind',
      input.kind,
      (v) => (v as DailyRecordKind).name,
    );
    _putIfChanged<String?>(
      payload,
      'occurredAt',
      input.occurredAt,
      (v) => v as String?,
    );
    _putIfChanged<String?>(payload, 'title', input.title, (v) => v as String?);
    _putIfChanged<String?>(payload, 'value', input.value, (v) => v as String?);
    _putIfChanged<String?>(payload, 'unit', input.unit, (v) => v as String?);
    _putIfChanged<String?>(payload, 'note', input.note, (v) => v as String?);
    _putIfChanged<List<Map<String, dynamic>>>(
      payload,
      'attachments',
      input.attachments,
      (v) => (v as List<DailyRecordAttachmentInput>)
          .map(_attachmentToJson)
          .toList(),
    );

    final response = await _write(
      'PATCH',
      '/api/v1/user/daily-records/$id',
      payload,
    );
    return _toItem(response);
  }

  Future<void> delete(String id) async {
    final response = await dio.request<Object>(
      '/api/v1/user/daily-records/$id',
      options: Options(method: 'DELETE', contentType: Headers.jsonContentType),
    );

    final body = _coerceToMap(response.data);
    final code = body?['code'];
    if (body == null || code != 0) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: 'Daily record delete failed.',
      );
    }
  }

  Future<lucent.DailyRecordItemDto> _write(
    String method,
    String path,
    Map<String, dynamic>? payload,
  ) async {
    final response = await dio.request<Object>(
      path,
      data: payload,
      options: Options(method: method, contentType: Headers.jsonContentType),
    );

    final body = _coerceToMap(response.data);
    if (body == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: 'Daily record response is empty.',
      );
    }

    return lucent.DailyRecordResponseDto.fromJson(body).data;
  }

  DailyRecordItem _toItem(lucent.DailyRecordItemDto item) {
    return DailyRecordItem(
      id: item.id,
      kind: _parseKind(item.kind.value),
      occurredAt: item.occurredAt,
      title: item.title as String?,
      value: item.value as String?,
      unit: item.unit as String?,
      note: item.note as String?,
      source: item.source_ as String?,
      attachments: item.attachments.map(_toAttachment).toList(),
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
    );
  }

  DailyRecordAttachment _toAttachment(lucent.DailyRecordAttachmentDto item) {
    return DailyRecordAttachment(
      id: item.id,
      kind: _parseAttachmentKind(item.kind.value),
      objectKey: item.objectKey,
      bucket: _asStringOrNull(item.bucket),
      provider: _asStringOrNull(item.provider),
      fileName: _asStringOrNull(item.fileName),
      contentType: _asStringOrNull(item.contentType),
      sizeBytes: _asIntOrNull(item.sizeBytes),
      width: _asIntOrNull(item.width),
      height: _asIntOrNull(item.height),
      publicUrl: _asStringOrNull(item.publicUrl),
      createdAt: item.createdAt,
    );
  }

  DailyRecordKind _parseKind(String value) {
    return DailyRecordKind.values.firstWhere((k) => k.name == value);
  }

  DailyRecordAttachmentKind _parseAttachmentKind(String value) {
    return DailyRecordAttachmentKind.values.firstWhere(
      (k) => k.name == value,
      orElse: () => DailyRecordAttachmentKind.image,
    );
  }

  void _putIfNotNull(Map<String, dynamic> map, String key, Object? value) {
    if (value != null) {
      map[key] = value;
    }
  }

  void _putIfChanged<T>(
    Map<String, dynamic> payload,
    String key,
    Object? value,
    T Function(dynamic v) convert,
  ) {
    if (identical(value, dailyRecordNoChange)) return;
    payload[key] = convert(value);
  }

  Map<String, dynamic> _attachmentToJson(DailyRecordAttachmentInput input) {
    final payload = <String, dynamic>{
      'kind': DailyRecordAttachmentKind.image.name,
      'objectKey': input.objectKey,
    };
    _putIfNotNull(payload, 'bucket', input.bucket);
    _putIfNotNull(payload, 'provider', input.provider);
    _putIfNotNull(payload, 'fileName', input.fileName);
    _putIfNotNull(payload, 'contentType', input.contentType);
    _putIfNotNull(payload, 'sizeBytes', input.sizeBytes);
    _putIfNotNull(payload, 'width', input.width);
    _putIfNotNull(payload, 'height', input.height);
    _putIfNotNull(payload, 'publicUrl', input.publicUrl);
    return payload;
  }

  Map<String, dynamic>? _coerceToMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.map((k, v) => MapEntry(k.toString(), v));
    return null;
  }

  Map<String, String> _coerceToStringMap(Object? value) {
    final map = _coerceToMap(value);
    if (map == null) return const <String, String>{};
    return map.map((key, value) => MapEntry(key, value.toString()));
  }

  String? _asStringOrNull(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  int? _asIntOrNull(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
