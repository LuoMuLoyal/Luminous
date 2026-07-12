import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/errors/app_error.dart';
import 'package:luminous/core/errors/result.dart';
import 'package:luminous/core/logger/app_logger.dart';
import 'package:luminous/core/network/error_mapper.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Runs [action] with unified error handling, returning a [Result].
///
/// On success, returns [Result.success] with the action's return value.
/// On any thrown exception, logs to [talker] with [tag] (which also
/// forwards to Sentry via [SentryTalkerObserver]) and returns
/// [Result.failure] with an [AppError] derived via [LucentErrorMapper.toAppError].
///
/// **Usage from a provider/notifier** (has `Ref`):
///
/// ```dart
/// final result = await runGuarded(
///   ref: ref,
///   tag: 'MyNotifier.doSomething',
///   action: () => repository.fetch(),
/// );
/// ```
///
/// **Usage from a widget** (has `WidgetRef`):
///
/// ```dart
/// final result = await runGuarded(
///   ref: ref,
///   tag: 'MyPage.handleTap',
///   action: () => controller.submit(),
/// );
/// ```
///
/// Both `Ref` and `WidgetRef` are accepted because they both expose
/// `read(talkerProvider)`.
Future<Result<T>> runGuarded<T>({
  required dynamic ref,
  required String tag,
  required Future<T> Function() action,
}) async {
  final Talker talker;
  if (ref is Ref) {
    talker = ref.read(talkerProvider);
  } else if (ref is WidgetRef) {
    talker = ref.read(talkerProvider);
  } else {
    talker = appTalker;
  }
  try {
    return Result.success(await action());
  } catch (e, st) {
    talker.handle(e, st, '$tag: failed');
    return Result.failure(LucentErrorMapper.toAppError(e));
  }
}
