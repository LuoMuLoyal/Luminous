//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_cascade_paths_response_cascades.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineCascadePathsResponseCascades {
  /// Returns a new [MedicineCascadePathsResponseCascades] instance.
  MedicineCascadePathsResponseCascades({
    required this.startDrug,

    required this.enzymeOne,

    required this.middleDrug,

    required this.enzymeTwo,

    required this.endDrug,
  });

  /// Starting drug name.
  @JsonKey(name: r'startDrug', required: true, includeIfNull: false)
  final String startDrug;

  /// First enzyme in the chain.
  @JsonKey(name: r'enzymeOne', required: true, includeIfNull: false)
  final String enzymeOne;

  /// Drug occupying the middle of the chain.
  @JsonKey(name: r'middleDrug', required: true, includeIfNull: false)
  final String middleDrug;

  /// Second enzyme in the chain.
  @JsonKey(name: r'enzymeTwo', required: true, includeIfNull: false)
  final String enzymeTwo;

  /// Drug whose exposure is affected downstream.
  @JsonKey(name: r'endDrug', required: true, includeIfNull: false)
  final String endDrug;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineCascadePathsResponseCascades &&
          other.startDrug == startDrug &&
          other.enzymeOne == enzymeOne &&
          other.middleDrug == middleDrug &&
          other.enzymeTwo == enzymeTwo &&
          other.endDrug == endDrug;

  @override
  int get hashCode =>
      startDrug.hashCode +
      enzymeOne.hashCode +
      middleDrug.hashCode +
      enzymeTwo.hashCode +
      endDrug.hashCode;

  factory MedicineCascadePathsResponseCascades.fromJson(
    Map<String, dynamic> json,
  ) => _$MedicineCascadePathsResponseCascadesFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MedicineCascadePathsResponseCascadesToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
