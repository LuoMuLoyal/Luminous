/// Extracts a user-friendly message from an arbitrary error object.
///
/// When an [AsyncValue] is in an error state, the error object can be an
/// [AppError], a [LucentFailure], a [DioException], or a plain
/// `Exception`. Displaying `error.toString()` directly exposes internal
/// details, stack traces, or English-only text to the user.
///
/// This helper normalizes any error into a display-safe string by delegating
/// to [LucentErrorMapper.toAppError], which already encodes the fallback
/// logic for each error category.
library;

import 'package:luminous/core/errors/error.dart';
import 'package:luminous/core/errors/network_error_l10n.dart';
import 'package:luminous/core/network/error_mapper.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Returns a user-facing message for [error].
///
/// If [error] is an [AppError], uses its [AppError.message] directly.
/// Otherwise, converts via [LucentErrorMapper.toAppError] and returns the
/// resulting `.message`.
///
/// When [l10n] is provided and the error has a [NetworkErrorCode], the
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

  final appError = error is AppError
      ? error
      : LucentErrorMapper.toAppError(error);

  if (l10n != null && appError.networkErrorCode != null) {
    return NetworkErrorL10n.map(appError.networkErrorCode!, l10n);
  }

  return appError.message.isNotEmpty ? appError.message : fallback;
}
