//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'google_o_auth_callback_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GoogleOAuthCallbackDto {
  /// Returns a new [GoogleOAuthCallbackDto] instance.
  GoogleOAuthCallbackDto({required this.code, required this.state});

  /// Google 授权码
  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final String code;

  /// 授权时生成的 state
  @JsonKey(name: r'state', required: true, includeIfNull: false)
  final String state;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoogleOAuthCallbackDto &&
          other.code == code &&
          other.state == state;

  @override
  int get hashCode => code.hashCode + state.hashCode;

  factory GoogleOAuthCallbackDto.fromJson(Map<String, dynamic> json) =>
      _$GoogleOAuthCallbackDtoFromJson(json);

  Map<String, dynamic> toJson() => _$GoogleOAuthCallbackDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
