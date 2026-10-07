//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'admin_user_list_response_items.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminUserListResponseItems {
  /// Returns a new [AdminUserListResponseItems] instance.
  AdminUserListResponseItems({
    required this.id,

    required this.email,

    required this.nickname,

    required this.status,

    required this.emailVerified,

    required this.createdAt,

    required this.lastLoginAt,

    required this.adminRole,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'email', required: true, includeIfNull: false)
  final String email;

  @JsonKey(name: r'nickname', required: true, includeIfNull: true)
  final String? nickname;

  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        AdminUserListResponseItemsStatusEnum.unknownDefaultOpenApi,
  )
  final AdminUserListResponseItemsStatusEnum status;

  @JsonKey(name: r'emailVerified', required: true, includeIfNull: false)
  final bool emailVerified;

  @JsonKey(name: r'createdAt', required: true, includeIfNull: false)
  final DateTime createdAt;

  @JsonKey(name: r'lastLoginAt', required: true, includeIfNull: true)
  final DateTime? lastLoginAt;

  @JsonKey(
    name: r'adminRole',
    required: true,
    includeIfNull: true,
    unknownEnumValue:
        AdminUserListResponseItemsAdminRoleEnum.unknownDefaultOpenApi,
  )
  final AdminUserListResponseItemsAdminRoleEnum? adminRole;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminUserListResponseItems &&
          other.id == id &&
          other.email == email &&
          other.nickname == nickname &&
          other.status == status &&
          other.emailVerified == emailVerified &&
          other.createdAt == createdAt &&
          other.lastLoginAt == lastLoginAt &&
          other.adminRole == adminRole;

  @override
  int get hashCode =>
      id.hashCode +
      email.hashCode +
      (nickname == null ? 0 : nickname.hashCode) +
      status.hashCode +
      emailVerified.hashCode +
      createdAt.hashCode +
      (lastLoginAt == null ? 0 : lastLoginAt.hashCode) +
      (adminRole == null ? 0 : adminRole.hashCode);

  factory AdminUserListResponseItems.fromJson(Map<String, dynamic> json) =>
      _$AdminUserListResponseItemsFromJson(json);

  Map<String, dynamic> toJson() => _$AdminUserListResponseItemsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum AdminUserListResponseItemsStatusEnum {
  @JsonValue(r'active')
  active(r'active'),
  @JsonValue(r'suspended')
  suspended(r'suspended'),
  @JsonValue(r'deleted')
  deleted(r'deleted'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const AdminUserListResponseItemsStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum AdminUserListResponseItemsAdminRoleEnum {
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

  const AdminUserListResponseItemsAdminRoleEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
