import 'package:dio/dio.dart';
import 'package:lucent_openapi/lucent_openapi.dart' hide DoseLogStatus;

enum DoseLogStatus { taken, skipped, missed, planned }

class DoseLogItem {
  final String id;
  final String? currentMedicineId;
  final DoseLogStatus status;
  final String scheduledFor;
  final String? doseText;
  final String? note;
  final String createdAt;
  const DoseLogItem({
    required this.id,
    this.currentMedicineId,
    required this.status,
    required this.scheduledFor,
    this.doseText,
    this.note,
    required this.createdAt,
  });
}

class DoseLogRemoteDataSource {
  DoseLogRemoteDataSource({required this.api, required this.dio});
  final MedicineDoseLogsApi api;
  final Dio dio;

  Future<List<DoseLogItem>> fetchForDate(String date) async {
    final response = await dio.get<Object>(
      '/api/v1/me/medicine-dose-logs',
      queryParameters: {'date': date},
    );
    final body = _coerce(response.data);
    final data = body!['data'] as Map<String, dynamic>;
    return (data['items'] as List)
        .map<DoseLogItem>(
          (d) => DoseLogItem(
            id: (d as Map<String, dynamic>)['id'] as String,
            currentMedicineId: d['currentMedicineId'] as String?,
            status: _parseStatus(d['status'] as String),
            scheduledFor: d['scheduledFor'] as String,
            doseText: d['doseText'] as String?,
            note: d['note'] as String?,
            createdAt: d['createdAt'] as String,
          ),
        )
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
      '/api/v1/me/medicine-dose-logs',
      data: payload,
      options: Options(method: 'POST', contentType: Headers.jsonContentType),
    );
    final body = _coerce(response.data);
    final d = body!['data'] as Map<String, dynamic>;
    return DoseLogItem(
      id: d['id'] as String,
      currentMedicineId: d['currentMedicineId'] as String?,
      status: _parseStatus(d['status'] as String),
      scheduledFor: d['scheduledFor'] as String,
      doseText: d['doseText'] as String?,
      note: d['note'] as String?,
      createdAt: d['createdAt'] as String,
    );
  }

  DoseLogStatus _parseStatus(String s) =>
      DoseLogStatus.values.firstWhere((e) => e.name == s);

  Map<String, dynamic>? _coerce(Object? v) {
    if (v is Map<String, dynamic>) return v;
    if (v is Map) return v.map((k, val) => MapEntry(k.toString(), val));
    return null;
  }
}
