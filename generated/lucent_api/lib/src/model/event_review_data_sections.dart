//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/event_review_data_sections_what_happened.dart';
import 'package:lucent_api/src/model/event_review_data_sections_completed_actions.dart';
import 'package:lucent_api/src/model/event_review_data_sections_key_changes.dart';
import 'package:lucent_api/src/model/event_review_data_sections_next_step.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_review_data_sections.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EventReviewDataSections {
  /// Returns a new [EventReviewDataSections] instance.
  EventReviewDataSections({
    required this.whatHappened,

    required this.keyChanges,

    required this.completedActions,

    required this.nextStep,
  });

  @JsonKey(name: r'whatHappened', required: true, includeIfNull: false)
  final EventReviewDataSectionsWhatHappened whatHappened;

  @JsonKey(name: r'keyChanges', required: true, includeIfNull: false)
  final EventReviewDataSectionsKeyChanges keyChanges;

  @JsonKey(name: r'completedActions', required: true, includeIfNull: false)
  final EventReviewDataSectionsCompletedActions completedActions;

  @JsonKey(name: r'nextStep', required: true, includeIfNull: false)
  final EventReviewDataSectionsNextStep nextStep;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventReviewDataSections &&
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

  factory EventReviewDataSections.fromJson(Map<String, dynamic> json) =>
      _$EventReviewDataSectionsFromJson(json);

  Map<String, dynamic> toJson() => _$EventReviewDataSectionsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
