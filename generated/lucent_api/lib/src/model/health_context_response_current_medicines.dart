//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'health_context_response_current_medicines.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HealthContextResponseCurrentMedicines {
  /// Returns a new [HealthContextResponseCurrentMedicines] instance.
  HealthContextResponseCurrentMedicines({
    required this.id,

    required this.source_,

    required this.sourceRefId,

    required this.displayName,

    required this.strengthText,

    required this.doseText,

    required this.route,

    required this.startedAt,

    required this.endedAt,

    required this.isCurrent,

    required this.note,

    required this.sourcePayload,

    required this.createdAt,

    required this.updatedAt,
  });

  /// Current medicine id.
  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  /// Upstream source used to anchor this medicine.
  @JsonKey(
    name: r'source',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        HealthContextResponseCurrentMedicinesSource_Enum.unknownDefaultOpenApi,
  )
  final HealthContextResponseCurrentMedicinesSource_Enum source_;

  @JsonKey(name: r'sourceRefId', required: true, includeIfNull: true)
  final String? sourceRefId;

  /// Display name shown to the user.
  @JsonKey(name: r'displayName', required: true, includeIfNull: false)
  final String displayName;

  @JsonKey(name: r'strengthText', required: true, includeIfNull: true)
  final String? strengthText;

  @JsonKey(name: r'doseText', required: true, includeIfNull: true)
  final String? doseText;

  @JsonKey(name: r'route', required: true, includeIfNull: true)
  final String? route;

  @JsonKey(name: r'startedAt', required: true, includeIfNull: true)
  final String? startedAt;

  @JsonKey(name: r'endedAt', required: true, includeIfNull: true)
  final String? endedAt;

  /// Whether the medicine is currently active.
  @JsonKey(name: r'isCurrent', required: true, includeIfNull: false)
  final bool isCurrent;

  @JsonKey(name: r'note', required: true, includeIfNull: true)
  final String? note;

  /// Original source payload stored in jsonb.
  @JsonKey(name: r'sourcePayload', required: true, includeIfNull: true)
  final Object? sourcePayload;

  /// Created time in ISO 8601 format.
  @JsonKey(name: r'createdAt', required: true, includeIfNull: false)
  final String createdAt;

  /// Updated time in ISO 8601 format.
  @JsonKey(name: r'updatedAt', required: true, includeIfNull: false)
  final String updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthContextResponseCurrentMedicines &&
          other.id == id &&
          other.source_ == source_ &&
          other.sourceRefId == sourceRefId &&
          other.displayName == displayName &&
          other.strengthText == strengthText &&
          other.doseText == doseText &&
          other.route == route &&
          other.startedAt == startedAt &&
          other.endedAt == endedAt &&
          other.isCurrent == isCurrent &&
          other.note == note &&
          other.sourcePayload == sourcePayload &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode =>
      id.hashCode +
      source_.hashCode +
      (sourceRefId == null ? 0 : sourceRefId.hashCode) +
      displayName.hashCode +
      (strengthText == null ? 0 : strengthText.hashCode) +
      (doseText == null ? 0 : doseText.hashCode) +
      (route == null ? 0 : route.hashCode) +
      (startedAt == null ? 0 : startedAt.hashCode) +
      (endedAt == null ? 0 : endedAt.hashCode) +
      isCurrent.hashCode +
      (note == null ? 0 : note.hashCode) +
      (sourcePayload == null ? 0 : sourcePayload.hashCode) +
      createdAt.hashCode +
      updatedAt.hashCode;

  factory HealthContextResponseCurrentMedicines.fromJson(
    Map<String, dynamic> json,
  ) => _$HealthContextResponseCurrentMedicinesFromJson(json);

  Map<String, dynamic> toJson() =>
      _$HealthContextResponseCurrentMedicinesToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Upstream source used to anchor this medicine.
enum HealthContextResponseCurrentMedicinesSource_Enum {
  @JsonValue(r'drugbank')
  drugbank(r'drugbank'),
  @JsonValue(r'cn')
  cn(r'cn'),
  @JsonValue(r'manual')
  manual(r'manual'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const HealthContextResponseCurrentMedicinesSource_Enum(this.value);

  final String value;

  @override
  String toString() => value;
}
