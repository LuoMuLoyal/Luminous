// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import 'package:retrofit/error_logger.dart';

import '../models/device_list_response_dto.dart';
import '../models/device_response_dto.dart';
import '../models/register_device_dto.dart';

part 'user_devices_api.g.dart';

@RestApi()
abstract class UserDevicesApi {
  factory UserDevicesApi(Dio dio, {String? baseUrl}) = _UserDevicesApi;

  /// Register or update a device for push notifications.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/user/user-devices')
  Future<DeviceResponseDto> userDevicesControllerRegisterV1({
    @Body() required RegisterDeviceDto body,
  });

  /// List registered devices
  @GET('/api/v1/user/user-devices')
  Future<DeviceListResponseDto> userDevicesControllerListV1();

  /// Unregister a device
  @DELETE('/api/v1/user/user-devices/{id}')
  Future<void> userDevicesControllerRemoveV1({@Path('id') required String id});
}
