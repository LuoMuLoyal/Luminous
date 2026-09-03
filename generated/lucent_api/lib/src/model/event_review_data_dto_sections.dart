//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/event_review_data_dto_sections_what_happened.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_review_data_dto_sections.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EventReviewDataDtoSections {
  /// Returns a new [EventReviewDataDtoSections] instance.
  EventReviewDataDtoSections({
    required this.whatHappened,

    required this.keyChanges,

    required this.completedActions,

    required this.nextStep,
  });

  @JsonKey(name: r'whatHappened', required: true, includeIfNull: false)
  final EventReviewDataDtoSectionsWhatHappened whatHappened;

  @JsonKey(name: r'keyChanges', required: true, includeIfNull: false)
  final EventReviewDataDtoSectionsWhatHappened keyChanges;

  @JsonKey(name: r'completedActions', required: true, includeIfNull: false)
  final EventReviewDataDtoSectionsWhatHappened completedActions;

  @JsonKey(name: r'nextStep', required: true, includeIfNull: false)
  final EventReviewDataDtoSectionsWhatHappened nextStep;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventReviewDataDtoSections &&
          other.whatHappened == whatHappened &&
          other.keyChanges == keyChanges &&
          other.completedActions == completedActions &&
          other.nextStep == nextStep;

  @override
  int get hashCode =>
      whatHappened.hashCode +
      keyChanges.hashCode +
      completedActions.hashCode +
      nextStep.hashCode;

  factory EventReviewDataDtoSections.fromJson(Map<String, dynamic> json) =>
      _$EventReviewDataDtoSectionsFromJson(json);

  Map<String, dynamic> toJson() => _$EventReviewDataDtoSectionsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
