//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// Upstream source used to anchor this medicine.
enum MedicineSource {
          /// Upstream source used to anchor this medicine.
      @JsonValue(r'drugbank')
      drugbank(r'drugbank'),
          /// Upstream source used to anchor this medicine.
      @JsonValue(r'cn')
      cn(r'cn'),
          /// Upstream source used to anchor this medicine.
      @JsonValue(r'manual')
      manual(r'manual'),
          /// Upstream source used to anchor this medicine.
      @JsonValue(r'unknown_default_open_api')
      unknownDefaultOpenApi(r'unknown_default_open_api');

  const MedicineSource(this.value);

  final String value;

  @override
  String toString() => value;
}
