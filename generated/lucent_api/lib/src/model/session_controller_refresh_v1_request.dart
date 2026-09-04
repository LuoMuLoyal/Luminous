//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'session_controller_refresh_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SessionControllerRefreshV1Request {
  /// Returns a new [SessionControllerRefreshV1Request] instance.
  SessionControllerRefreshV1Request({required this.refreshToken});

  /// 刷新令牌
  @JsonKey(name: r'refreshToken', required: true, includeIfNull: false)
  final String refreshToken;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionControllerRefreshV1Request &&
          other.refreshToken == refreshToken;

  @override
  int get hashCode => refreshToken.hashCode;

  factory SessionControllerRefreshV1Request.fromJson(
    Map<String, dynamic> json,
  ) => _$SessionControllerRefreshV1RequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$SessionControllerRefreshV1RequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
