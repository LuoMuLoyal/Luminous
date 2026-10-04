/// Extracts a user-friendly message from an arbitrary error object.
///
/// When an [AsyncValue] is in an error state, the error object can be a
/// [LucentFailure], a [DioException], or a plain `Exception`. Displaying
/// `error.toString()` directly exposes internal details, stack traces, or
/// English-only text to the user.
///
/// This helper normalizes any error into a display-safe string by delegating
/// to [LucentErrorMapper.fromObject], which already encodes the fallback
/// logic for each error category.
library;

import 'package:luminous/core/errors/client_error_l10n.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/errors/network_error_l10n.dart';
import 'package:luminous/core/network/contract/error_mapper.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Returns a user-facing message for [error].
///
/// Normalizes [error] via [LucentErrorMapper.fromObject] (which passes
/// [LucentFailure] through unchanged) and returns the resulting `.message`.
///
/// When [l10n] is provided the failure resolves to localized copy instead of
/// the raw developer-facing message: [LucentFailure.clientErrorCode] first
/// (most specific — the client knows exactly what it refused), then
/// [LucentFailure.networkErrorCode] via [NetworkErrorL10n.map]. Failures
/// without either code fall back to the message the server sent.
///
/// [fallback] is returned only if the mapped message is empty (which should
/// not happen in practice, but guards against regressions).
String userMessageFromError(
  Object? error, {
  String fallback = '',
  AppLocalizations? l10n,
}) {
  if (error == null) return fallback;

  final failure = error is LucentFailure
      ? error
      : LucentErrorMapper.fromObject(error);

  if (l10n != null) {
    final clientErrorCode = failure.clientErrorCode;
    if (clientErrorCode != null) {
      return ClientErrorL10n.map(clientErrorCode, l10n);
    }
    final networkErrorCode = failure.networkErrorCode;
    if (networkErrorCode != null) {
      return NetworkErrorL10n.map(networkErrorCode, l10n);
    }
  }

  return failure.message.isNotEmpty ? failure.message : fallback;
}

/// [userMessageFromError] for state fields that signal "there is an error"
/// with `null`, and treat an empty message as "nothing to show".
///
/// Returns `null` when [error] is null or resolves to empty copy, so call
/// sites can keep their `if (message != null)` toast guard unchanged while the
/// state carries the error object instead of a ready-made sentence.
String? userMessageOrNull(Object? error, {AppLocalizations? l10n}) {
  if (error == null) return null;
  final message = userMessageFromError(error, l10n: l10n);
  return message.isEmpty ? null : message;
}
