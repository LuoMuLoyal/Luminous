//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/admin_admin_list_response_items.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'admin_admin_list_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminAdminListResponse {
  /// Returns a new [AdminAdminListResponse] instance.
  AdminAdminListResponse({required this.items, required this.total});

  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<AdminAdminListResponseItems> items;

  // minimum: 0
  // maximum: 9007199254740991
  @JsonKey(name: r'total', required: true, includeIfNull: false)
  final int total;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminAdminListResponse &&
          other.items == items &&
          other.total == total;

  @override
  int get hashCode => items.hashCode + total.hashCode;

  factory AdminAdminListResponse.fromJson(Map<String, dynamic> json) =>
      _$AdminAdminListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AdminAdminListResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
