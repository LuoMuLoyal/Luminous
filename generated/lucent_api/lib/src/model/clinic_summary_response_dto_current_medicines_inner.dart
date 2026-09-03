//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'clinic_summary_response_dto_current_medicines_inner.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ClinicSummaryResponseDtoCurrentMedicinesInner {
  /// Returns a new [ClinicSummaryResponseDtoCurrentMedicinesInner] instance.
  ClinicSummaryResponseDtoCurrentMedicinesInner({
    required this.displayName,

    this.doseText,
  });

  /// Generic medicine name
  @JsonKey(name: r'displayName', required: true, includeIfNull: false)
  final String displayName;

  @JsonKey(name: r'doseText', required: false, includeIfNull: false)
  final String? doseText;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClinicSummaryResponseDtoCurrentMedicinesInner &&
          other.displayName == displayName &&
          other.doseText == doseText;

  @override
  int get hashCode =>
      displayName.hashCode + (doseText == null ? 0 : doseText.hashCode);

  factory ClinicSummaryResponseDtoCurrentMedicinesInner.fromJson(
    Map<String, dynamic> json,
  ) => _$ClinicSummaryResponseDtoCurrentMedicinesInnerFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ClinicSummaryResponseDtoCurrentMedicinesInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
