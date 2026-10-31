//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/layout_list_response_surfaces_value.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'layout_list_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LayoutListResponse {
  /// Returns a new [LayoutListResponse] instance.
  LayoutListResponse({required this.surfaces});

  /// Stored layouts keyed by surface. A missing surface means the user never customised it.
  @JsonKey(name: r'surfaces', required: true, includeIfNull: false)
  final Map<String, LayoutListResponseSurfacesValue> surfaces;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LayoutListResponse && other.surfaces == surfaces;

  @override
  int get hashCode => surfaces.hashCode;

  factory LayoutListResponse.fromJson(Map<String, dynamic> json) =>
      _$LayoutListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LayoutListResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
