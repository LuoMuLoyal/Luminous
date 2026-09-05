//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'forgot_password_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ForgotPasswordResponse {
  /// Returns a new [ForgotPasswordResponse] instance.
  ForgotPasswordResponse({required this.cooldown, required this.message});

  /// 冷却时间（秒）
  @JsonKey(name: r'cooldown', required: true, includeIfNull: false)
  final num cooldown;

  /// 提示消息
  @JsonKey(name: r'message', required: true, includeIfNull: false)
  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ForgotPasswordResponse &&
          other.cooldown == cooldown &&
          other.message == message;

  @override
  int get hashCode => cooldown.hashCode + message.hashCode;

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ForgotPasswordResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
