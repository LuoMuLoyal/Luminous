//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'unread_count_response_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UnreadCountResponseDto {
  /// Returns a new [UnreadCountResponseDto] instance.
  UnreadCountResponseDto({
    required this.code,

    required this.message,

    required this.count,
  });

  /// Result code.
  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final num code;

  /// Message.
  @JsonKey(name: r'message', required: true, includeIfNull: false)
  final String message;

  /// Number of unread notifications.
  @JsonKey(name: r'count', required: true, includeIfNull: false)
  final num count;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnreadCountResponseDto &&
          other.code == code &&
          other.message == message &&
          other.count == count;

  @override
  int get hashCode => code.hashCode + message.hashCode + count.hashCode;

  factory UnreadCountResponseDto.fromJson(Map<String, dynamic> json) =>
      _$UnreadCountResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UnreadCountResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
