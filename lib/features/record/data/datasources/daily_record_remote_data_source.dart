import 'package:dio/dio.dart';
import 'package:lucent_openapi/lucent_openapi.dart' hide DailyRecordKind;
import 'package:luminous/features/record/domain/entities/daily_record.dart';
import 'package:luminous/features/record/domain/entities/daily_record_inputs.dart';

class DailyRecordRemoteDataSource {
  DailyRecordRemoteDataSource({required this.api, required this.dio});

  final DailyRecordsApi api;
  final Dio dio;

  Future<DailyRecordListData> fetchRecords(String date, {String? kind, int page = 1, int pageSize = 50}) async {
    final response = await api.dailyRecordsControllerListV1(
      date: date,
      kind: kind,
      page: page.toString(),
      pageSize: pageSize.toString(),
    );
    final dto = response.data!.data!;
    return DailyRecordListData(
      items: dto.items.map(_toItem).toList(),
      total: dto.total,
    );
  }

  Future<DailyRecordSummaryData> fetchSummary(String date) async {
    final response = await api.dailyRecordsControllerSummaryV1(date: date);
    final dto = response.data!.data!;
    return DailyRecordSummaryData(
      summaries: dto.summaries.map((s) => DailyRecordSummary(
        kind: _parseKind(s.kind.value),
        count: s.count,
        latest: s.latest != null ? _toItem(s.latest!) : null,
      )).toList(),
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

    final response = await _write('POST', '/api/v1/me/daily-records', payload);
    return _toItem(response);
  }

  Future<DailyRecordItem> update(String id, DailyRecordUpdateInput input) async {
    final payload = <String, dynamic>{};
    _putIfChanged(payload, 'kind', input.kind, (v) => (v as DailyRecordKind).name);
    _putIfChanged<String?>(payload, 'occurredAt', input.occurredAt, (v) => v as String?);
    _putIfChanged<String?>(payload, 'title', input.title, (v) => v as String?);
    _putIfChanged<String?>(payload, 'value', input.value, (v) => v as String?);
    _putIfChanged<String?>(payload, 'unit', input.unit, (v) => v as String?);
    _putIfChanged<String?>(payload, 'note', input.note, (v) => v as String?);

    final response = await _write('PATCH', '/api/v1/me/daily-records/$id', payload);
    return _toItem(response);
  }

  Future<void> delete(String id) async {
    await _write('DELETE', '/api/v1/me/daily-records/$id', null);
  }

  Future<DailyRecordItemDto> _write(String method, String path, Map<String, dynamic>? payload) async {
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

    final result = DailyRecordResponseDto.fromJson(body).data;
    return result!;
  }

  DailyRecordItem _toItem(DailyRecordItemDto item) {
    return DailyRecordItem(
      id: item.id,
      kind: _parseKind(item.kind.value),
      occurredAt: item.occurredAt,
      title: item.title as String?,
      value: item.value as String?,
      unit: item.unit as String?,
      note: item.note as String?,
      source: item.source_ as String?,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
    );
  }

  DailyRecordKind _parseKind(String value) {
    return DailyRecordKind.values.firstWhere((k) => k.name == value);
  }

  void _putIfNotNull(Map<String, dynamic> map, String key, Object? value) {
    if (value != null) {
      map[key] = value;
    }
  }

  void _putIfChanged<T>(Map<String, dynamic> payload, String key, Object value, T Function(dynamic v) convert) {
    if (identical(value, dailyRecordNoChange)) return;
    payload[key] = convert(value);
  }

  Map<String, dynamic>? _coerceToMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.map((k, v) => MapEntry(k.toString(), v));
    return null;
  }
}
