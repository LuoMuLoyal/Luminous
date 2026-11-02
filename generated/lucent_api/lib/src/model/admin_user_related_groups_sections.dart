//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'admin_user_related_groups_sections.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminUserRelatedGroupsSections {
  /// Returns a new [AdminUserRelatedGroupsSections] instance.
  AdminUserRelatedGroupsSections({
    required this.resource,

    required this.items,

    required this.total,
  });

  @JsonKey(name: r'resource', required: true, includeIfNull: false)
  final String resource;

  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<Map<String, Object>> items;

  // minimum: 0
  // maximum: 9007199254740991
  @JsonKey(name: r'total', required: true, includeIfNull: false)
  final int total;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminUserRelatedGroupsSections &&
          other.resource == resource &&
          other.items == items &&
          other.total == total;

  @override
  int get hashCode => resource.hashCode + items.hashCode + total.hashCode;

  factory AdminUserRelatedGroupsSections.fromJson(Map<String, dynamic> json) =>
      _$AdminUserRelatedGroupsSectionsFromJson(json);

  Map<String, dynamic> toJson() => _$AdminUserRelatedGroupsSectionsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
