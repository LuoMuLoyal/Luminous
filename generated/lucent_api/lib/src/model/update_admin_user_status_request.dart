//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_admin_user_status_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateAdminUserStatusRequest {
  /// Returns a new [UpdateAdminUserStatusRequest] instance.
  UpdateAdminUserStatusRequest({required this.status});

  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        UpdateAdminUserStatusRequestStatusEnum.unknownDefaultOpenApi,
  )
  final UpdateAdminUserStatusRequestStatusEnum status;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateAdminUserStatusRequest && other.status == status;

  @override
  int get hashCode => status.hashCode;

  factory UpdateAdminUserStatusRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateAdminUserStatusRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateAdminUserStatusRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum UpdateAdminUserStatusRequestStatusEnum {
  @JsonValue(r'active')
  active(r'active'),
  @JsonValue(r'suspended')
  suspended(r'suspended'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const UpdateAdminUserStatusRequestStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
