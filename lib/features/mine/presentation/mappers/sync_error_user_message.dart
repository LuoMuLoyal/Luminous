import 'package:luminous/core/database/daos/pending_sync_dao.dart';
import 'package:luminous/core/errors/error.dart';
import 'package:luminous/core/errors/network_error_l10n.dart';
import 'package:luminous/core/network/error_code.dart';
import 'package:luminous/core/network/result_code.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Maps a permanently failed sync entry to a localized, user-facing message.
///
/// Never returns the raw exception string here — that is kept behind the
/// diagnostics expansion panel.
String mapSyncErrorToUserMessage(
  PendingSyncEntry entry,
  AppLocalizations l10n,
) {
  final details = entry.errorDetails;

  // Prefer structured details when available.
  if (details != null) {
    final networkCode = details.networkErrorCode;

    // Network-layer failures (timeouts, connection errors, ...).
    if (networkCode != null &&
        networkCode != NetworkErrorCode.businessFailure &&
        networkCode != NetworkErrorCode.unknown) {
      return NetworkErrorL10n.map(networkCode, l10n);
    }

    final kind = details.kind;
    final code = details.code;

    // Business validation errors.
    if (code == LucentResultCode.badRequest ||
        code == LucentResultCode.validationFailed) {
      return l10n.mineSyncFailedErrorDataInvalid;
    }

    // Auth/session errors.
    if (kind == AppErrorKind.auth) {
      return l10n.mineSyncFailedErrorAuth;
    }

    // Server-side errors.
    if (kind == AppErrorKind.server) {
      return l10n.mineSyncFailedErrorServer;
    }

    // Network connectivity errors that did not carry a specific code.
    if (kind == AppErrorKind.network) {
      return l10n.mineSyncFailedErrorNetwork;
    }
  }

  // Fallback for structured-but-unknown or legacy raw-only entries.
  return l10n.mineSyncFailedErrorUnknown;
}
