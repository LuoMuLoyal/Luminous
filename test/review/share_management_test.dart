import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/network/client_providers.dart';
import 'package:luminous/core/network/dio_client.dart';
import 'package:luminous/features/review/presentation/widgets/sheets/share_management.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_forui_app.dart';
import '../helpers/test_helpers.dart';

class _MockReportsApi extends Mock implements ReportsApi {}

class _FakeLucentClient extends LucentClient {
  _FakeLucentClient({required this.reportsApi}) : super(LucentApi(dio: Dio()));

  final ReportsApi reportsApi;

  @override
  ReportsApi get reports => reportsApi;
}

ClinicSummaryShareListItemDto _shareItem({
  String id = 'share-1',
  String? revokedAt,
  int accessCount = 3,
  String? lastAccessedAt = '2026-07-03T09:00:00',
}) {
  return ClinicSummaryShareListItemDto(
    id: id,
    createdAt: '2026-07-01T08:00:00',
    expiresAt: '2026-07-08T08:00:00',
    revokedAt: revokedAt,
    accessCount: accessCount,
    firstAccessedAt: lastAccessedAt,
    lastAccessedAt: lastAccessedAt,
    scope: ClinicSummaryShareScopeDto(
      eventId: null,
      dateFrom: '2026-06-02',
      dateTo: '2026-07-01',
    ),
    selectedFields: const ['event_overview', 'symptom_changes'],
  );
}

Response<ClinicSummaryShareListResponseDto> _shareListResponse(
  List<ClinicSummaryShareListItemDto> items,
) {
  return Response<ClinicSummaryShareListResponseDto>(
    data: ClinicSummaryShareListResponseDto(items: items),
    requestOptions: RequestOptions(path: '/shares'),
    statusCode: 200,
  );
}

void main() {
  late _MockReportsApi reportsApi;
  late _FakeLucentClient client;

  setUp(() {
    reportsApi = _MockReportsApi();
    client = _FakeLucentClient(reportsApi: reportsApi);
  });

  Future<void> pumpSheet(
    WidgetTester tester, {
    required List<ClinicSummaryShareListItemDto> items,
    Future<Response<ClinicSummaryShareListResponseDto>> Function()? listHandler,
  }) async {
    when(
      () => reportsApi.reportsControllerListClinicSummarySharesV1(),
    ).thenAnswer((_) async {
      return listHandler != null
          ? await listHandler()
          : _shareListResponse(items);
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
          lucentClientProvider.overrideWithValue(client),
        ],
        child: const TestForuiApp(
          locale: Locale('zh'),
          home: Scaffold(
            body: SingleChildScrollView(child: ShareManagementSheet()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  AppLocalizations l10n(WidgetTester tester) {
    return AppLocalizations.of(
      tester.element(find.byType(ShareManagementSheet)),
    )!;
  }

  testWidgets('renders created, expires, access count and last accessed', (
    tester,
  ) async {
    await pumpSheet(tester, items: [_shareItem()]);

    final l10n_ = l10n(tester);
    expect(find.text(l10n_.reviewShareManagementTitle), findsOneWidget);
    expect(find.text(l10n_.reviewShareCreatedAt), findsOneWidget);
    expect(find.text(l10n_.reviewShareExpiresAt), findsOneWidget);
    expect(find.text(l10n_.reviewShareAccessCountLabel), findsOneWidget);
    expect(find.text(l10n_.reviewShareAccessCount(3)), findsOneWidget);
    expect(find.text(l10n_.reviewShareLastAccessed), findsOneWidget);
    // 2026-07-03T09:00:00 (UTC+8 local formatting in the zh locale).
    expect(find.textContaining('2026/7/3'), findsOneWidget);
    // Active share: revoke action available, no revoked badge.
    expect(find.text(l10n_.reviewShareRevokeAction), findsOneWidget);
    expect(find.text(l10n_.reviewShareRevokedBadge), findsNothing);
  });

  testWidgets('shows "not accessed yet" when the share was never opened', (
    tester,
  ) async {
    await pumpSheet(tester, items: [_shareItem(lastAccessedAt: null)]);

    final l10n_ = l10n(tester);
    expect(find.text(l10n_.reviewShareLastAccessedNever), findsOneWidget);
  });

  testWidgets('shows the revoked state and hides the revoke action', (
    tester,
  ) async {
    await pumpSheet(
      tester,
      items: [_shareItem(revokedAt: '2026-07-05T10:00:00')],
    );

    final l10n_ = l10n(tester);
    expect(find.text(l10n_.reviewShareRevokedBadge), findsOneWidget);
    expect(find.textContaining('2026/7/5'), findsOneWidget);
    expect(find.text(l10n_.reviewShareRevokeAction), findsNothing);
  });

  testWidgets('renders the empty state when there are no shares', (
    tester,
  ) async {
    await pumpSheet(tester, items: []);

    final l10n_ = l10n(tester);
    expect(find.text(l10n_.reviewShareManagementEmpty), findsOneWidget);
    expect(find.text(l10n_.reviewShareManagementEmptyHint), findsOneWidget);
    expect(find.text(l10n_.reviewShareRevokeAction), findsNothing);
  });

  testWidgets('revoke calls DELETE with the share id and refreshes the list', (
    tester,
  ) async {
    when(
      () => reportsApi.reportsControllerRevokeClinicSummaryShareV1(
        shareId: 'share-1',
      ),
    ).thenAnswer(
      (_) async => Response<void>(
        requestOptions: RequestOptions(path: '/revoke'),
        statusCode: 200,
      ),
    );

    // First listing returns the active share; the refreshed listing returns
    // the same share already revoked (server-side revocation result).
    var revoked = false;
    await pumpSheet(
      tester,
      items: [_shareItem()],
      listHandler: () async {
        return _shareListResponse([
          _shareItem(revokedAt: revoked ? '2026-07-05T10:00:00' : null),
        ]);
      },
    );

    // Flip the server-side state before triggering the revoke + refresh.
    revoked = true;
    final l10n_ = l10n(tester);
    await tester.tap(find.text(l10n_.reviewShareRevokeAction));
    await tester.pumpAndSettle();

    verify(
      () => reportsApi.reportsControllerRevokeClinicSummaryShareV1(
        shareId: 'share-1',
      ),
    ).called(1);
    // invalidateSelf refetched the list after the revoke.
    verify(
      () => reportsApi.reportsControllerListClinicSummarySharesV1(),
    ).called(2);
    // The refreshed row shows the revoked state without a revoke action.
    expect(find.text(l10n_.reviewShareRevokedBadge), findsOneWidget);
    expect(find.text(l10n_.reviewShareRevokeAction), findsNothing);
  });

  testWidgets('never shows visitor identity', (tester) async {
    await pumpSheet(tester, items: [_shareItem()]);

    // The share list API carries no visitor identity; the sheet must not
    // invent or render any (no IPs, no names, no visitor labels).
    expect(find.textContaining(RegExp(r'\d{1,3}(\.\d{1,3}){3}')), findsNothing);
    expect(find.textContaining('访问者'), findsNothing);
    expect(find.textContaining('IP'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the load-failed state with retry', (tester) async {
    when(
      () => reportsApi.reportsControllerListClinicSummarySharesV1(),
    ).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/shares'),
        type: DioExceptionType.connectionError,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
          lucentClientProvider.overrideWithValue(client),
        ],
        child: const TestForuiApp(
          locale: Locale('zh'),
          home: Scaffold(
            body: SingleChildScrollView(child: ShareManagementSheet()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final l10n_ = l10n(tester);
    expect(find.text(l10n_.reviewShareManagementLoadFailed), findsOneWidget);
    expect(find.text(l10n_.todayRetryAction), findsOneWidget);

    // Retry re-fetches and succeeds.
    when(
      () => reportsApi.reportsControllerListClinicSummarySharesV1(),
    ).thenAnswer((_) async => _shareListResponse([_shareItem()]));
    await tester.tap(find.text(l10n_.todayRetryAction));
    await tester.pumpAndSettle();
    expect(find.text(l10n_.reviewShareManagementEmpty), findsNothing);
    expect(find.text(l10n_.reviewShareCreatedAt), findsOneWidget);
  });
}
