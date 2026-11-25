//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/reaction_drugs_response_drugs.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reaction_drugs_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReactionDrugsResponse {
  /// Returns a new [ReactionDrugsResponse] instance.
  ReactionDrugsResponse({
    required this.source_,

    required this.meddraId,

    required this.meddraName,

    required this.drugs,
  });

  /// Knowledge source discriminator.
  @JsonKey(
    name: r'source',
    required: true,
    includeIfNull: false,
    unknownEnumValue: ReactionDrugsResponseSource_Enum.unknownDefaultOpenApi,
  )
  final ReactionDrugsResponseSource_Enum source_;

  /// MedDRA term id the rows are keyed by.
  @JsonKey(name: r'meddraId', required: true, includeIfNull: false)
  final String meddraId;

  /// MedDRA term name.
  @JsonKey(name: r'meddraName', required: true, includeIfNull: true)
  final String? meddraName;

  /// Drugs whose labels state this reaction, most-labelled first. Sorted by label count, not by importance.
  @JsonKey(name: r'drugs', required: true, includeIfNull: false)
  final List<ReactionDrugsResponseDrugs> drugs;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReactionDrugsResponse &&
          other.source_ == source_ &&
          other.meddraId == meddraId &&
          other.meddraName == meddraName &&
          other.drugs == drugs;

  @override
  int get hashCode =>
      source_.hashCode +
      meddraId.hashCode +
      (meddraName == null ? 0 : meddraName.hashCode) +
      drugs.hashCode;

  factory ReactionDrugsResponse.fromJson(Map<String, dynamic> json) =>
      _$ReactionDrugsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ReactionDrugsResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Knowledge source discriminator.
enum ReactionDrugsResponseSource_Enum {
  @JsonValue(r'onsides')
  onsides(r'onsides'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const ReactionDrugsResponseSource_Enum(this.value);

  final String value;

  @override
  String toString() => value;
}
