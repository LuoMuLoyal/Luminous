import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/database/connection_providers.dart';
import 'package:luminous/core/database/daos/pending_sync.dart';
import 'package:luminous/core/database/models/pending_sync_error_details.dart';
import 'package:luminous/core/database/sync/worker.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/contract/error_code.dart';
import 'package:luminous/core/widgets/common/feedback/skeleton.dart';
import 'package:luminous/features/mine/presentation/pages/sync_failures.dart';
import 'package:luminous/features/mine/presentation/providers/sync_failures.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_forui_app.dart';

class _MockPendingSyncDao extends Mock implements PendingSyncDao {}

class _MockSyncWorker extends Mock implements SyncWorker {}

PendingSyncEntry _entry({String id = 'pending-1'}) => PendingSyncEntry(
  id: id,
  entityType: 'daily_record',
  entityId: 'record-1',
  operation: 'update',
  payload: '{}',
  createdAt: DateTime(2026, 8, 2, 12, 0),
  retryCount: 5,
  maxRetry: 5,
  lastError: 'DioException [connectionError]: network unavailable',
  errorDetails: const PendingSyncErrorDetails(
    message: 'Connection timed out',
    networkErrorCode: NetworkErrorCode.connectionError,
    kind: LucentFailureKind.network,
    raw: 'DioException [connectionError]: network unavailable',
  ),
);

Widget _app({
  required PendingSyncDao dao,
  required SyncWorker worker,
  FutureOr<List<PendingSyncEntry>> Function(Ref ref)? entries,
}) {
  return ProviderScope(
    overrides: [
      pendingSyncDaoProvider.overrideWithValue(dao),
      syncWorkerProvider.overrideWithValue(worker),
      syncFailedCountProvider.overrideWith((ref) async => 0),
      mineSyncFailedEntriesProvider.overrideWith(
        entries ?? (ref) async => [_entry()],
      ),
    ],
    child: const TestForuiApp(home: SyncFailuresPage()),
  );
}

void main() {
  testWidgets('renders the failed item with the user-facing message', (
    tester,
  ) async {
    final dao = _MockPendingSyncDao();
    final worker = _MockSyncWorker();

    await tester.pumpWidget(_app(dao: dao, worker: worker));
    await tester.pumpAndSettle();

    expect(find.text('同步失败详情'), findsOneWidget);
    expect(find.text('待处理项（1）'), findsOneWidget);
    expect(find.text('daily_record'), findsOneWidget);
    expect(find.text('record-1'), findsOneWidget);
    // User-facing message is shown; raw exception is hidden by default.
    expect(find.text('网络请求失败，请检查当前连接。'), findsOneWidget);
    expect(
      find.text('DioException [connectionError]: network unavailable'),
      findsNothing,
    );
  });

  testWidgets('shows a skeleton while the queue is loading', (tester) async {
    final dao = _MockPendingSyncDao();
    final worker = _MockSyncWorker();
    final pending = Completer<List<PendingSyncEntry>>();

    await tester.pumpWidget(
      _app(dao: dao, worker: worker, entries: (ref) => pending.future),
    );
    await tester.pump();

    expect(find.byType(InlineSkeletonSection), findsOneWidget);

    pending.complete([_entry()]);
    await tester.pump();
    await tester.pump();
    expect(find.byType(InlineSkeletonSection), findsNothing);
  });

  testWidgets('shows the empty state when nothing remains', (tester) async {
    final dao = _MockPendingSyncDao();
    final worker = _MockSyncWorker();

    await tester.pumpWidget(
      _app(dao: dao, worker: worker, entries: (ref) async => []),
    );
    await tester.pumpAndSettle();

    expect(find.text('当前没有待处理的同步失败项。'), findsOneWidget);
    expect(find.byKey(const Key('sync-failures-retry-all')), findsNothing);
  });

  testWidgets('diagnostics panel reveals raw error when expanded', (
    tester,
  ) async {
    final dao = _MockPendingSyncDao();
    final worker = _MockSyncWorker();

    await tester.pumpWidget(_app(dao: dao, worker: worker));
    await tester.pumpAndSettle();

    await tester.tap(find.text('诊断信息'));
    await tester.pumpAndSettle();

    expect(
      find.text('DioException [connectionError]: network unavailable'),
      findsOneWidget,
    );
  });

  testWidgets('retry all resets every failed item before flushing', (
    tester,
  ) async {
    final dao = _MockPendingSyncDao();
    final worker = _MockSyncWorker();

    when(() => dao.resetForRetry('pending-1')).thenAnswer((_) async {});
    when(() => dao.resetForRetry('pending-2')).thenAnswer((_) async {});
    when(() => worker.flush()).thenAnswer((_) async {});

    await tester.pumpWidget(
      _app(
        dao: dao,
        worker: worker,
        entries: (ref) async => [_entry(), _entry(id: 'pending-2')],
      ),
    );
    await tester.pumpAndSettle();

    // The primary action lives in the page footer, so it is reachable without
    // scrolling past the failure list.
    await tester.tap(find.byKey(const Key('sync-failures-retry-all')));
    await tester.pumpAndSettle();

    verify(() => dao.resetForRetry('pending-1')).called(1);
    verify(() => dao.resetForRetry('pending-2')).called(1);
    verify(() => worker.flush()).called(1);
  });

  testWidgets('surfaces an error when the retry cannot be started', (
    tester,
  ) async {
    final dao = _MockPendingSyncDao();
    final worker = _MockSyncWorker();

    when(
      () => dao.resetForRetry('pending-1'),
    ).thenThrow(StateError('database is closed'));

    await tester.pumpWidget(_app(dao: dao, worker: worker));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('sync-failures-retry-all')));
    await tester.pumpAndSettle();

    expect(find.text('无法开始重试，请稍后再试。'), findsOneWidget);
    verifyNever(() => worker.flush());
    // The entry stays on screen so the user can retry again.
    expect(find.text('daily_record'), findsOneWidget);
  });

  testWidgets('discard removes the entry only after the user confirms', (
    tester,
  ) async {
    final dao = _MockPendingSyncDao();
    final worker = _MockSyncWorker();

    when(() => dao.remove('pending-1')).thenAnswer((_) async {});

    await tester.pumpWidget(_app(dao: dao, worker: worker));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('sync-failed-entry-discard')));
    await tester.pumpAndSettle();

    // The destructive confirmation is mandatory: nothing is deleted yet.
    expect(find.text('丢弃这一项？'), findsOneWidget);
    verifyNever(() => dao.remove(any()));

    await tester.tap(find.text('丢弃').last);
    await tester.pumpAndSettle();

    verify(() => dao.remove('pending-1')).called(1);
    // Discarding must not trigger the retry flush — the entry is gone, and
    // re-sending it is exactly what the user chose not to do.
    verifyNever(() => worker.flush());
  });

  testWidgets('cancelling the discard confirmation keeps the entry', (
    tester,
  ) async {
    final dao = _MockPendingSyncDao();
    final worker = _MockSyncWorker();

    await tester.pumpWidget(_app(dao: dao, worker: worker));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('sync-failed-entry-discard')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();

    verifyNever(() => dao.remove(any()));
    expect(find.text('daily_record'), findsOneWidget);
  });

  testWidgets('surfaces an error when the discard cannot be persisted', (
    tester,
  ) async {
    final dao = _MockPendingSyncDao();
    final worker = _MockSyncWorker();

    when(
      () => dao.remove('pending-1'),
    ).thenThrow(StateError('database is closed'));

    await tester.pumpWidget(_app(dao: dao, worker: worker));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('sync-failed-entry-discard')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('丢弃').last);
    await tester.pumpAndSettle();

    expect(find.text('无法丢弃该项，请稍后再试。'), findsOneWidget);
  });
}
