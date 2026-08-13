import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luminous/core/errors/error.dart';
import 'package:luminous/core/network/error_code.dart';

part 'pending_sync_error_details.freezed.dart';
part 'pending_sync_error_details.g.dart';

/// Structured details about why a pending sync item failed.
///
/// Stored as JSON in [PendingSyncItems.lastErrorDetails] so the UI can show
/// localized user-facing messages without parsing raw exception strings.
/// The raw exception text is also kept here for diagnostics / copy-to-support.
@freezed
abstract class PendingSyncErrorDetails with _$PendingSyncErrorDetails {
  const factory PendingSyncErrorDetails({
    String? message,
    int? code,
    int? statusCode,
    String? traceId,
    NetworkErrorCode? networkErrorCode,
    AppErrorKind? kind,
    String? raw,
  }) = _PendingSyncErrorDetails;

  factory PendingSyncErrorDetails.fromJson(Map<String, dynamic> json) =>
      _$PendingSyncErrorDetailsFromJson(json);

  const PendingSyncErrorDetails._();

  /// Builds details from a normalized [AppError].
  ///
  /// [raw] is the original exception string (typically `error.toString()`)
  /// used for the diagnostics panel.
  factory PendingSyncErrorDetails.fromAppError(AppError error, String raw) {
    return PendingSyncErrorDetails(
      message: error.message,
      code: error.code,
      statusCode: error.statusCode,
      traceId: error.traceId,
      networkErrorCode: error.networkErrorCode,
      kind: error.kind,
      raw: raw,
    );
  }
}
