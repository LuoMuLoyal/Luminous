//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_safety_tip_item.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineSafetyTipItem {
  /// Returns a new [MedicineSafetyTipItem] instance.
  MedicineSafetyTipItem({
    required this.id,

    required this.text,

    required this.category,
  });

  /// Safety tip id.
  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  /// Localized safety tip text.
  @JsonKey(name: r'text', required: true, includeIfNull: false)
  final String text;

  /// Tip category.
  @JsonKey(name: r'category', required: true, includeIfNull: false)
  final String category;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineSafetyTipItem &&
          other.id == id &&
          other.text == text &&
          other.category == category;

  @override
  int get hashCode => id.hashCode + text.hashCode + category.hashCode;

  factory MedicineSafetyTipItem.fromJson(Map<String, dynamic> json) =>
      _$MedicineSafetyTipItemFromJson(json);

  Map<String, dynamic> toJson() => _$MedicineSafetyTipItemToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
