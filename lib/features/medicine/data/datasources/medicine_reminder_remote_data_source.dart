import 'package:dio/dio.dart';
import 'package:lucent_openapi/lucent_openapi.dart';

class MedicineReminderWriteInput {
  const MedicineReminderWriteInput({
    this.currentMedicineId,
    this.label,
    required this.scheduledHour,
    required this.scheduledMinute,
    this.daysOfWeek,
    this.isActive = true,
    this.note,
  });

  final String? currentMedicineId;
  final String? label;
  final int scheduledHour;
  final int scheduledMinute;
  final List<int>? daysOfWeek;
  final bool isActive;
  final String? note;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'currentMedicineId': currentMedicineId,
      'label': label,
      'scheduledHour': scheduledHour,
      'scheduledMinute': scheduledMinute,
      'daysOfWeek': daysOfWeek,
      'isActive': isActive,
      'note': note,
    };
  }
}

class MedicineReminderItem {
  const MedicineReminderItem({
    required this.id,
    this.currentMedicineId,
    this.label,
    required this.scheduledHour,
    required this.scheduledMinute,
    this.daysOfWeek,
    required this.isActive,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String? currentMedicineId;
  final String? label;
  final int scheduledHour;
  final int scheduledMinute;
  final List<int>? daysOfWeek;
  final bool isActive;
  final String? note;
  final String createdAt;
  final String updatedAt;

  String get timeLabel {
    final hour = scheduledHour.toString().padLeft(2, '0');
    final minute = scheduledMinute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  bool matchesDate(DateTime date) {
    final days = daysOfWeek;
    if (days == null) return true;
    final weekday = date.weekday % 7;
    return days.contains(weekday);
  }
}

class MedicineReminderRemoteDataSource {
  MedicineReminderRemoteDataSource({required this.api, required this.dio});

  final MedicineRemindersApi api;
  final Dio dio;

  Future<List<MedicineReminderItem>> fetchActive() => _fetch(activeOnly: true);

  Future<List<MedicineReminderItem>> fetchAll() => _fetch(activeOnly: false);

  Future<List<MedicineReminderItem>> _fetch({required bool activeOnly}) async {
    final response = await api.medicineRemindersControllerListV1(
      activeOnly: activeOnly ? 'true' : null,
    );
    return response.data?.data.items.map(_fromDto).toList(growable: false) ??
        const <MedicineReminderItem>[];
  }

  Future<MedicineReminderItem> create(MedicineReminderWriteInput input) async {
    final response = await dio.request<Object>(
      '/api/v1/me/medicine-reminders',
      data: input.toJson(),
      options: Options(method: 'POST', contentType: Headers.jsonContentType),
    );
    return _fromJson(_responseData(response.data));
  }

  Future<MedicineReminderItem> update(
    String id,
    MedicineReminderWriteInput input,
  ) async {
    final response = await dio.request<Object>(
      '/api/v1/me/medicine-reminders/$id',
      data: input.toJson(),
      options: Options(method: 'PATCH', contentType: Headers.jsonContentType),
    );
    return _fromJson(_responseData(response.data));
  }

  Future<void> delete(String id) async {
    await dio.request<Object>(
      '/api/v1/me/medicine-reminders/$id',
      options: Options(method: 'DELETE'),
    );
  }

  MedicineReminderItem _fromDto(MedicineReminderItemDto dto) {
    return MedicineReminderItem(
      id: dto.id,
      currentMedicineId: _optionalString(dto.currentMedicineId),
      label: _optionalString(dto.label),
      scheduledHour: dto.scheduledHour.toInt(),
      scheduledMinute: dto.scheduledMinute.toInt(),
      daysOfWeek: dto.daysOfWeek
          ?.map((day) => day.toInt())
          .toList(growable: false),
      isActive: dto.isActive,
      note: _optionalString(dto.note),
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  MedicineReminderItem _fromJson(Map<String, dynamic> json) {
    return MedicineReminderItem(
      id: json['id'] as String,
      currentMedicineId: _optionalString(json['currentMedicineId']),
      label: _optionalString(json['label']),
      scheduledHour: (json['scheduledHour'] as num).toInt(),
      scheduledMinute: (json['scheduledMinute'] as num).toInt(),
      daysOfWeek: (json['daysOfWeek'] as List?)
          ?.map((day) => (day as num).toInt())
          .toList(growable: false),
      isActive: json['isActive'] as bool,
      note: _optionalString(json['note']),
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Map<String, dynamic> _responseData(Object? value) {
    final body = _coerce(value);
    final data = body['data'];
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return data.map((key, val) => MapEntry('$key', val));
    throw StateError('Unexpected medicine reminder response body.');
  }

  Map<String, dynamic> _coerce(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.map((key, val) => MapEntry('$key', val));
    throw StateError('Unexpected medicine reminder response body.');
  }

  String? _optionalString(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}
