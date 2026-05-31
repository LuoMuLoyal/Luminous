//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// Pregnancy state for personalized medical guidance.
enum PregnancyState {
          /// Pregnancy state for personalized medical guidance.
      @JsonValue(r'not_applicable')
      notApplicable(r'not_applicable'),
          /// Pregnancy state for personalized medical guidance.
      @JsonValue(r'unknown')
      unknown(r'unknown'),
          /// Pregnancy state for personalized medical guidance.
      @JsonValue(r'not_pregnant')
      notPregnant(r'not_pregnant'),
          /// Pregnancy state for personalized medical guidance.
      @JsonValue(r'pregnant')
      pregnant(r'pregnant'),
          /// Pregnancy state for personalized medical guidance.
      @JsonValue(r'trying')
      trying(r'trying'),
          /// Pregnancy state for personalized medical guidance.
      @JsonValue(r'postpartum')
      postpartum(r'postpartum'),
          /// Pregnancy state for personalized medical guidance.
      @JsonValue(r'unknown_default_open_api')
      unknownDefaultOpenApi(r'unknown_default_open_api');

  const PregnancyState(this.value);

  final String value;

  @override
  String toString() => value;
}
