//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'emergency_contact_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EmergencyContactDto {
  /// Returns a new [EmergencyContactDto] instance.
  EmergencyContactDto({required this.name, required this.phone});

  /// Emergency contact name.
  @JsonKey(name: r'name', required: true, includeIfNull: true)
  final String? name;

  /// Emergency contact phone.
  @JsonKey(name: r'phone', required: true, includeIfNull: true)
  final String? phone;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmergencyContactDto &&
          other.name == name &&
          other.phone == phone;

  @override
  int get hashCode =>
      (name == null ? 0 : name.hashCode) + (phone == null ? 0 : phone.hashCode);

  factory EmergencyContactDto.fromJson(Map<String, dynamic> json) =>
      _$EmergencyContactDtoFromJson(json);

  Map<String, dynamic> toJson() => _$EmergencyContactDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
