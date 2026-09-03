//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'local_controller_send_verification_code_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LocalControllerSendVerificationCodeV1Request {
  /// Returns a new [LocalControllerSendVerificationCodeV1Request] instance.
  LocalControllerSendVerificationCodeV1Request({
    required this.email,

    required this.scene,
  });

  /// 邮箱地址
  @JsonKey(name: r'email', required: true, includeIfNull: false)
  final String email;

  @JsonKey(
    name: r'scene',
    required: true,
    includeIfNull: false,
    unknownEnumValue: LocalControllerSendVerificationCodeV1RequestSceneEnum
        .unknownDefaultOpenApi,
  )
  final LocalControllerSendVerificationCodeV1RequestSceneEnum scene;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalControllerSendVerificationCodeV1Request &&
          other.email == email &&
          other.scene == scene;

  @override
  int get hashCode => email.hashCode + scene.hashCode;

  factory LocalControllerSendVerificationCodeV1Request.fromJson(
    Map<String, dynamic> json,
  ) => _$LocalControllerSendVerificationCodeV1RequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$LocalControllerSendVerificationCodeV1RequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum LocalControllerSendVerificationCodeV1RequestSceneEnum {
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

  const LocalControllerSendVerificationCodeV1RequestSceneEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
