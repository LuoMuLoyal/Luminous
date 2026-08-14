//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// Fixed product event name — enums only, no free text.
enum ProductEventName {
  /// Fixed product event name — enums only, no free text.
  @JsonValue(r'health_event_started')
  healthEventStarted(r'health_event_started'),

  /// Fixed product event name — enums only, no free text.
  @JsonValue(r'health_event_ended')
  healthEventEnded(r'health_event_ended'),

  /// Fixed product event name — enums only, no free text.
  @JsonValue(r'health_event_outcome_confirmed')
  healthEventOutcomeConfirmed(r'health_event_outcome_confirmed'),

  /// Fixed product event name — enums only, no free text.
  @JsonValue(r'suggestion_impression')
  suggestionImpression(r'suggestion_impression'),

  /// Fixed product event name — enums only, no free text.
  @JsonValue(r'suggestion_actioned')
  suggestionActioned(r'suggestion_actioned'),

  /// Fixed product event name — enums only, no free text.
  @JsonValue(r'review_opened')
  reviewOpened(r'review_opened'),

  /// Fixed product event name — enums only, no free text.
  @JsonValue(r'visit_summary_previewed')
  visitSummaryPreviewed(r'visit_summary_previewed'),

  /// Fixed product event name — enums only, no free text.
  @JsonValue(r'visit_summary_exported')
  visitSummaryExported(r'visit_summary_exported'),

  /// Fixed product event name — enums only, no free text.
  @JsonValue(r'visit_summary_share_created')
  visitSummaryShareCreated(r'visit_summary_share_created'),

  /// Fixed product event name — enums only, no free text.
  @JsonValue(r'visit_summary_share_opened')
  visitSummaryShareOpened(r'visit_summary_share_opened'),

  /// Fixed product event name — enums only, no free text.
  @JsonValue(r'visit_summary_share_revoked')
  visitSummaryShareRevoked(r'visit_summary_share_revoked'),

  /// Fixed product event name — enums only, no free text.
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const ProductEventName(this.value);

  final String value;

  @override
  String toString() => value;
}
