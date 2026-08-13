//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_review_section_facts_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EventReviewSectionFactsDto {
  /// Returns a new [EventReviewSectionFactsDto] instance.
  EventReviewSectionFactsDto({required this.code, required this.arguments});

  /// Structured fact code; localized by the client.
  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final String code;

  /// Structured fact arguments for the client localizer.
  @JsonKey(name: r'arguments', required: true, includeIfNull: false)
  final Object arguments;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventReviewSectionFactsDto &&
          other.code == code &&
          other.arguments == arguments;

  @override
  int get hashCode => code.hashCode + arguments.hashCode;

  factory EventReviewSectionFactsDto.fromJson(Map<String, dynamic> json) =>
      _$EventReviewSectionFactsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$EventReviewSectionFactsDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
