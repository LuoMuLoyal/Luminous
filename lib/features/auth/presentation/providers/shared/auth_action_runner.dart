import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/errors/result.dart';
import 'package:luminous/core/errors/run_guarded.dart';

/// Result of [runAuthAction].
typedef AuthActionResult<T> = ({T? value, String? error});

/// Runs [action] with unified error handling.
///
/// @deprecated Use [runGuarded] instead. This function is kept for backward
/// compatibility with existing auth form providers. New code should use
/// `runGuarded` which returns a [Result<T>] instead of a record type.
@Deprecated('Use runGuarded instead. Will be removed in a future refactor.')
Future<AuthActionResult<T>> runAuthAction<T>({
  required Ref ref,
  required String tag,
  required Future<T> Function() action,
}) async {
  final result = await runGuarded<T>(ref: ref, tag: tag, action: action);
  return switch (result) {
    Success(:final value) => (value: value, error: null),
    Failure(:final error) => (value: null, error: error.message),
  };
}
