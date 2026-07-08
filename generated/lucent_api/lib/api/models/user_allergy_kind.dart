// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

/// Allergy kind.
@JsonEnum()
enum UserAllergyKind {
  @JsonValue('drug')
  drug('drug'),
  @JsonValue('food')
  food('food'),
  @JsonValue('environment')
  environment('environment'),
  @JsonValue('other')
  other('other'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const UserAllergyKind(this.json);

  factory UserAllergyKind.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  String toJson() => json ?? 'null';

  @override
  String toString() => json ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<UserAllergyKind> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
