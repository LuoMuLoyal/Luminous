import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/database/connection_providers.dart';
import 'package:luminous/core/database/daos/pending_sync_dao.dart';
import 'package:luminous/core/database/models/pending_sync_error_details.dart';
import 'package:luminous/core/database/sync/worker.dart';
import 'package:luminous/core/errors/error.dart';
import 'package:luminous/core/network/error_code.dart';
import 'package:luminous/features/mine/presentation/widgets/sections/sync_failed_banner.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_forui_app.dart';

class _MockPendingSyncDao extends Mock implements PendingSyncDao {}

class _MockSyncWorker extends Mock implements SyncWorker {}

void main() {
  PendingSyncEntry entry() => PendingSyncEntry(
    id: 'pending-1',
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
      kind: AppErrorKind.network,
      raw: 'DioException [connectionError]: network unavailable',
    ),
  );

  testWidgets('view details opens a dialog with the failed sync item', (
    tester,
  ) async {
    final dao = _MockPendingSyncDao();
    final worker = _MockSyncWorker();

    when(() => dao.fetchPermanentlyFailed()).thenAnswer((_) async => [entry()]);
    when(() => worker.flush()).thenAnswer((_) async {});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pendingSyncDaoProvider.overrideWithValue(dao),
          syncWorkerProvider.overrideWithValue(worker),
          syncFailedCountProvider.overrideWith((ref) async => 1),
        ],
        child: const TestForuiApp(home: MineSyncFailedBanner()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('查看详情'));
    await tester.pumpAndSettle();

    expect(find.byType(FDialog), findsOneWidget);
    expect(find.text('daily_record'), findsOneWidget);
    expect(find.text('record-1'), findsOneWidget);
    // User-facing message is shown; raw exception is hidden by default.
    expect(find.text('网络请求失败，请检查当前连接。'), findsOneWidget);
    expect(
      find.text('DioException [connectionError]: network unavailable'),
      findsNothing,
    );
  });

  testWidgets('diagnostics panel reveals raw error when expanded', (
    tester,
  ) async {
    final dao = _MockPendingSyncDao();
    final worker = _MockSyncWorker();

    when(() => dao.fetchPermanentlyFailed()).thenAnswer((_) async => [entry()]);
    when(() => worker.flush()).thenAnswer((_) async {});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pendingSyncDaoProvider.overrideWithValue(dao),
          syncWorkerProvider.overrideWithValue(worker),
          syncFailedCountProvider.overrideWith((ref) async => 1),
        ],
        child: const TestForuiApp(home: MineSyncFailedBanner()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('查看详情'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('诊断信息'));
    await tester.pumpAndSettle();

    expect(
      find.text('DioException [connectionError]: network unavailable'),
      findsOneWidget,
    );
  });

  testWidgets('retry all resets failed items before flushing', (tester) async {
    final dao = _MockPendingSyncDao();
    final worker = _MockSyncWorker();

    when(() => dao.fetchPermanentlyFailed()).thenAnswer((_) async => [entry()]);
    when(() => dao.resetForRetry('pending-1')).thenAnswer((_) async {});
    when(() => worker.flush()).thenAnswer((_) async {});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pendingSyncDaoProvider.overrideWithValue(dao),
          syncWorkerProvider.overrideWithValue(worker),
          syncFailedCountProvider.overrideWith((ref) async => 1),
        ],
        child: const TestForuiApp(home: MineSyncFailedBanner()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('查看详情'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('全部重试'));
    await tester.pumpAndSettle();

    verify(() => dao.resetForRetry('pending-1')).called(1);
    verify(() => worker.flush()).called(1);
    expect(find.byType(FDialog), findsNothing);
  });
}
