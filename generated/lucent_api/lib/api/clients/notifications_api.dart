// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import 'package:retrofit/error_logger.dart';

import '../models/create_notification_dto.dart';
import '../models/notification_detail_response_dto.dart';
import '../models/notification_list_response_dto.dart';
import '../models/unread_count_response_dto.dart';

part 'notifications_api.g.dart';

@RestApi()
abstract class NotificationsApi {
  factory NotificationsApi(Dio dio, {String? baseUrl}) = _NotificationsApi;

  /// Create a notification (internal/test).
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/user/notifications')
  Future<NotificationListResponseDto> notificationsControllerCreateV1({
    @Body() required CreateNotificationDto body,
  });

  /// List user notifications
  @GET('/api/v1/user/notifications')
  Future<NotificationListResponseDto> notificationsControllerFindAllV1({
    @Query('page') required num page,
    @Query('pageSize') required num pageSize,
  });

  /// Get unread notification count
  @GET('/api/v1/user/notifications/unread-count')
  Future<UnreadCountResponseDto> notificationsControllerGetUnreadCountV1();

  /// Get a notification detail
  @GET('/api/v1/user/notifications/{id}')
  Future<NotificationDetailResponseDto> notificationsControllerFindOneV1({
    @Path('id') required String id,
  });

  /// Delete a notification
  @DELETE('/api/v1/user/notifications/{id}')
  Future<void> notificationsControllerRemoveV1({
    @Path('id') required String id,
  });

  /// Mark a notification as read
  @PATCH('/api/v1/user/notifications/{id}/read')
  Future<NotificationDetailResponseDto> notificationsControllerMarkAsReadV1({
    @Path('id') required String id,
  });

  /// Mark a notification as unread
  @PATCH('/api/v1/user/notifications/{id}/unread')
  Future<NotificationDetailResponseDto> notificationsControllerMarkAsUnreadV1({
    @Path('id') required String id,
  });

  /// Mark all notifications as read
  @PATCH('/api/v1/user/notifications/mark-all-read')
  Future<UnreadCountResponseDto> notificationsControllerMarkAllAsReadV1();
}
