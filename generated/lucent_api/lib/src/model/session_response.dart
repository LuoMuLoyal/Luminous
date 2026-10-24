//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/session_response_user.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'session_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SessionResponse {
  /// Returns a new [SessionResponse] instance.
  SessionResponse({required this.user, required this.expiresIn});

  @JsonKey(name: r'user', required: true, includeIfNull: false)
  final SessionResponseUser user;

  /// 访问令牌过期时间（秒）
  @JsonKey(name: r'expiresIn', required: true, includeIfNull: false)
  final num expiresIn;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionResponse &&
          other.user == user &&
          other.expiresIn == expiresIn;

  @override
  int get hashCode => user.hashCode + expiresIn.hashCode;

  factory SessionResponse.fromJson(Map<String, dynamic> json) =>
      _$SessionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SessionResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
