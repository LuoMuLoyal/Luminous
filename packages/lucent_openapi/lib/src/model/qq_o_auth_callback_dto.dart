//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'qq_o_auth_callback_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class QqOAuthCallbackDto {
  /// Returns a new [QqOAuthCallbackDto] instance.
  QqOAuthCallbackDto({required this.code, required this.state});

  /// QQ 授权码
  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final String code;

  /// 授权时生成的 state
  @JsonKey(name: r'state', required: true, includeIfNull: false)
  final String state;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QqOAuthCallbackDto && other.code == code && other.state == state;

  @override
  int get hashCode => code.hashCode + state.hashCode;

  factory QqOAuthCallbackDto.fromJson(Map<String, dynamic> json) =>
      _$QqOAuthCallbackDtoFromJson(json);

  Map<String, dynamic> toJson() => _$QqOAuthCallbackDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
