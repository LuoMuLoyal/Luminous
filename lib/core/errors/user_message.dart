/// Extracts a user-friendly message from an arbitrary error object.
///
/// When an [AsyncValue] is in an error state, the error object can be an
/// [AppError], a [LucentApiException], a [DioException], or a plain
/// `Exception`. Displaying `error.toString()` directly exposes internal
/// details, stack traces, or English-only text to the user.
///
/// This helper normalizes any error into a display-safe string by delegating
/// to [LucentErrorMapper.toAppError], which already encodes the fallback
/// logic for each error category.
library;

import 'package:luminous/core/errors/error.dart';
import 'package:luminous/core/network/error_mapper.dart';

/// Returns a user-facing message for [error].
///
/// If [error] is an [AppError], uses its [AppError.message] directly.
/// Otherwise, converts via [LucentErrorMapper.toAppError] and returns the
/// resulting `.message`.
///
/// [fallback] is returned only if the mapped message is empty (which should
/// not happen in practice, but guards against regressions).
String userMessageFromError(Object? error, {String fallback = ''}) {
  if (error == null) return fallback;
  if (error is AppError) {
    return error.message.isNotEmpty ? error.message : fallback;
  }
  final mapped = LucentErrorMapper.toAppError(error);
  return mapped.message.isNotEmpty ? mapped.message : fallback;
}
