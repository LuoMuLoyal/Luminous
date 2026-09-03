//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'account_controller_unlink_identity_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AccountControllerUnlinkIdentityV1Request {
  /// Returns a new [AccountControllerUnlinkIdentityV1Request] instance.
  AccountControllerUnlinkIdentityV1Request({required this.password});

  /// 当前密码(敏感操作再认证用)
  @JsonKey(name: r'password', required: true, includeIfNull: false)
  final String password;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountControllerUnlinkIdentityV1Request &&
          other.password == password;

  @override
  int get hashCode => password.hashCode;

  factory AccountControllerUnlinkIdentityV1Request.fromJson(
    Map<String, dynamic> json,
  ) => _$AccountControllerUnlinkIdentityV1RequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$AccountControllerUnlinkIdentityV1RequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
