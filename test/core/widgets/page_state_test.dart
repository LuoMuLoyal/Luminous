import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/auth/session_state.dart';
import 'package:luminous/core/widgets/common/feedback/page_state.dart';

/// `AsyncValue` 是多维状态：`isLoading` 与 `hasValue`/`hasError` 不互斥。
/// 这组用例锁住 `resolvePageViewState` 对这些组合的判定，防止有人把它退化成
/// 三态 `when` —— 那会让刷新闪骨架、让刷新失败丢掉已有数据。
///
/// 各种组合都经由真实的 `FutureProvider` 产生，而不是 `copyWithPrevious`
/// （后者是 `@internal`，测试里不该直接调）。
void main() {
  const session = AuthSessionState(isAuthenticated: true);

  late Completer<int> pending;
  late ProviderContainer container;

  final probe = FutureProvider<int>((ref) => pending.future, name: 'probe');

  setUp(() {
    pending = Completer<int>();
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test('首帧加载 → Loading', () {
    final state = resolvePageViewState<int>(
      session: session,
      data: container.read(probe),
    );
    expect(state, isA<PageViewStateLoading<int>>());
    expect(state.dataOrNull, isNull);
  });

  test('有值后重算 → Refreshing，保留数据（不闪骨架）', () async {
    container.listen(probe, (_, _) {});
    pending.complete(42);
    await settle();

    // 重新计算：新一轮 future 还没完成，但旧值仍在。
    container.invalidate(probe);
    final async = container.read(probe);

    expect(async.hasValue, isTrue, reason: '旧值应被保留');
    expect(async.isLoading, isTrue, reason: '新一轮读取应处于加载中');

    final state = resolvePageViewState<int>(session: session, data: async);
    expect(state, isA<PageViewStateRefreshing<int>>());
    expect(state.dataOrNull, 42);
    expect(state.isDegraded, isTrue);
  });

  test('有值且稳定 → Ready', () async {
    container.listen(probe, (_, _) {});
    pending.complete(1);
    await settle();

    final state = resolvePageViewState<int>(
      session: session,
      data: container.read(probe),
    );
    expect(state, isA<PageViewStateReady<int>>());
    expect(state.dataOrNull, 1);
    expect(state.isDegraded, isFalse);
  });

  test('无值且失败 → FatalError，dataOrNull 为 null', () async {
    container.listen(probe, (_, _) {});
    pending.completeError('boom');
    await settle();

    final state = resolvePageViewState<int>(
      session: session,
      data: container.read(probe),
    );
    expect(state, isA<PageViewStateFatalError<int>>());
    expect(state.dataOrNull, isNull);
  });

  test('isInsufficient 对旧值同样生效（刷新时判定空态）', () async {
    container.listen(probe, (_, _) {});
    pending.complete(0);
    await settle();

    container.invalidate(probe);
    final state = resolvePageViewState<int>(
      session: session,
      data: container.read(probe),
      isInsufficient: (value) => value == 0,
    );
    expect(state, isA<PageViewStateEmptyInsufficient<int>>());
  });
}
