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

import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/errors/network_error_l10n.dart';
import 'package:luminous/core/network/error_mapper.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Returns a user-facing message for [error].
///
/// Normalizes [error] via [LucentErrorMapper.fromObject] (which passes
/// [LucentFailure] through unchanged) and returns the resulting `.message`.
///
/// When [l10n] is provided and the failure has a [NetworkErrorCode], the
/// message is mapped to a localized string via [NetworkErrorL10n.map]
/// instead of using the raw developer-facing message.
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

  if (l10n != null && failure.networkErrorCode != null) {
    return NetworkErrorL10n.map(failure.networkErrorCode!, l10n);
  }

  return failure.message.isNotEmpty ? failure.message : fallback;
}
