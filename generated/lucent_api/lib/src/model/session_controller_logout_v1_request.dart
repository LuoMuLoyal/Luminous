//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'session_controller_logout_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SessionControllerLogoutV1Request {
  /// Returns a new [SessionControllerLogoutV1Request] instance.
  SessionControllerLogoutV1Request({required this.refreshToken});

  /// 刷新令牌
  @JsonKey(name: r'refreshToken', required: true, includeIfNull: false)
  final String refreshToken;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionControllerLogoutV1Request &&
          other.refreshToken == refreshToken;

  @override
  int get hashCode => refreshToken.hashCode;

  factory SessionControllerLogoutV1Request.fromJson(
    Map<String, dynamic> json,
  ) => _$SessionControllerLogoutV1RequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$SessionControllerLogoutV1RequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
