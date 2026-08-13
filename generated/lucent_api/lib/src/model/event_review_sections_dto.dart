//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/event_review_section_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_review_sections_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EventReviewSectionsDto {
  /// Returns a new [EventReviewSectionsDto] instance.
  EventReviewSectionsDto({
    required this.whatHappened,

    required this.keyChanges,

    required this.completedActions,

    required this.nextStep,
  });

  @JsonKey(name: r'whatHappened', required: true, includeIfNull: false)
  final EventReviewSectionDto whatHappened;

  @JsonKey(name: r'keyChanges', required: true, includeIfNull: false)
  final EventReviewSectionDto keyChanges;

  @JsonKey(name: r'completedActions', required: true, includeIfNull: false)
  final EventReviewSectionDto completedActions;

  @JsonKey(name: r'nextStep', required: true, includeIfNull: false)
  final EventReviewSectionDto nextStep;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventReviewSectionsDto &&
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

  factory EventReviewSectionsDto.fromJson(Map<String, dynamic> json) =>
      _$EventReviewSectionsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$EventReviewSectionsDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
