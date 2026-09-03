//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_safety_tip_response_dto_inner.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineSafetyTipResponseDtoInner {
  /// Returns a new [MedicineSafetyTipResponseDtoInner] instance.
  MedicineSafetyTipResponseDtoInner({
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
      other is MedicineSafetyTipResponseDtoInner &&
          other.id == id &&
          other.text == text &&
          other.category == category;

  @override
  int get hashCode => id.hashCode + text.hashCode + category.hashCode;

  factory MedicineSafetyTipResponseDtoInner.fromJson(
    Map<String, dynamic> json,
  ) => _$MedicineSafetyTipResponseDtoInnerFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MedicineSafetyTipResponseDtoInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
