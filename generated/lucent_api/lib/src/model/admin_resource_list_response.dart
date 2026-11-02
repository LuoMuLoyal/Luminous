//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'admin_resource_list_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminResourceListResponse {
  /// Returns a new [AdminResourceListResponse] instance.
  AdminResourceListResponse({
    required this.items,

    required this.total,

    required this.page,

    required this.limit,
  });

  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<Map<String, Object>> items;

  // minimum: 0
  // maximum: 9007199254740991
  @JsonKey(name: r'total', required: true, includeIfNull: false)
  final int total;

  // minimum: 0
  // maximum: 9007199254740991
  @JsonKey(name: r'page', required: true, includeIfNull: false)
  final int page;

  // minimum: 0
  // maximum: 100
  @JsonKey(name: r'limit', required: true, includeIfNull: false)
  final int limit;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminResourceListResponse &&
          other.items == items &&
          other.total == total &&
          other.page == page &&
          other.limit == limit;

  @override
  int get hashCode =>
      items.hashCode + total.hashCode + page.hashCode + limit.hashCode;

  factory AdminResourceListResponse.fromJson(Map<String, dynamic> json) =>
      _$AdminResourceListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AdminResourceListResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
