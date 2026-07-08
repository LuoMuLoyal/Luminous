// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import 'package:retrofit/error_logger.dart';

import '../models/create_medicine_reminder_dto.dart';
import '../models/medicine_reminder_list_response_dto.dart';
import '../models/medicine_reminder_response_dto.dart';
import '../models/update_medicine_reminder_dto.dart';

part 'medicine_reminders_api.g.dart';

@RestApi()
abstract class MedicineRemindersApi {
  factory MedicineRemindersApi(Dio dio, {String? baseUrl}) =
      _MedicineRemindersApi;

  /// List medicine reminder schedules.
  ///
  /// [activeOnly] - Set to true to return active reminders only.
  @GET('/api/v1/user/medicine-reminders')
  Future<MedicineReminderListResponseDto> medicineRemindersControllerListV1({
    @Query('activeOnly') String? activeOnly,
  });

  /// Create a medicine reminder schedule.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/user/medicine-reminders')
  Future<MedicineReminderResponseDto> medicineRemindersControllerCreateV1({
    @Body() required CreateMedicineReminderDto body,
  });

  /// Update a medicine reminder schedule.
  ///
  /// [body] - Name not received - field will be skipped.
  @PATCH('/api/v1/user/medicine-reminders/{id}')
  Future<MedicineReminderResponseDto> medicineRemindersControllerUpdateV1({
    @Path('id') required String id,
    @Body() required UpdateMedicineReminderDto body,
  });

  /// Soft-delete a medicine reminder schedule
  @DELETE('/api/v1/user/medicine-reminders/{id}')
  Future<void> medicineRemindersControllerDeleteV1({
    @Path('id') required String id,
  });
}
