//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/admin_audit_log_list_response_items.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'admin_audit_log_list_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminAuditLogListResponse {
  /// Returns a new [AdminAuditLogListResponse] instance.
  AdminAuditLogListResponse({
    required this.items,

    required this.total,

    required this.page,

    required this.limit,
  });

  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<AdminAuditLogListResponseItems> items;

  // minimum: 0
  // maximum: 9007199254740991
  @JsonKey(name: r'total', required: true, includeIfNull: false)
  final int total;

  // maximum: 9007199254740991
  @JsonKey(name: r'page', required: true, includeIfNull: false)
  final int page;

  // maximum: 100
  @JsonKey(name: r'limit', required: true, includeIfNull: false)
  final int limit;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminAuditLogListResponse &&
          other.items == items &&
          other.total == total &&
          other.page == page &&
          other.limit == limit;

  @override
  int get hashCode =>
      items.hashCode + total.hashCode + page.hashCode + limit.hashCode;

  factory AdminAuditLogListResponse.fromJson(Map<String, dynamic> json) =>
      _$AdminAuditLogListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AdminAuditLogListResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
