//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_review_data_sections_next_step_facts.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EventReviewDataSectionsNextStepFacts {
  /// Returns a new [EventReviewDataSectionsNextStepFacts] instance.
  EventReviewDataSectionsNextStepFacts({
    required this.code,

    required this.arguments,
  });

  /// Structured fact code; localized by the client.
  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final String code;

  /// Structured fact arguments for the client localizer.
  @JsonKey(name: r'arguments', required: true, includeIfNull: false)
  final Map<String, Object> arguments;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventReviewDataSectionsNextStepFacts &&
          other.code == code &&
          other.arguments == arguments;

  @override
  int get hashCode => code.hashCode + arguments.hashCode;

  factory EventReviewDataSectionsNextStepFacts.fromJson(
    Map<String, dynamic> json,
  ) => _$EventReviewDataSectionsNextStepFactsFromJson(json);

  Map<String, dynamic> toJson() =>
      _$EventReviewDataSectionsNextStepFactsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
