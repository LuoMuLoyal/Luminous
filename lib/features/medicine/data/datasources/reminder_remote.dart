import 'package:dio/dio.dart';
import 'package:luminous/core/network/api.dart';
import 'package:luminous/core/network/error_code.dart';
import 'package:luminous/core/network/map_utils.dart';
import 'package:luminous/features/medicine/domain/entities/reminder.dart';
import 'package:luminous/features/medicine/domain/repositories/reminder.dart';

export 'package:luminous/features/medicine/domain/entities/reminder.dart'
    show MedicineReminderItem, MedicineReminderWriteInput, ReminderDeliveryItem;

class MedicineReminderRemoteDataSource implements ReminderRepository {
  MedicineReminderRemoteDataSource({required this.api, required this.dio});

  final MedicineRemindersApi api;
  final Dio dio;

  @override
  Future<List<MedicineReminderItem>> fetchActive() => _fetch(activeOnly: true);

  @override
  Future<List<MedicineReminderItem>> fetchAll() => _fetch(activeOnly: false);

  Future<List<MedicineReminderItem>> _fetch({required bool activeOnly}) async {
    final response = await dio.request<Object>(
      LucentApiPaths.medicineReminders,
      queryParameters: <String, Object?>{if (activeOnly) 'activeOnly': 'true'},
      options: Options(method: 'GET'),
    );
    return _responseItems(response.data).map(_fromJson).toList(growable: false);
  }

  @override
  Future<List<ReminderDeliveryItem>> fetchDeliveries({
    String? date,
    int limit = 20,
  }) async {
    final response = await dio.request<Object>(
      LucentApiPaths.reminderDeliveries,
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

  @override
  Future<MedicineReminderItem> create(MedicineReminderWriteInput input) async {
    final response = await dio.request<Object>(
      LucentApiPaths.medicineReminders,
      data: input.toJson(),
      options: Options(method: 'POST', contentType: Headers.jsonContentType),
    );
    return _fromJson(_responseData(response.data));
  }

  @override
  Future<MedicineReminderItem> update(
    String id,
    MedicineReminderWriteInput input,
  ) async {
    final response = await dio.request<Object>(
      LucentApiPaths.medicineReminder(id),
      data: input.toJson(),
      options: Options(method: 'PATCH', contentType: Headers.jsonContentType),
    );
    return _fromJson(_responseData(response.data));
  }

  @override
  Future<void> delete(String id) async {
    await dio.request<Object>(
      LucentApiPaths.medicineReminder(id),
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
            final map = coerceToStringMap(item);
            if (map == null) {
              throw const LucentApiException(
                message: '用药提醒项格式异常',
                networkErrorCode: NetworkErrorCode.emptyResponse,
              );
            }
            return map;
          })
          .toList(growable: false);
    }
    throw const LucentApiException(
      message: '用药提醒列表格式异常',
      networkErrorCode: NetworkErrorCode.emptyResponse,
    );
  }

  Map<String, dynamic> _responseData(Object? value) {
    final body = coerceToStringMap(value);
    if (body == null) {
      throw const LucentApiException(
        message: '用药提醒响应体为空',
        networkErrorCode: NetworkErrorCode.emptyResponse,
      );
    }
    final data = coerceToStringMap(body['data']);
    if (data != null) return data;
    throw const LucentApiException(
      message: '用药提醒响应数据为空',
      networkErrorCode: NetworkErrorCode.emptyResponse,
    );
  }

  String? _optionalString(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}
