import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/features/record/data/providers/record_access.dart';
import 'package:luminous/features/record/domain/entities/candidates.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/domain/repositories/daily.dart';
import 'package:luminous/features/record/presentation/pages/create.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/test_helpers.dart';

class _FakeRepo extends DailyRecordRepository {
  @override
  TaskEither<LucentFailure, DailyRecordItem> get(String id) =>
      throw UnimplementedError();
  @override
  TaskEither<LucentFailure, DailyRecordListData> fetchRecords(
    String date, {
    String? kind,
    int page = 1,
    int pageSize = 50,
  }) => throw UnimplementedError();
  @override
  TaskEither<LucentFailure, DailyRecordSummaryData> fetchSummary(String date) =>
      throw UnimplementedError();
  @override
  TaskEither<LucentFailure, DailyRecordAttachmentInput> uploadImage(
    DailyRecordImageUploadInput input,
  ) => throw UnimplementedError();
  @override
  TaskEither<LucentFailure, DailyRecordCandidateResult> generateCandidates({
    required String text,
    required String occurredAt,
  }) => throw UnimplementedError();
  @override
  TaskEither<LucentFailure, DailyRecordItem> create(
    DailyRecordCreateInput input,
  ) => throw UnimplementedError();
  @override
  TaskEither<LucentFailure, DailyRecordItem> update(
    String id,
    DailyRecordUpdateInput input,
  ) => throw UnimplementedError();
  @override
  TaskEither<LucentFailure, void> delete(String id) => TaskEither.right(null);
}

void main() {
  testWidgets('RecordCreatePage renders when authenticated', (tester) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(() => SignedInAuthSessionNotifier()),
          dailyRecordRepositoryProvider.overrideWithValue(_FakeRepo()),
        ],
        child: TestAuthApp(
          router: GoRouter(
            initialLocation: '/',
            routes: [
              GoRoute(path: '/', builder: (_, __) => const RecordCreatePage()),
              GoRoute(
                path: '/home',
                builder: (_, __) => const Scaffold(body: Text('Home')),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(RecordCreatePage), findsOneWidget);
  });
}
