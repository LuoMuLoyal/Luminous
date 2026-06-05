//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'o_auth_code_callback_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class OAuthCodeCallbackDto {
  /// Returns a new [OAuthCodeCallbackDto] instance.
  OAuthCodeCallbackDto({required this.code});

  /// OAuth 授权码
  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final String code;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OAuthCodeCallbackDto && other.code == code;

  @override
  int get hashCode => code.hashCode;

  factory OAuthCodeCallbackDto.fromJson(Map<String, dynamic> json) =>
      _$OAuthCodeCallbackDtoFromJson(json);

  Map<String, dynamic> toJson() => _$OAuthCodeCallbackDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
