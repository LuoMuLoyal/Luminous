//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/ingredient_reactions_response_reactions.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ingredient_reactions_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class IngredientReactionsResponse {
  /// Returns a new [IngredientReactionsResponse] instance.
  IngredientReactionsResponse({
    required this.source_,

    required this.rxnormCui,

    required this.sourceVersion,

    required this.reactions,
  });

  /// Knowledge source discriminator.
  @JsonKey(
    name: r'source',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        IngredientReactionsResponseSource_Enum.unknownDefaultOpenApi,
  )
  final IngredientReactionsResponseSource_Enum source_;

  /// RxNorm ingredient CUI the rows are keyed by.
  @JsonKey(name: r'rxnormCui', required: true, includeIfNull: false)
  final String rxnormCui;

  /// Upstream OnSIDES version the rows were imported from.
  @JsonKey(name: r'sourceVersion', required: true, includeIfNull: false)
  final String sourceVersion;

  /// Label-stated adverse reactions for this ingredient, strongest evidence first. Empty when the ingredient exists but has no statements.
  @JsonKey(name: r'reactions', required: true, includeIfNull: false)
  final List<IngredientReactionsResponseReactions> reactions;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IngredientReactionsResponse &&
          other.source_ == source_ &&
          other.rxnormCui == rxnormCui &&
          other.sourceVersion == sourceVersion &&
          other.reactions == reactions;

  @override
  int get hashCode =>
      source_.hashCode +
      rxnormCui.hashCode +
      sourceVersion.hashCode +
      reactions.hashCode;

  factory IngredientReactionsResponse.fromJson(Map<String, dynamic> json) =>
      _$IngredientReactionsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$IngredientReactionsResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Knowledge source discriminator.
enum IngredientReactionsResponseSource_Enum {
  @JsonValue(r'onsides')
  onsides(r'onsides'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const IngredientReactionsResponseSource_Enum(this.value);

  final String value;

  @override
  String toString() => value;
}
