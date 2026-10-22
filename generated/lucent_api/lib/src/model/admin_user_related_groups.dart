//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/admin_user_related_groups_sections.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'admin_user_related_groups.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminUserRelatedGroups {
  /// Returns a new [AdminUserRelatedGroups] instance.
  AdminUserRelatedGroups({required this.key, required this.sections});

  @JsonKey(name: r'key', required: true, includeIfNull: false)
  final String key;

  @JsonKey(name: r'sections', required: true, includeIfNull: false)
  final List<AdminUserRelatedGroupsSections> sections;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminUserRelatedGroups &&
          other.key == key &&
          other.sections == sections;

  @override
  int get hashCode => key.hashCode + sections.hashCode;

  factory AdminUserRelatedGroups.fromJson(Map<String, dynamic> json) =>
      _$AdminUserRelatedGroupsFromJson(json);

  Map<String, dynamic> toJson() => _$AdminUserRelatedGroupsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
