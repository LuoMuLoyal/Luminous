//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'admin_safety_tip_item.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminSafetyTipItem {
  /// Returns a new [AdminSafetyTipItem] instance.
  AdminSafetyTipItem({
    required this.id,

    required this.contentZh,

    required this.contentEn,

    required this.category,

    required this.sortOrder,

    required this.isActive,

    required this.updatedAt,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'contentZh', required: true, includeIfNull: false)
  final String contentZh;

  @JsonKey(name: r'contentEn', required: true, includeIfNull: false)
  final String contentEn;

  @JsonKey(name: r'category', required: true, includeIfNull: false)
  final String category;

  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'sortOrder', required: true, includeIfNull: false)
  final int sortOrder;

  @JsonKey(name: r'isActive', required: true, includeIfNull: false)
  final bool isActive;

  @JsonKey(name: r'updatedAt', required: true, includeIfNull: false)
  final DateTime updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminSafetyTipItem &&
          other.id == id &&
          other.contentZh == contentZh &&
          other.contentEn == contentEn &&
          other.category == category &&
          other.sortOrder == sortOrder &&
          other.isActive == isActive &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode =>
      id.hashCode +
      contentZh.hashCode +
      contentEn.hashCode +
      category.hashCode +
      sortOrder.hashCode +
      isActive.hashCode +
      updatedAt.hashCode;

  factory AdminSafetyTipItem.fromJson(Map<String, dynamic> json) =>
      _$AdminSafetyTipItemFromJson(json);

  Map<String, dynamic> toJson() => _$AdminSafetyTipItemToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
