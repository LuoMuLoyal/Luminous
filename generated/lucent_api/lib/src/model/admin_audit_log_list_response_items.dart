//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'admin_audit_log_list_response_items.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminAuditLogListResponseItems {
  /// Returns a new [AdminAuditLogListResponseItems] instance.
  AdminAuditLogListResponseItems({
    required this.id,

    required this.actorUserId,

    required this.action,

    required this.resourceType,

    required this.resourceId,

    required this.createdAt,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'actorUserId', required: true, includeIfNull: false)
  final String actorUserId;

  @JsonKey(name: r'action', required: true, includeIfNull: false)
  final String action;

  @JsonKey(name: r'resourceType', required: true, includeIfNull: true)
  final String? resourceType;

  @JsonKey(name: r'resourceId', required: true, includeIfNull: true)
  final String? resourceId;

  @JsonKey(name: r'createdAt', required: true, includeIfNull: false)
  final DateTime createdAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminAuditLogListResponseItems &&
          other.id == id &&
          other.actorUserId == actorUserId &&
          other.action == action &&
          other.resourceType == resourceType &&
          other.resourceId == resourceId &&
          other.createdAt == createdAt;

  @override
  int get hashCode =>
      id.hashCode +
      actorUserId.hashCode +
      action.hashCode +
      (resourceType == null ? 0 : resourceType.hashCode) +
      (resourceId == null ? 0 : resourceId.hashCode) +
      createdAt.hashCode;

  factory AdminAuditLogListResponseItems.fromJson(Map<String, dynamic> json) =>
      _$AdminAuditLogListResponseItemsFromJson(json);

  Map<String, dynamic> toJson() => _$AdminAuditLogListResponseItemsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
