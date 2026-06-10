import 'package:dio/dio.dart';
import 'package:lucent_openapi/lucent_openapi.dart';

class MedicineReminderWriteInput {
  const MedicineReminderWriteInput({
    this.currentMedicineId,
    this.label,
    required this.scheduledHour,
    required this.scheduledMinute,
    this.daysOfWeek,
    this.startDate,
    this.endDate,
    this.isActive = true,
    this.note,
  });

  final String? currentMedicineId;
  final String? label;
  final int scheduledHour;
  final int scheduledMinute;
  final List<int>? daysOfWeek;
  final String? startDate;
  final String? endDate;
  final bool isActive;
  final String? note;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'currentMedicineId': currentMedicineId,
      'label': label,
      'scheduledHour': scheduledHour,
      'scheduledMinute': scheduledMinute,
      'daysOfWeek': daysOfWeek,
      'startDate': startDate,
      'endDate': endDate,
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
    this.startDate,
    this.endDate,
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
  final String? startDate;
  final String? endDate;
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
    final currentDate = _dateOnly(date);
    final start = _parseDateOnly(startDate);
    if (start != null && currentDate.isBefore(start)) return false;
    final end = _parseDateOnly(endDate);
    if (end != null && currentDate.isAfter(end)) return false;

    final days = daysOfWeek;
    if (days == null) return true;
    final weekday = date.weekday % 7;
    return days.contains(weekday);
  }
}

class ReminderDeliveryItem {
  const ReminderDeliveryItem({
    required this.id,
    this.reminderId,
    this.deviceId,
    required this.channel,
    required this.status,
    required this.scheduledFor,
    this.deliveredAt,
    this.errorMessage,
    required this.createdAt,
  });

  final String id;
  final String? reminderId;
  final String? deviceId;
  final String channel;
  final String status;
  final String scheduledFor;
  final String? deliveredAt;
  final String? errorMessage;
  final String createdAt;
}

class MedicineReminderRemoteDataSource {
  MedicineReminderRemoteDataSource({required this.api, required this.dio});

  final MedicineRemindersApi api;
  final Dio dio;

  Future<List<MedicineReminderItem>> fetchActive() => _fetch(activeOnly: true);

  Future<List<MedicineReminderItem>> fetchAll() => _fetch(activeOnly: false);

  Future<List<MedicineReminderItem>> _fetch({required bool activeOnly}) async {
    final response = await dio.request<Object>(
      '/api/v1/me/medicine-reminders',
      queryParameters: <String, Object?>{if (activeOnly) 'activeOnly': 'true'},
      options: Options(method: 'GET'),
    );
    return _responseItems(response.data).map(_fromJson).toList(growable: false);
  }

  Future<List<ReminderDeliveryItem>> fetchDeliveries({
    String? date,
    int limit = 20,
  }) async {
    final response = await dio.request<Object>(
      '/api/v1/me/reminder-deliveries',
      queryParameters: <String, Object?>{
        if (date != null) 'date': date,
        'limit': limit,
      },
      options: Options(method: 'GET'),
    );
    return _responseItems(
      response.data,
    ).map(_deliveryFromJson).toList(growable: false);
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
      startDate: _optionalString(json['startDate']),
      endDate: _optionalString(json['endDate']),
      isActive: json['isActive'] as bool,
      note: _optionalString(json['note']),
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  ReminderDeliveryItem _deliveryFromJson(Map<String, dynamic> json) {
    return ReminderDeliveryItem(
      id: json['id'] as String,
      reminderId: _optionalString(json['reminderId']),
      deviceId: _optionalString(json['deviceId']),
      channel: json['channel'] as String,
      status: json['status'] as String,
      scheduledFor: json['scheduledFor'] as String,
      deliveredAt: _optionalString(json['deliveredAt']),
      errorMessage: _optionalString(json['errorMessage']),
      createdAt: json['createdAt'] as String,
    );
  }

  List<Map<String, dynamic>> _responseItems(Object? value) {
    final data = _responseData(value);
    final items = data['items'];
    if (items is List) {
      return items
          .map((item) {
            if (item is Map<String, dynamic>) return item;
            if (item is Map) {
              return item.map((key, val) => MapEntry('$key', val));
            }
            throw StateError('Unexpected medicine reminder item body.');
          })
          .toList(growable: false);
    }
    throw StateError('Unexpected medicine reminder list body.');
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

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

DateTime? _parseDateOnly(String? value) {
  if (value == null || value.isEmpty) return null;
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return null;
  return _dateOnly(parsed);
}
