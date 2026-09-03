//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'clinic_summary_response_dto_profile.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ClinicSummaryResponseDtoProfile {
  /// Returns a new [ClinicSummaryResponseDtoProfile] instance.
  ClinicSummaryResponseDtoProfile({
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
      other is ClinicSummaryResponseDtoProfile &&
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

  factory ClinicSummaryResponseDtoProfile.fromJson(Map<String, dynamic> json) =>
      _$ClinicSummaryResponseDtoProfileFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ClinicSummaryResponseDtoProfileToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
