//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'clinic_summary_profile_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ClinicSummaryProfileDto {
  /// Returns a new [ClinicSummaryProfileDto] instance.
  ClinicSummaryProfileDto({
    required this.nickname,
    this.age,
    required this.sexAtBirth,
    this.bloodType,
  });

  /// Masked display name (e.g. 张**)
  @JsonKey(name: r'nickname', required: true, includeIfNull: false)
  final String nickname;

  /// Age in years (derived from birthDate, never raw date)
  @JsonKey(name: r'age', required: false, includeIfNull: false)
  final num? age;

  /// Sex at birth
  @JsonKey(name: r'sexAtBirth', required: true, includeIfNull: true)
  final String? sexAtBirth;

  /// Blood type
  @JsonKey(name: r'bloodType', required: false, includeIfNull: false)
  final String? bloodType;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClinicSummaryProfileDto &&
          other.nickname == nickname &&
          other.age == age &&
          other.sexAtBirth == sexAtBirth &&
          other.bloodType == bloodType;

  @override
  int get hashCode =>
      nickname.hashCode +
      (age == null ? 0 : age.hashCode) +
      (sexAtBirth == null ? 0 : sexAtBirth.hashCode) +
      (bloodType == null ? 0 : bloodType.hashCode);

  factory ClinicSummaryProfileDto.fromJson(Map<String, dynamic> json) =>
      _$ClinicSummaryProfileDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ClinicSummaryProfileDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
