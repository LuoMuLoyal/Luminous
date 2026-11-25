//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ingredient_reactions_response_reactions.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class IngredientReactionsResponseReactions {
  /// Returns a new [IngredientReactionsResponseReactions] instance.
  IngredientReactionsResponseReactions({
    required this.meddraId,

    required this.name,

    required this.termType,

    required this.labelCount,

    required this.labelSections,

    required this.sources,

    required this.confidenceMax,
  });

  /// MedDRA term id.
  @JsonKey(name: r'meddraId', required: true, includeIfNull: false)
  final String meddraId;

  /// MedDRA term name.
  @JsonKey(name: r'name', required: true, includeIfNull: false)
  final String name;

  /// MedDRA term type (LLT today).
  @JsonKey(name: r'termType', required: true, includeIfNull: false)
  final String termType;

  /// Number of distinct product labels that stated this reaction for the ingredient. A count of label statements, not an incidence.
  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'labelCount', required: true, includeIfNull: false)
  final int labelCount;

  /// Label sections the statement came from (AR / WP / NA / BW), AR first.
  @JsonKey(name: r'labelSections', required: true, includeIfNull: false)
  final List<String> labelSections;

  /// Regulatory sources of those labels (US / JP / UK / EU).
  @JsonKey(name: r'sources', required: true, includeIfNull: false)
  final List<String> sources;

  /// Highest extraction confidence across the statements. Null means unscored (the source omits a score), not a low score. Clients decide the threshold; the backend never filters.
  @JsonKey(name: r'confidenceMax', required: true, includeIfNull: true)
  final num? confidenceMax;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IngredientReactionsResponseReactions &&
          other.meddraId == meddraId &&
          other.name == name &&
          other.termType == termType &&
          other.labelCount == labelCount &&
          other.labelSections == labelSections &&
          other.sources == sources &&
          other.confidenceMax == confidenceMax;

  @override
  int get hashCode =>
      meddraId.hashCode +
      name.hashCode +
      termType.hashCode +
      labelCount.hashCode +
      labelSections.hashCode +
      sources.hashCode +
      (confidenceMax == null ? 0 : confidenceMax.hashCode);

  factory IngredientReactionsResponseReactions.fromJson(
    Map<String, dynamic> json,
  ) => _$IngredientReactionsResponseReactionsFromJson(json);

  Map<String, dynamic> toJson() =>
      _$IngredientReactionsResponseReactionsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
