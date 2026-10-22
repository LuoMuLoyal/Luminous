//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/admin_user_related_groups.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'admin_user_related.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminUserRelated {
  /// Returns a new [AdminUserRelated] instance.
  AdminUserRelated({required this.userId, required this.groups});

  @JsonKey(name: r'userId', required: true, includeIfNull: false)
  final String userId;

  @JsonKey(name: r'groups', required: true, includeIfNull: false)
  final List<AdminUserRelatedGroups> groups;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminUserRelated &&
          other.userId == userId &&
          other.groups == groups;

  @override
  int get hashCode => userId.hashCode + groups.hashCode;

  factory AdminUserRelated.fromJson(Map<String, dynamic> json) =>
      _$AdminUserRelatedFromJson(json);

  Map<String, dynamic> toJson() => _$AdminUserRelatedToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
