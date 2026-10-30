import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:luminous/shared/domain/failure.dart';

/// 把 `TaskEither` / 超时的成功值接进 Riverpod 的 `Future` 世界。
///
/// `AsyncValue` 的错误通道本来就承载成功/失败两态，是"显式处理"在这里的
/// 落地形态；但**裸 `throw failure` 表达的是一段隐式控制流**，既看不出失败
/// 从哪来，也让 lint 无法把它和真正的异常区分开。统一走这里：
///
/// - `Left(failure)` → [LucentFailureException]（携带原始 `LucentFailure`，
///   供 `AsyncValue.error` 与 UI 的错误映射使用）；
/// - 超时 → `LucentFailure.network(receiveTimeout)`，不再借 `TimeoutException`；
/// - 其余同步异常仍按原样抛出，交给上层既有的 catch。
///
/// 调用方仍是 `async` provider：返回值直接作为 provider 的结果，失败会自然
/// 落到 `AsyncValue.error`。
Future<T> unwrapFailure<T>(
  Future<Either<LucentFailure, T>> result, {
  String? timeoutMessage,
  Duration? timeout,
}) async {
  final Either<LucentFailure, T> either;
  try {
    final completed = timeout == null ? result : result.timeout(timeout);
    either = await completed;
  } on TimeoutException {
    throw LucentFailureException(
      LucentFailure.network(
        message: timeoutMessage ?? NetworkErrorCode.receiveTimeout.name,
        networkErrorCode: NetworkErrorCode.receiveTimeout,
      ),
    );
  }
  return either.fold(
    (failure) => throw LucentFailureException(failure),
    (value) => value,
  );
}

/// 配合 `TaskEither.timeout` 使用：把超时值也收敛成同一种 failure。
///
/// `Future<Either<L, T>>.timeout(onTimeout: () => Either.left(failure))`
/// 之后仍交给 [unwrapFailure]，超时就和其他失败走同一条通道。
LucentFailure timeoutFailure({
  required NetworkErrorCode code,
  required String message,
}) {
  return LucentFailure.network(message: message, networkErrorCode: code);
}

/// `LucentFailure` 在 Future 通道里的唯一表现形态。
///
/// 它实现 [Exception]（而不是 Error），并且永远携带原始的 failure，所以在
/// `AsyncError` 里解包不需要猜类型：`error is LucentFailureException`。
final class LucentFailureException implements Exception {
  const LucentFailureException(this.failure);

  final LucentFailure failure;

  @override
  String toString() => 'LucentFailureException($failure)';
}
