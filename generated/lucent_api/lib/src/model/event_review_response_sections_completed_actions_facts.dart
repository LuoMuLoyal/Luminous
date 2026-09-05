//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_review_response_sections_completed_actions_facts.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EventReviewResponseSectionsCompletedActionsFacts {
  /// Returns a new [EventReviewResponseSectionsCompletedActionsFacts] instance.
  EventReviewResponseSectionsCompletedActionsFacts({
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
      other is EventReviewResponseSectionsCompletedActionsFacts &&
          other.code == code &&
          other.arguments == arguments;

  @override
  int get hashCode => code.hashCode + arguments.hashCode;

  factory EventReviewResponseSectionsCompletedActionsFacts.fromJson(
    Map<String, dynamic> json,
  ) => _$EventReviewResponseSectionsCompletedActionsFactsFromJson(json);

  Map<String, dynamic> toJson() =>
      _$EventReviewResponseSectionsCompletedActionsFactsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
