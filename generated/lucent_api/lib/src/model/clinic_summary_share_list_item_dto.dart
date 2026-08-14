//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/clinic_summary_share_scope_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'clinic_summary_share_list_item_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ClinicSummaryShareListItemDto {
  /// Returns a new [ClinicSummaryShareListItemDto] instance.
  ClinicSummaryShareListItemDto({
    required this.id,

    required this.createdAt,

    required this.expiresAt,

    required this.revokedAt,

    required this.accessCount,

    required this.firstAccessedAt,

    required this.lastAccessedAt,

    required this.scope,

    required this.selectedFields,
  });

  /// Persisted share record id (used for revocation). Never a token.
  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  /// Creation time in ISO 8601 format.
  @JsonKey(name: r'createdAt', required: true, includeIfNull: false)
  final String createdAt;

  /// Expiration time in ISO 8601 format.
  @JsonKey(name: r'expiresAt', required: true, includeIfNull: false)
  final String expiresAt;

  /// Revocation time in ISO 8601 format, or null while the share is active.
  @JsonKey(name: r'revokedAt', required: true, includeIfNull: true)
  final String? revokedAt;

  /// Number of successful public opens.
  @JsonKey(name: r'accessCount', required: true, includeIfNull: false)
  final num accessCount;

  /// First access time in ISO 8601 format, or null when never opened.
  @JsonKey(name: r'firstAccessedAt', required: true, includeIfNull: true)
  final String? firstAccessedAt;

  /// Last access time in ISO 8601 format, or null when never opened.
  @JsonKey(name: r'lastAccessedAt', required: true, includeIfNull: true)
  final String? lastAccessedAt;

  @JsonKey(name: r'scope', required: true, includeIfNull: false)
  final ClinicSummaryShareScopeDto scope;

  /// Share fields the link may expose.
  @JsonKey(name: r'selectedFields', required: true, includeIfNull: false)
  final List<String> selectedFields;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClinicSummaryShareListItemDto &&
          other.id == id &&
          other.createdAt == createdAt &&
          other.expiresAt == expiresAt &&
          other.revokedAt == revokedAt &&
          other.accessCount == accessCount &&
          other.firstAccessedAt == firstAccessedAt &&
          other.lastAccessedAt == lastAccessedAt &&
          other.scope == scope &&
          other.selectedFields == selectedFields;

  @override
  int get hashCode =>
      id.hashCode +
      createdAt.hashCode +
      expiresAt.hashCode +
      (revokedAt == null ? 0 : revokedAt.hashCode) +
      accessCount.hashCode +
      (firstAccessedAt == null ? 0 : firstAccessedAt.hashCode) +
      (lastAccessedAt == null ? 0 : lastAccessedAt.hashCode) +
      scope.hashCode +
      selectedFields.hashCode;

  factory ClinicSummaryShareListItemDto.fromJson(Map<String, dynamic> json) =>
      _$ClinicSummaryShareListItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ClinicSummaryShareListItemDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
