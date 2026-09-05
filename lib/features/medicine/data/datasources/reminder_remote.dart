import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/network/api.dart';
import 'package:luminous/core/network/contract/error_code.dart';
import 'package:luminous/core/network/map_utils.dart';
import 'package:luminous/features/medicine/domain/entities/reminder.dart';
import 'package:luminous/features/medicine/domain/repositories/reminder.dart';

export 'package:luminous/features/medicine/domain/entities/reminder.dart'
    show
        MedicineReminderItem,
        MedicineReminderWriteInput,
        MedicineReminderGroupUpsertInput,
        MedicineReminderSlotUpsertInput,
        ReminderDeliveryItem;

/// Remote data source for medicine reminders.
///
/// As the sole implementation of [ReminderRepository] it returns
/// `TaskEither` directly (today suggestion data source precedent); transport
/// errors are normalized through [LucentErrorMapper] — server business
/// failures keep their Problem Details code/status, network failures become
/// network Lefts. An empty success body is a `LucentFailure.network(
/// emptyResponse)`; a structurally malformed body is a thrown protocol
/// exception (logged via [appTalker] for diagnosability) that surfaces as a
/// `Left(unknown)`.
class MedicineReminderRemoteDataSource implements ReminderRepository {
  MedicineReminderRemoteDataSource({required this.api, required this.dio});

  final MedicineRemindersApi api;
  final Dio dio;

  @override
  TaskEither<LucentFailure, List<MedicineReminderItem>> fetchActive() =>
      _fetch(activeOnly: true);

  @override
  TaskEither<LucentFailure, List<MedicineReminderItem>> fetchAll() =>
      _fetch(activeOnly: false);

  TaskEither<LucentFailure, List<MedicineReminderItem>> _fetch({
    required bool activeOnly,
  }) {
    return TaskEither.tryCatch(() async {
      final response = await dio.request<Object>(
        LucentApiPaths.medicineReminders,
        queryParameters: <String, Object?>{
          if (activeOnly) 'activeOnly': 'true',
        },
        options: Options(method: 'GET'),
      );
      return _responseItems(
        response.data,
      ).map(_fromJson).toList(growable: false);
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, List<ReminderDeliveryItem>> fetchDeliveries({
    String? date,
    int limit = 20,
  }) {
    return TaskEither.tryCatch(() async {
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
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, MedicineReminderItem> create(
    MedicineReminderWriteInput input,
  ) {
    return TaskEither.tryCatch(() async {
      final response = await dio.request<Object>(
        LucentApiPaths.medicineReminders,
        data: input.toJson(),
        options: Options(method: 'POST', contentType: Headers.jsonContentType),
      );
      return _fromJson(_responseData(response.data));
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, MedicineReminderItem> update(
    String id,
    MedicineReminderWriteInput input,
  ) {
    return TaskEither.tryCatch(() async {
      final response = await dio.request<Object>(
        LucentApiPaths.medicineReminder(id),
        data: input.toJson(),
        options: Options(method: 'PATCH', contentType: Headers.jsonContentType),
      );
      return _fromJson(_responseData(response.data));
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, void> delete(String id) {
    return TaskEither.tryCatch(() async {
      await dio.request<Object>(
        LucentApiPaths.medicineReminder(id),
        options: Options(method: 'DELETE'),
      );
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, List<MedicineReminderItem>> upsertGroup(
    MedicineReminderGroupUpsertInput input,
  ) {
    // 消费再生契约的生成 API 方法（PUT /api/v1/user/medicine-reminders/group），
    // 请求/响应均走生成 DTO（UpsertGroupRequest /
    // MedicineReminderListResponse），与 openapi.json 对齐。
    return TaskEither.tryCatch(() async {
      final response = await api.upsertGroup(
        upsertGroupRequest:
            UpsertGroupRequest(
              currentMedicineId: input.currentMedicineId,
              label: _nonEmptyOrNull(input.label),
              daysOfWeek: input.daysOfWeek,
              // 方案 A 后契约把 startDate/endDate 定为可空日键 String?:
              // '' 表示"未选择日期"(表单 formatDateInput(null) 产出的形态),
              // 归一为 null 走省略;必填场景由调用侧契约保证非空,不做兜底。
              startDate: _dateKeyOrNull(input.startDate),
              endDate: _dateKeyOrNull(input.endDate),
              isActive: input.isActive,
              note: _nonEmptyOrNull(input.note),
              slots: input.slots
                  .map(
                    (slot) =>
                        UpsertGroupRequestSlots(
                          id: slot.id,
                          scheduledHour: slot.scheduledHour,
                          scheduledMinute: slot.scheduledMinute,
                        ),
                  )
                  .toList(growable: false),
            ),
      );
      final body = response.data;
      if (body == null) {
        throw LucentFailure.network(
          message: 'Empty reminder group response body',
          networkErrorCode: NetworkErrorCode.emptyResponse,
        );
      }
      return body.items.map(_fromDto).toList(growable: false);
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, void> reportLocalReceipt({
    required String reminderId,
    required String scheduledDate,
    required String scheduledTime,
  }) {
    return TaskEither.tryCatch(() async {
      await dio.request<Object>(
        LucentApiPaths.reminderDeliveryReceipts,
        data: <String, Object?>{
          'reminderId': reminderId,
          'scheduledDate': scheduledDate,
          'scheduledTime': scheduledTime,
        },
        options: Options(method: 'POST', contentType: Headers.jsonContentType),
      );
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, void> reportLocalCapability(String state) {
    return TaskEither.tryCatch(() async {
      await dio.request<Object>(
        LucentApiPaths.reminderDeliveryLocalCapability,
        data: <String, Object?>{'state': state},
        options: Options(method: 'PUT', contentType: Headers.jsonContentType),
      );
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
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

  MedicineReminderItem _fromDto(MedicineReminderListResponseItems dto) {
    return MedicineReminderItem(
      id: dto.id,
      currentMedicineId: dto.currentMedicineId,
      label: dto.label,
      scheduledHour: dto.scheduledHour.toInt(),
      scheduledMinute: dto.scheduledMinute.toInt(),
      daysOfWeek: dto.daysOfWeek
          ?.map((day) => day.toInt())
          .toList(growable: false),
      startDate: dto.startDate,
      endDate: dto.endDate,
      isActive: dto.isActive,
      note: dto.note,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
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
              appTalker.error(
                'MedicineReminderRemoteDataSource._responseItems: item is '
                'not a map: $item',
              );
              throw const FormatException('Reminder item is not a map');
            }
            return map;
          })
          .toList(growable: false);
    }
    appTalker.error(
      'MedicineReminderRemoteDataSource._responseItems: items is not a '
      'list: $items',
    );
    throw const FormatException('Reminder items is not a list');
  }

  Map<String, dynamic> _responseData(Object? value) {
    final body = coerceToStringMap(value);
    if (body == null) {
      throw LucentFailure.network(
        message: 'Empty reminder response body',
        networkErrorCode: NetworkErrorCode.emptyResponse,
      );
    }
    return body;
  }

  String? _optionalString(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  String? _nonEmptyOrNull(String? value) {
    if (value == null || value.isEmpty) return null;
    return value;
  }

  /// 可空日键归一:契约(方案 A)的 startDate/endDate 是 String? 日键,
  /// 空串表示"未选择日期"(表单 `formatDateInput(null)` 的产物),归为 null
  /// 让请求体省略该键;不再经 `DateTime.tryParse` 中转(那会把 null 静默化,
  /// 且 DateTime 序列化会带出时间部分塞进日键槽位)。
  String? _dateKeyOrNull(String? value) {
    if (value == null || value.isEmpty) return null;
    return value;
  }
}
