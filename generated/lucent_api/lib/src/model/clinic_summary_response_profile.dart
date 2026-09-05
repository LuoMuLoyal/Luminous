//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'clinic_summary_response_profile.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ClinicSummaryResponseProfile {
  /// Returns a new [ClinicSummaryResponseProfile] instance.
  ClinicSummaryResponseProfile({
    required this.nickname,

    this.age,

    required this.sexAtBirth,

    this.bloodType,
  });

  /// Masked display name (e.g. 张**)
  @JsonKey(name: r'nickname', required: true, includeIfNull: false)
  final String nickname;

  @JsonKey(name: r'age', required: false, includeIfNull: false)
  final num? age;

  @JsonKey(name: r'sexAtBirth', required: true, includeIfNull: true)
  final String? sexAtBirth;

  @JsonKey(name: r'bloodType', required: false, includeIfNull: false)
  final String? bloodType;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClinicSummaryResponseProfile &&
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

  factory ClinicSummaryResponseProfile.fromJson(Map<String, dynamic> json) =>
      _$ClinicSummaryResponseProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ClinicSummaryResponseProfileToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
