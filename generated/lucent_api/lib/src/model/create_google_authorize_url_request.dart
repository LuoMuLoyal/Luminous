//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_google_authorize_url_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateGoogleAuthorizeUrlRequest {
  /// Returns a new [CreateGoogleAuthorizeUrlRequest] instance.
  CreateGoogleAuthorizeUrlRequest({this.callbackUri});

  /// Google 授权完成后的客户端回跳地址
  @JsonKey(name: r'callbackUri', required: false, includeIfNull: false)
  final String? callbackUri;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateGoogleAuthorizeUrlRequest &&
          other.callbackUri == callbackUri;

  @override
  int get hashCode => callbackUri.hashCode;

  factory CreateGoogleAuthorizeUrlRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateGoogleAuthorizeUrlRequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$CreateGoogleAuthorizeUrlRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
