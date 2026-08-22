//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'forgot_password_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ForgotPasswordResponseDto {
  /// Returns a new [ForgotPasswordResponseDto] instance.
  ForgotPasswordResponseDto({required this.cooldown, required this.message});

  /// 冷却时间（秒）
  @JsonKey(name: r'cooldown', required: true, includeIfNull: false)
  final num cooldown;

  /// 提示消息
  @JsonKey(name: r'message', required: true, includeIfNull: false)
  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ForgotPasswordResponseDto &&
          other.cooldown == cooldown &&
          other.message == message;

  @override
  int get hashCode => cooldown.hashCode + message.hashCode;

  factory ForgotPasswordResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ForgotPasswordResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
