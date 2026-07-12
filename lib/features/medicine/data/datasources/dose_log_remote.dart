import 'package:dio/dio.dart';
import 'package:lucent_api/api/export.dart' hide DoseLogStatus;
import 'package:luminous/core/network/network_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dose_log_remote.g.dart';

enum DoseLogStatus { taken, skipped, missed, planned }

class DoseLogItem {
  final String id;
  final String? currentMedicineId;
  final String? reminderId;
  final DoseLogStatus status;
  final String scheduledFor;
  final String? scheduledTime;
  final String? doseText;
  final String? note;
  final String createdAt;
  final String updatedAt;
  const DoseLogItem({
    required this.id,
    this.currentMedicineId,
    this.reminderId,
    required this.status,
    required this.scheduledFor,
    this.scheduledTime,
    this.doseText,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });
}

class DoseLogRemoteDataSource {
  DoseLogRemoteDataSource({required this.api, required this.dio});
  final MedicineDoseLogsApi api;
  final Dio dio;

  Future<List<DoseLogItem>> fetchForDate(String date) async {
    final response = await dio.get<Object>(
      '/api/v1/user/medicine-dose-logs',
      queryParameters: {'date': date},
    );
    final body = _coerce(response.data);
    final data = body!['data'] as Map<String, dynamic>;
    return (data['items'] as List)
        .map<DoseLogItem>((d) => _fromJson(d as Map<String, dynamic>))
        .toList();
  }

  Future<DoseLogItem> create(
    String currentMedicineId,
    String status,
    String date,
  ) async {
    final payload = <String, dynamic>{
      'currentMedicineId': currentMedicineId,
      'status': status,
      'scheduledFor': date,
    };
    final response = await dio.request<Object>(
      '/api/v1/user/medicine-dose-logs',
      data: payload,
      options: Options(method: 'POST', contentType: Headers.jsonContentType),
    );
    final body = _coerce(response.data);
    return _fromJson(body!['data'] as Map<String, dynamic>);
  }

  Future<DoseLogItem> update(String doseLogId, String status) async {
    final response = await dio.request<Object>(
      '/api/v1/user/medicine-dose-logs/$doseLogId',
      data: <String, dynamic>{'status': status},
      options: Options(method: 'PATCH', contentType: Headers.jsonContentType),
    );
    final body = _coerce(response.data);
    return _fromJson(body!['data'] as Map<String, dynamic>);
  }

  Future<DoseLogItem> mark({
    required String currentMedicineId,
    required String status,
    required String date,
    String? reminderId,
    String? scheduledTime,
  }) async {
    final payload = <String, dynamic>{
      'currentMedicineId': currentMedicineId,
      if (_hasText(reminderId)) 'reminderId': reminderId,
      'status': status,
      'scheduledFor': date,
      if (_hasText(scheduledTime)) 'scheduledTime': scheduledTime,
    };
    final response = await dio.request<Object>(
      '/api/v1/user/medicine-dose-logs/mark',
      data: payload,
      options: Options(method: 'POST', contentType: Headers.jsonContentType),
    );
    final body = _coerce(response.data);
    return _fromJson(body!['data'] as Map<String, dynamic>);
  }

  DoseLogStatus _parseStatus(String s) =>
      DoseLogStatus.values.firstWhere((e) => e.name == s);

  DoseLogItem _fromJson(Map<String, dynamic> json) {
    return DoseLogItem(
      id: json['id'] as String,
      currentMedicineId: _optionalString(json['currentMedicineId']),
      reminderId: _optionalString(json['reminderId']),
      status: _parseStatus(json['status'] as String),
      scheduledFor: json['scheduledFor'] as String,
      scheduledTime: _optionalString(json['scheduledTime']),
      doseText: _optionalString(json['doseText']),
      note: _optionalString(json['note']),
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Map<String, dynamic>? _coerce(Object? v) {
    if (v is Map<String, dynamic>) return v;
    if (v is Map) return v.map((k, val) => MapEntry(k.toString(), val));
    return null;
  }

  String? _optionalString(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  bool _hasText(String? value) => value != null && value.trim().isNotEmpty;
}

@riverpod
DoseLogRemoteDataSource doseLogRemoteDataSource(Ref ref) {
  final api = ref.watch(lucentClientProvider).medicineDoseLogs;
  final dio = ref.watch(lucentDioClientProvider).dio;
  return DoseLogRemoteDataSource(api: api, dio: dio);
}
