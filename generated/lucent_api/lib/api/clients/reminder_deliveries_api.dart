// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import 'package:retrofit/error_logger.dart';

import '../models/reminder_delivery_list_response_dto.dart';

part 'reminder_deliveries_api.g.dart';

@RestApi()
abstract class ReminderDeliveriesApi {
  factory ReminderDeliveriesApi(Dio dio, {String? baseUrl}) =
      _ReminderDeliveriesApi;

  /// List reminder delivery audit logs.
  ///
  /// [date] - Optional scheduled date filter in YYYY-MM-DD format.
  ///
  /// [limit] - Maximum rows to return. Clamped to 1-100.
  @GET('/api/v1/user/reminder-deliveries')
  Future<ReminderDeliveryListResponseDto> reminderDeliveriesControllerListV1({
    @Query('date') String? date,
    @Query('limit') String? limit,
  });
}
