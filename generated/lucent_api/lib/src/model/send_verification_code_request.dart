//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'send_verification_code_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SendVerificationCodeRequest {
  /// Returns a new [SendVerificationCodeRequest] instance.
  SendVerificationCodeRequest({required this.email, required this.scene});

  /// 邮箱地址
  @JsonKey(name: r'email', required: true, includeIfNull: false)
  final String email;

  @JsonKey(
    name: r'scene',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        SendVerificationCodeRequestSceneEnum.unknownDefaultOpenApi,
  )
  final SendVerificationCodeRequestSceneEnum scene;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SendVerificationCodeRequest &&
          other.email == email &&
          other.scene == scene;

  @override
  int get hashCode => email.hashCode + scene.hashCode;

  factory SendVerificationCodeRequest.fromJson(Map<String, dynamic> json) =>
      _$SendVerificationCodeRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SendVerificationCodeRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum SendVerificationCodeRequestSceneEnum {
  @JsonValue(r'register')
  register(r'register'),
  @JsonValue(r'login')
  login(r'login'),
  @JsonValue(r'change-email')
  changeEmail(r'change-email'),
  @JsonValue(r'set-password')
  setPassword(r'set-password'),
  @JsonValue(r'delete-account')
  deleteAccount(r'delete-account'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const SendVerificationCodeRequestSceneEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
