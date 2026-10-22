//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'admin_admin_list_response_items.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminAdminListResponseItems {
  /// Returns a new [AdminAdminListResponseItems] instance.
  AdminAdminListResponseItems({
    required this.userId,

    required this.email,

    required this.nickname,

    required this.userStatus,

    required this.role,

    required this.createdAt,

    required this.updatedAt,
  });

  @JsonKey(name: r'userId', required: true, includeIfNull: false)
  final String userId;

  @JsonKey(name: r'email', required: true, includeIfNull: false)
  final String email;

  @JsonKey(name: r'nickname', required: true, includeIfNull: true)
  final String? nickname;

  @JsonKey(
    name: r'userStatus',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        AdminAdminListResponseItemsUserStatusEnum.unknownDefaultOpenApi,
  )
  final AdminAdminListResponseItemsUserStatusEnum userStatus;

  @JsonKey(
    name: r'role',
    required: true,
    includeIfNull: false,
    unknownEnumValue: AdminAdminListResponseItemsRoleEnum.unknownDefaultOpenApi,
  )
  final AdminAdminListResponseItemsRoleEnum role;

  @JsonKey(name: r'createdAt', required: true, includeIfNull: false)
  final DateTime createdAt;

  @JsonKey(name: r'updatedAt', required: true, includeIfNull: false)
  final DateTime updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminAdminListResponseItems &&
          other.userId == userId &&
          other.email == email &&
          other.nickname == nickname &&
          other.userStatus == userStatus &&
          other.role == role &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode =>
      userId.hashCode +
      email.hashCode +
      (nickname == null ? 0 : nickname.hashCode) +
      userStatus.hashCode +
      role.hashCode +
      createdAt.hashCode +
      updatedAt.hashCode;

  factory AdminAdminListResponseItems.fromJson(Map<String, dynamic> json) =>
      _$AdminAdminListResponseItemsFromJson(json);

  Map<String, dynamic> toJson() => _$AdminAdminListResponseItemsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum AdminAdminListResponseItemsUserStatusEnum {
  @JsonValue(r'active')
  active(r'active'),
  @JsonValue(r'suspended')
  suspended(r'suspended'),
  @JsonValue(r'deleted')
  deleted(r'deleted'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const AdminAdminListResponseItemsUserStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum AdminAdminListResponseItemsRoleEnum {
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

  const AdminAdminListResponseItemsRoleEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
