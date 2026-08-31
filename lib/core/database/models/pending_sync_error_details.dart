import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/contract/error_code.dart';

part 'pending_sync_error_details.freezed.dart';
part 'pending_sync_error_details.g.dart';

/// Structured details about why a pending sync item failed.
///
/// Stored as JSON in [PendingSyncItems.lastErrorDetails] so the UI can show
/// localized user-facing messages without parsing raw exception strings.
/// The raw exception text is also kept here for diagnostics / copy-to-support.
///
/// Fields mirror the normalized [LucentFailure] shape at the repository
/// boundary: [kind] is a [LucentFailureKind] (not the retired legacy error
/// kind), and [code] is the Problem Details string code (not the retired
/// numeric application code).
@freezed
abstract class PendingSyncErrorDetails with _$PendingSyncErrorDetails {
  const factory PendingSyncErrorDetails({
    String? message,
    String? code,
    int? statusCode,
    String? traceId,
    NetworkErrorCode? networkErrorCode,
    LucentFailureKind? kind,
    String? raw,
  }) = _PendingSyncErrorDetails;

  /// Decodes persisted JSON, tolerating rows written by the pre-migration
  /// shape (legacy kind names and numeric `code`).
  ///
  /// Backward compatibility contract — a legacy row must never throw on
  /// decode (a throw would drop the whole entry's structured details):
  /// - `kind` legacy names `network` / `auth` / `server` / `business` /
  ///   `unknown` are mapped onto the matching [LucentFailureKind]; any other
  ///   unknown value falls back to [LucentFailureKind.unknown].
  /// - `code` as a legacy `int` is converted to its string form; the legacy
  ///   numeric validation codes 400001 / 400002 are normalized to the current
  ///   Problem Details code `VALIDATION_FAILED` so the UI message mapping
  ///   ("data invalid") keeps working for old rows.
  factory PendingSyncErrorDetails.fromJson(Map<String, dynamic> json) =>
      _$PendingSyncErrorDetailsFromJson(_normalizeLegacyJson(json));

  const PendingSyncErrorDetails._();

  /// Builds details from a normalized [LucentFailure].
  ///
  /// [raw] is the original exception string (typically `error.toString()`)
  /// used for the diagnostics panel.
  factory PendingSyncErrorDetails.fromLucentFailure(
    LucentFailure failure,
    String raw,
  ) {
    return PendingSyncErrorDetails(
      message: failure.message,
      code: failure.code,
      statusCode: failure.statusCode,
      traceId: failure.traceId,
      networkErrorCode: failure.networkErrorCode,
      kind: failure.kind,
      raw: raw,
    );
  }

  /// Maps legacy persisted values onto the current shape without ever
  /// throwing (see [PendingSyncErrorDetails.fromJson]).
  static Map<String, dynamic> _normalizeLegacyJson(Map<String, dynamic> json) {
    final result = Map<String, dynamic>.from(json);

    final kind = result['kind'];
    if (kind is String) {
      result['kind'] =
          _legacyKindToLucentFailureKind(kind)?.name ??
          LucentFailureKind.unknown.name;
    } else if (kind != null) {
      // Non-string legacy value — nothing meaningful to recover.
      result['kind'] = null;
    }

    final code = result['code'];
    if (code is num) {
      final truncated = code.toInt();
      result['code'] = switch (truncated) {
        // Legacy numeric validation codes 400001 / 400002.
        400001 || 400002 => 'VALIDATION_FAILED',
        _ => code == truncated ? '$truncated' : code.toString(),
      };
    } else if (code != null && code is! String) {
      result['code'] = null;
    }

    return result;
  }

  /// Maps a persisted kind string (legacy kind names or current
  /// [LucentFailureKind] names) onto the matching [LucentFailureKind].
  static LucentFailureKind? _legacyKindToLucentFailureKind(String value) {
    return switch (value) {
      'network' => LucentFailureKind.network,
      // Legacy 'auth' ↔ current authentication.
      'auth' || 'authentication' => LucentFailureKind.authentication,
      'server' => LucentFailureKind.server,
      'business' => LucentFailureKind.business,
      'unknown' => LucentFailureKind.unknown,
      _ => null,
    };
  }
}
