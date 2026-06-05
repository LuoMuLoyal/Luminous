//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/account_email_data_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'account_email_response_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AccountEmailResponseDto {
  /// Returns a new [AccountEmailResponseDto] instance.
  AccountEmailResponseDto({
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

  @JsonKey(name: r'data', required: true, includeIfNull: false)
  final AccountEmailDataDto data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountEmailResponseDto &&
          other.code == code &&
          other.message == message &&
          other.data == data;

  @override
  int get hashCode => code.hashCode + message.hashCode + data.hashCode;

  factory AccountEmailResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AccountEmailResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AccountEmailResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
