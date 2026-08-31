import 'package:luminous/core/database/daos/pending_sync.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/errors/network_error_l10n.dart';
import 'package:luminous/core/network/contract/error_code.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Problem Details code for a Lucent 400 validation failure.
///
/// The retired numeric validation codes (400001 / 400002) were normalized to
/// this code when decoding legacy persisted sync details.
const _validationFailedCode = 'VALIDATION_FAILED';

/// Maps a permanently failed sync entry to a localized, user-facing message.
///
/// Dispatches on the structured [PendingSyncErrorDetails] fields only —
/// [LucentFailureKind] / [NetworkErrorCode] / Problem Details code — never on
/// raw exception strings or guessed HTTP statuses. Never returns the raw
/// exception string here — that is kept behind the diagnostics expansion
/// panel.
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

    // Business validation errors — dispatched by the Problem Details code
    // (server-reported, not guessed from the HTTP status).
    if (code == _validationFailedCode) {
      return l10n.mineSyncFailedErrorDataInvalid;
    }

    // Auth/session errors.
    if (kind == LucentFailureKind.authentication) {
      return l10n.mineSyncFailedErrorAuth;
    }

    // Server-side errors.
    if (kind == LucentFailureKind.server) {
      return l10n.mineSyncFailedErrorServer;
    }

    // Network connectivity errors that did not carry a specific code.
    if (kind == LucentFailureKind.network) {
      return l10n.mineSyncFailedErrorNetwork;
    }
  }

  // Fallback for structured-but-unknown or legacy raw-only entries.
  return l10n.mineSyncFailedErrorUnknown;
}
