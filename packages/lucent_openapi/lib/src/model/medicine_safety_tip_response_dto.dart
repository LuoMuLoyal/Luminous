//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'medicine_safety_tip_response_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineSafetyTipResponseDto {
  /// Returns a new [MedicineSafetyTipResponseDto] instance.
  MedicineSafetyTipResponseDto({
    required this.id,

    required this.text,

    required this.category,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'text', required: true, includeIfNull: false)
  final String text;

  @JsonKey(name: r'category', required: true, includeIfNull: false)
  final String category;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineSafetyTipResponseDto &&
          other.id == id &&
          other.text == text &&
          other.category == category;

  @override
  int get hashCode => id.hashCode + text.hashCode + category.hashCode;

  factory MedicineSafetyTipResponseDto.fromJson(Map<String, dynamic> json) =>
      _$MedicineSafetyTipResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MedicineSafetyTipResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
