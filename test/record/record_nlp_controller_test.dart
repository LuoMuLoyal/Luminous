import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/network/lucent_api_exception.dart';
import 'package:luminous/features/auth/domain/entities/auth_session.dart';
import 'package:luminous/features/auth/presentation/providers/session/auth_session_provider.dart';
import 'package:luminous/features/record/data/providers/daily_record_providers.dart';
import 'package:luminous/features/record/domain/entities/daily_record.dart';
import 'package:luminous/features/record/domain/entities/daily_record_candidates.dart';
import 'package:luminous/features/record/domain/entities/daily_record_inputs.dart';
import 'package:luminous/features/record/domain/repositories/daily_record_repository.dart';
import 'package:luminous/features/record/presentation/controllers/record_nlp_controller.dart';

void main() {
  test(
    'RecordNlpController saveSelected keeps failed selected items only',
    () async {
      final repo = _ControllerFakeDailyRecordRepository(
        generatedCandidates: DailyRecordCandidateResult(
          locale: 'zh-CN',
          generatedAt: '2026-06-14T00:00:00.000Z',
          confirmationHint: '确认后再保存。',
          items: const [
            DailyRecordCandidateItem(
              kind: DailyRecordKind.water,
              occurredAt: '2026-06-14',
              value: '500',
              unit: 'ml',
              rationale: '识别到饮水。',
            ),
            DailyRecordCandidateItem(
              kind: DailyRecordKind.note,
              occurredAt: '2026-06-14',
              title: '午后状态',
              note: '有点累',
              rationale: '识别到备注。',
            ),
          ],
        ),
        failCreateAtIndexes: {1},
      );

      final container = ProviderContainer(
        overrides: [
          dailyRecordRepositoryProvider.overrideWithValue(repo),
          authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(recordNlpControllerProvider.notifier);

      controller.updateDraft('喝了水，下午有点累');
      await controller.generate(occurredAt: '2026-06-14');
      final outcome = await controller.saveSelected();
      final state = container.read(recordNlpControllerProvider);

      expect(outcome.kind, RecordNlpSaveOutcomeKind.partial);
      expect(outcome.savedCount, 1);
      expect(outcome.failedCount, 1);
      expect(repo.createdInputs, hasLength(2));
      expect(state.candidates, hasLength(1));
      expect(state.candidates.single.kind, DailyRecordKind.note);
      expect(state.candidates.single.selected, isTrue);
      expect(state.candidates.single.lastErrorMessage, 'Create failed.');
    },
  );

  test('RecordNlpController retryFailed only retries failed items', () async {
    final repo = _ControllerFakeDailyRecordRepository(
      generatedCandidates: DailyRecordCandidateResult(
        locale: 'zh-CN',
        generatedAt: '2026-06-14T00:00:00.000Z',
        confirmationHint: '确认后再保存。',
        items: const [
          DailyRecordCandidateItem(
            kind: DailyRecordKind.water,
            occurredAt: '2026-06-14',
            value: '500',
            unit: 'ml',
            rationale: '识别到饮水。',
          ),
          DailyRecordCandidateItem(
            kind: DailyRecordKind.note,
            occurredAt: '2026-06-14',
            title: '午后状态',
            note: '有点累',
            rationale: '识别到备注。',
          ),
        ],
      ),
      failCreateAtIndexes: {1},
    );

    final container = ProviderContainer(
      overrides: [
        dailyRecordRepositoryProvider.overrideWithValue(repo),
        authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(recordNlpControllerProvider.notifier);

    controller.updateDraft('喝了水，下午有点累');
    await controller.generate(occurredAt: '2026-06-14');
    await controller.saveSelected();

    repo.failCreateAtIndexes.clear();

    final retryOutcome = await controller.retryFailed();
    final state = container.read(recordNlpControllerProvider);

    expect(retryOutcome.kind, RecordNlpSaveOutcomeKind.saved);
    expect(retryOutcome.savedCount, 1);
    expect(repo.createdInputs, hasLength(3));
    expect(repo.createdInputs.last.kind, DailyRecordKind.note);
    expect(state.candidates, isEmpty);
  });
}

class _ControllerFakeDailyRecordRepository implements DailyRecordRepository {
  _ControllerFakeDailyRecordRepository({
    required this.generatedCandidates,
    this.failCreateAtIndexes = const <int>{},
  });

  final DailyRecordCandidateResult generatedCandidates;
  final Set<int> failCreateAtIndexes;
  final List<DailyRecordCreateInput> createdInputs = <DailyRecordCreateInput>[];

  @override
  Future<DailyRecordCandidateResult> generateCandidates({
    required String text,
    required String occurredAt,
  }) async {
    return generatedCandidates;
  }

  @override
  Future<DailyRecordItem> create(DailyRecordCreateInput input) async {
    createdInputs.add(input);
    final index = createdInputs.length - 1;
    if (failCreateAtIndexes.contains(index)) {
      throw const LucentApiException(message: 'Create failed.');
    }
    return DailyRecordItem(
      id: 'created-$index',
      kind: input.kind,
      occurredAt: input.occurredAt,
      title: input.title,
      value: input.value,
      unit: input.unit,
      note: input.note,
      payload: input.payload,
      source: 'manual',
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
  }

  @override
  Future<void> delete(String id) {
    throw UnimplementedError();
  }

  @override
  Future<DailyRecordListData> fetchRecords(
    String date, {
    String? kind,
    int page = 1,
    int pageSize = 50,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<DailyRecordSummaryData> fetchSummary(String date) {
    throw UnimplementedError();
  }

  @override
  Future<DailyRecordItem> get(String id) {
    throw UnimplementedError();
  }

  @override
  Future<DailyRecordAttachmentInput> uploadImage(
    DailyRecordImageUploadInput input,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<DailyRecordItem> update(String id, DailyRecordUpdateInput input) {
    throw UnimplementedError();
  }
}

class _SignedInAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() {
    return AuthSessionState(
      isAuthenticated: true,
      isLoading: false,
      user: AuthUser(
        id: 'user-1',
        email: 'user@example.com',
        nickname: 'Lumi',
        avatar: null,
        emailVerifiedAt: DateTime.parse('2026-01-01T00:00:00Z'),
        createdAt: DateTime.parse('2026-01-01T00:00:00Z'),
        updatedAt: DateTime.parse('2026-01-02T00:00:00Z'),
      ),
    );
  }
}
