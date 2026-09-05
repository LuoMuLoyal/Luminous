//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/clinic_summary_share_response_scope.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'clinic_summary_share_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ClinicSummaryShareResponse {
  /// Returns a new [ClinicSummaryShareResponse] instance.
  ClinicSummaryShareResponse({
    this.shareId,

    this.token,

    required this.shareUrl,

    required this.expiresAt,

    this.scope,

    this.selectedFields,
  });

  /// Persisted share record id (used for revocation). Always present on the create response; optional only because the legacy `createShareLink` service method (cache-only shares) does not emit it.
  @JsonKey(name: r'shareId', required: false, includeIfNull: false)
  final String? shareId;

  /// Plaintext token — returned exactly once at creation, never persisted or logged
  @JsonKey(name: r'token', required: false, includeIfNull: false)
  final String? token;

  /// Shareable URL
  @JsonKey(name: r'shareUrl', required: true, includeIfNull: false)
  final String shareUrl;

  /// Expiration time (ISO 8601)
  @JsonKey(name: r'expiresAt', required: true, includeIfNull: false)
  final String expiresAt;

  @JsonKey(name: r'scope', required: false, includeIfNull: false)
  final ClinicSummaryShareResponseScope? scope;

  /// Share fields the link may expose
  @JsonKey(name: r'selectedFields', required: false, includeIfNull: false)
  final List<String>? selectedFields;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClinicSummaryShareResponse &&
          other.shareId == shareId &&
          other.token == token &&
          other.shareUrl == shareUrl &&
          other.expiresAt == expiresAt &&
          other.scope == scope &&
          other.selectedFields == selectedFields;

  @override
  int get hashCode =>
      shareId.hashCode +
      token.hashCode +
      shareUrl.hashCode +
      expiresAt.hashCode +
      scope.hashCode +
      selectedFields.hashCode;

  factory ClinicSummaryShareResponse.fromJson(Map<String, dynamic> json) =>
      _$ClinicSummaryShareResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ClinicSummaryShareResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
