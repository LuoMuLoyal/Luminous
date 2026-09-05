//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'health_context_response_profile_emergency_contact.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HealthContextResponseProfileEmergencyContact {
  /// Returns a new [HealthContextResponseProfileEmergencyContact] instance.
  HealthContextResponseProfileEmergencyContact({
    required this.name,

    required this.phone,
  });

  @JsonKey(name: r'name', required: true, includeIfNull: true)
  final String? name;

  @JsonKey(name: r'phone', required: true, includeIfNull: true)
  final String? phone;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthContextResponseProfileEmergencyContact &&
          other.name == name &&
          other.phone == phone;

  @override
  int get hashCode =>
      (name == null ? 0 : name.hashCode) + (phone == null ? 0 : phone.hashCode);

  factory HealthContextResponseProfileEmergencyContact.fromJson(
    Map<String, dynamic> json,
  ) => _$HealthContextResponseProfileEmergencyContactFromJson(json);

  Map<String, dynamic> toJson() =>
      _$HealthContextResponseProfileEmergencyContactToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
