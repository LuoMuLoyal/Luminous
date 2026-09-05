//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_review_data_sections_what_happened_facts.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EventReviewDataSectionsWhatHappenedFacts {
  /// Returns a new [EventReviewDataSectionsWhatHappenedFacts] instance.
  EventReviewDataSectionsWhatHappenedFacts({
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
      other is EventReviewDataSectionsWhatHappenedFacts &&
          other.code == code &&
          other.arguments == arguments;

  @override
  int get hashCode => code.hashCode + arguments.hashCode;

  factory EventReviewDataSectionsWhatHappenedFacts.fromJson(
    Map<String, dynamic> json,
  ) => _$EventReviewDataSectionsWhatHappenedFactsFromJson(json);

  Map<String, dynamic> toJson() =>
      _$EventReviewDataSectionsWhatHappenedFactsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
