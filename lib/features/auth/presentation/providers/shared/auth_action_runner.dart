import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/logger/app_logger.dart';
import 'package:luminous/core/network/api.dart';

/// Result of [runAuthAction].
typedef AuthActionResult<T> = ({T? value, String? error});

/// Runs [action] with unified error handling.
///
/// All auth form notifiers share the same pattern:
/// 1. call the remote data source
/// 2. on error, log via `talkerProvider` and map with `LucentErrorMapper`
///
/// This function encapsulates step 2 so each notifier only writes:
/// ```dart
/// final (value, error) = await runAuthAction(
///   ref: ref,
///   tag: 'LoginFormNotifier.submit',
///   action: () => remote.login(...),
/// );
/// if (error != null) { /* set error state */ return null; }
/// /* set success state */
/// ```
Future<AuthActionResult<T>> runAuthAction<T>({
  required Ref ref,
  required String tag,
  required Future<T> Function() action,
}) async {
  try {
    final value = await action();
    return (value: value, error: null);
  } catch (e) {
    ref.read(talkerProvider).error('$tag: failed: $e');
    return (value: null, error: LucentErrorMapper.fromObject(e).message);
  }
}
