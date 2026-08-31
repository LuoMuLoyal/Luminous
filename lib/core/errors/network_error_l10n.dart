import 'package:luminous/core/network/contract/error_code.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Maps a [NetworkErrorCode] to a localized user-facing string.
///
/// Network layer exceptions carry [NetworkErrorCode] instead of hardcoded
/// message text. This function is called at presentation sites that have
/// access to [AppLocalizations] (via `BuildContext`).
///
/// Usage:
/// ```dart
/// final l10n = AppLocalizations.of(context)!;
/// final message = appError.networkErrorCode != null
///     ? NetworkErrorL10n.map(appError.networkErrorCode!, l10n)
///     : appError.message;
/// ```
abstract final class NetworkErrorL10n {
  static String map(NetworkErrorCode code, AppLocalizations l10n) {
    return switch (code) {
      NetworkErrorCode.businessFailure => l10n.networkErrorBusinessFailure,
      NetworkErrorCode.emptyStreamResponse => l10n.networkErrorEmptyStream,
      NetworkErrorCode.invalidSsePayload => l10n.networkErrorInvalidSsePayload,
      NetworkErrorCode.emptyResponse => l10n.networkErrorEmptyResponse,
      NetworkErrorCode.connectionTimeout => l10n.networkErrorConnectionTimeout,
      NetworkErrorCode.sendTimeout => l10n.networkErrorSendTimeout,
      NetworkErrorCode.receiveTimeout => l10n.networkErrorReceiveTimeout,
      NetworkErrorCode.badCertificate => l10n.networkErrorBadCertificate,
      NetworkErrorCode.connectionError => l10n.networkErrorConnectionError,
      NetworkErrorCode.cancelled => l10n.networkErrorCancelled,
      NetworkErrorCode.badResponse => l10n.networkErrorBadResponse,
      NetworkErrorCode.unknown => l10n.networkErrorUnknown,
    };
  }
}
