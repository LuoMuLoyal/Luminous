import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/database/connection_providers.dart';
import 'package:luminous/core/database/daos/pending_sync.dart';
import 'package:luminous/core/database/sync/worker.dart';
import 'package:luminous/features/mine/presentation/pages/sync_failures.dart';
import 'package:luminous/features/mine/presentation/widgets/sections/sync_failed_banner.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_forui_app.dart';

class _MockPendingSyncDao extends Mock implements PendingSyncDao {}

class _MockSyncWorker extends Mock implements SyncWorker {}

PendingSyncEntry _entry() => PendingSyncEntry(
  id: 'pending-1',
  entityType: 'daily_record',
  entityId: 'record-1',
  operation: 'update',
  payload: '{}',
  createdAt: DateTime(2026, 8, 2, 12, 0),
  retryCount: 5,
  maxRetry: 5,
  lastError: 'DioException [connectionError]: network unavailable',
);

GoRouter _router() => GoRouter(
  initialLocation: '/mine',
  routes: [
    GoRoute(path: '/mine', builder: (_, _) => const MineSyncFailedBanner()),
    GoRoute(
      path: '/mine/sync/failures',
      builder: (_, _) => const SyncFailuresPage(),
    ),
  ],
);

Widget _app({
  required PendingSyncDao dao,
  required SyncWorker worker,
  required int failedCount,
}) {
  return ProviderScope(
    overrides: [
      pendingSyncDaoProvider.overrideWithValue(dao),
      syncWorkerProvider.overrideWithValue(worker),
      syncFailedCountProvider.overrideWith((ref) async => failedCount),
    ],
    child: TestForuiRouterApp(routerConfig: _router()),
  );
}

void main() {
  testWidgets('hides the banner when there are no failed items', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        dao: _MockPendingSyncDao(),
        worker: _MockSyncWorker(),
        failedCount: 0,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('查看详情'), findsNothing);
  });

  testWidgets('view details opens the sync failures page', (tester) async {
    final dao = _MockPendingSyncDao();
    final worker = _MockSyncWorker();

    when(
      () => dao.fetchPermanentlyFailed(),
    ).thenAnswer((_) async => [_entry()]);
    when(() => worker.flush()).thenAnswer((_) async {});

    await tester.pumpWidget(_app(dao: dao, worker: worker, failedCount: 1));
    await tester.pumpAndSettle();

    await tester.tap(find.text('查看详情'));
    await tester.pumpAndSettle();

    expect(find.byType(SyncFailuresPage), findsOneWidget);
    expect(find.text('daily_record'), findsOneWidget);
    expect(find.text('record-1'), findsOneWidget);
  });
}
