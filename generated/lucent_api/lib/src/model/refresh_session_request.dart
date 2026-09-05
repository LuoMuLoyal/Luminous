//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'refresh_session_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RefreshSessionRequest {
  /// Returns a new [RefreshSessionRequest] instance.
  RefreshSessionRequest({required this.refreshToken});

  /// 刷新令牌
  @JsonKey(name: r'refreshToken', required: true, includeIfNull: false)
  final String refreshToken;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RefreshSessionRequest && other.refreshToken == refreshToken;

  @override
  int get hashCode => refreshToken.hashCode;

  factory RefreshSessionRequest.fromJson(Map<String, dynamic> json) =>
      _$RefreshSessionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RefreshSessionRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
