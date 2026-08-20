//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/notification_preferences_data_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'notification_preferences_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class NotificationPreferencesResponseDto {
  /// Returns a new [NotificationPreferencesResponseDto] instance.
  NotificationPreferencesResponseDto({
    required this.code,

    required this.message,

    required this.data,
  });

  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final num code;

  @JsonKey(name: r'message', required: true, includeIfNull: false)
  final String message;

  @JsonKey(name: r'data', required: true, includeIfNull: false)
  final NotificationPreferencesDataDto data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationPreferencesResponseDto &&
          other.code == code &&
          other.message == message &&
          other.data == data;

  @override
  int get hashCode => code.hashCode + message.hashCode + data.hashCode;

  factory NotificationPreferencesResponseDto.fromJson(
    Map<String, dynamic> json,
  ) => _$NotificationPreferencesResponseDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$NotificationPreferencesResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
