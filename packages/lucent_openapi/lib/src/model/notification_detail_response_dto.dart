//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/notification_detail_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'notification_detail_response_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class NotificationDetailResponseDto {
  /// Returns a new [NotificationDetailResponseDto] instance.
  NotificationDetailResponseDto({
    required this.code,

    required this.message,

    required this.data,
  });

  /// Result code.
  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final num code;

  /// Message.
  @JsonKey(name: r'message', required: true, includeIfNull: false)
  final String message;

  @JsonKey(name: r'data', required: true, includeIfNull: true)
  final NotificationDetailDto? data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationDetailResponseDto &&
          other.code == code &&
          other.message == message &&
          other.data == data;

  @override
  int get hashCode =>
      code.hashCode + message.hashCode + (data == null ? 0 : data.hashCode);

  factory NotificationDetailResponseDto.fromJson(Map<String, dynamic> json) =>
      _$NotificationDetailResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationDetailResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
