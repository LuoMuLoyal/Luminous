//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// In-app surface where the event occurred; 'system' marks server-initiated events.
enum ProductEventSurface {
  /// In-app surface where the event occurred; 'system' marks server-initiated events.
  @JsonValue(r'today')
  today(r'today'),

  /// In-app surface where the event occurred; 'system' marks server-initiated events.
  @JsonValue(r'record')
  record(r'record'),

  /// In-app surface where the event occurred; 'system' marks server-initiated events.
  @JsonValue(r'review')
  review(r'review'),

  /// In-app surface where the event occurred; 'system' marks server-initiated events.
  @JsonValue(r'more')
  more(r'more'),

  /// In-app surface where the event occurred; 'system' marks server-initiated events.
  @JsonValue(r'notification')
  notification(r'notification'),

  /// In-app surface where the event occurred; 'system' marks server-initiated events.
  @JsonValue(r'system')
  system(r'system'),

  /// In-app surface where the event occurred; 'system' marks server-initiated events.
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const ProductEventSurface(this.value);

  final String value;

  @override
  String toString() => value;
}
