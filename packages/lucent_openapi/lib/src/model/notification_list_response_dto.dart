//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/notification_list_item_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'notification_list_response_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class NotificationListResponseDto {
  /// Returns a new [NotificationListResponseDto] instance.
  NotificationListResponseDto({
    required this.code,

    required this.message,

    required this.items,

    required this.total,
  });

  /// Result code.
  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final num code;

  /// Message.
  @JsonKey(name: r'message', required: true, includeIfNull: false)
  final String message;

  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<NotificationListItemDto> items;

  /// Total count of notifications for the user.
  @JsonKey(name: r'total', required: true, includeIfNull: false)
  final num total;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationListResponseDto &&
          other.code == code &&
          other.message == message &&
          other.items == items &&
          other.total == total;

  @override
  int get hashCode =>
      code.hashCode + message.hashCode + items.hashCode + total.hashCode;

  factory NotificationListResponseDto.fromJson(Map<String, dynamic> json) =>
      _$NotificationListResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationListResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
