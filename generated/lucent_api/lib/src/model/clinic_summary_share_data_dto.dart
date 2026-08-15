//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/clinic_summary_share_scope_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'clinic_summary_share_data_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ClinicSummaryShareDataDto {
  /// Returns a new [ClinicSummaryShareDataDto] instance.
  ClinicSummaryShareDataDto({
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
  final ClinicSummaryShareScopeDto? scope;

  /// Share fields the link may expose
  @JsonKey(name: r'selectedFields', required: false, includeIfNull: false)
  final List<String>? selectedFields;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClinicSummaryShareDataDto &&
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

  factory ClinicSummaryShareDataDto.fromJson(Map<String, dynamic> json) =>
      _$ClinicSummaryShareDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ClinicSummaryShareDataDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
