//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_admin_safety_tip_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateAdminSafetyTipRequest {
  /// Returns a new [CreateAdminSafetyTipRequest] instance.
  CreateAdminSafetyTipRequest({
    required this.contentZh,

    required this.contentEn,

    required this.category,

    required this.sortOrder,

    required this.isActive,
  });

  @JsonKey(name: r'contentZh', required: true, includeIfNull: false)
  final String contentZh;

  @JsonKey(name: r'contentEn', required: true, includeIfNull: false)
  final String contentEn;

  @JsonKey(name: r'category', required: true, includeIfNull: false)
  final String category;

  // minimum: 0
  // maximum: 1000000
  @JsonKey(name: r'sortOrder', required: true, includeIfNull: false)
  final int sortOrder;

  @JsonKey(name: r'isActive', required: true, includeIfNull: false)
  final bool isActive;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateAdminSafetyTipRequest &&
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

  factory CreateAdminSafetyTipRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateAdminSafetyTipRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateAdminSafetyTipRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
