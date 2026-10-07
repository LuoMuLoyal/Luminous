//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_admin_safety_tip_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateAdminSafetyTipRequest {
  /// Returns a new [UpdateAdminSafetyTipRequest] instance.
  UpdateAdminSafetyTipRequest({
    this.contentZh,

    this.contentEn,

    this.category,

    this.sortOrder,

    this.isActive,
  });

  @JsonKey(name: r'contentZh', required: false, includeIfNull: false)
  final String? contentZh;

  @JsonKey(name: r'contentEn', required: false, includeIfNull: false)
  final String? contentEn;

  @JsonKey(name: r'category', required: false, includeIfNull: false)
  final String? category;

  // minimum: 0
  // maximum: 1000000
  @JsonKey(name: r'sortOrder', required: false, includeIfNull: false)
  final int? sortOrder;

  @JsonKey(name: r'isActive', required: false, includeIfNull: false)
  final bool? isActive;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateAdminSafetyTipRequest &&
          other.contentZh == contentZh &&
          other.contentEn == contentEn &&
          other.category == category &&
          other.sortOrder == sortOrder &&
          other.isActive == isActive;

  @override
  int get hashCode =>
      contentZh.hashCode +
      contentEn.hashCode +
      category.hashCode +
      sortOrder.hashCode +
      isActive.hashCode;

  factory UpdateAdminSafetyTipRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateAdminSafetyTipRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateAdminSafetyTipRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
