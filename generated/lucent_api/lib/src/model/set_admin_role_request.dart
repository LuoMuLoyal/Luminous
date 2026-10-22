//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'set_admin_role_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SetAdminRoleRequest {
  /// Returns a new [SetAdminRoleRequest] instance.
  SetAdminRoleRequest({required this.role});

  @JsonKey(
    name: r'role',
    required: true,
    includeIfNull: false,
    unknownEnumValue: SetAdminRoleRequestRoleEnum.unknownDefaultOpenApi,
  )
  final SetAdminRoleRequestRoleEnum role;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetAdminRoleRequest && other.role == role;

  @override
  int get hashCode => role.hashCode;

  factory SetAdminRoleRequest.fromJson(Map<String, dynamic> json) =>
      _$SetAdminRoleRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SetAdminRoleRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum SetAdminRoleRequestRoleEnum {
  @JsonValue(r'SUPER_ADMIN')
  SUPER_ADMIN(r'SUPER_ADMIN'),
  @JsonValue(r'ADMIN')
  ADMIN(r'ADMIN'),
  @JsonValue(r'EDITOR')
  EDITOR(r'EDITOR'),
  @JsonValue(r'VIEWER')
  VIEWER(r'VIEWER'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const SetAdminRoleRequestRoleEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
