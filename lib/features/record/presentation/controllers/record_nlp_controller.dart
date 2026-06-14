import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/network/lucent_error_mapper.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/record/data/providers/daily_record_providers.dart';
import 'package:luminous/features/record/domain/entities/daily_record_candidates.dart';
import 'package:luminous/features/record/domain/entities/daily_record_inputs.dart';
import 'package:luminous/features/record/presentation/providers/record_dashboard_provider.dart';
import 'package:luminous/features/report/presentation/providers/report_dashboard_provider.dart';
import 'package:luminous/features/today/presentation/providers/today_dashboard_provider.dart';

class RecordNlpController extends Notifier<RecordNlpState> {
  @override
  RecordNlpState build() => const RecordNlpState.idle();

  void updateDraft(String value) {
    state = state.copyWith(draft: value, errorMessage: null);
  }

  void removeCandidateAt(int index) {
    final result = state.result;
    if (result == null) return;
    if (index < 0 || index >= result.items.length) return;

    final nextItems = [...result.items]..removeAt(index);
    state = state.copyWith(
      status: RecordNlpStatus.reviewing,
      result: result.copyWith(items: nextItems),
      errorMessage: null,
    );
  }

  Future<RecordNlpState> generate({required String occurredAt}) async {
    final session = ref.read(authSessionProvider);
    if (!session.canAccessProtectedData) {
      return state;
    }

    final text = state.draft.trim();
    if (text.isEmpty) {
      state = state.copyWith(
        status: RecordNlpStatus.error,
        errorMessage: null,
      );
      return state;
    }

    final previousResult = state.result;
    state = state.copyWith(
      status: RecordNlpStatus.generating,
      errorMessage: null,
    );

    try {
      final result = await ref
          .read(dailyRecordRepositoryProvider)
          .generateCandidates(text: text, occurredAt: occurredAt);
      state = state.copyWith(
        status: RecordNlpStatus.reviewing,
        result: result,
        errorMessage: null,
      );
      return state;
    } catch (error) {
      final apiError = LucentErrorMapper.fromObject(error);
      state = state.copyWith(
        status: previousResult == null
            ? RecordNlpStatus.error
            : RecordNlpStatus.reviewing,
        result: previousResult,
        errorMessage: apiError.message,
      );
      return state;
    }
  }

  Future<RecordNlpSaveOutcome> saveAll() async {
    final session = ref.read(authSessionProvider);
    if (!session.canAccessProtectedData) {
      return const RecordNlpSaveOutcome.authRequired();
    }

    final result = state.result;
    if (result == null || result.items.isEmpty) {
      return const RecordNlpSaveOutcome.empty();
    }

    state = state.copyWith(status: RecordNlpStatus.saving, errorMessage: null);
    try {
      final repo = ref.read(dailyRecordRepositoryProvider);
      for (final item in result.items) {
        await repo.create(
          DailyRecordCreateInput(
            kind: item.kind,
            occurredAt: item.occurredAt,
            title: item.title,
            value: item.value,
            unit: item.unit,
            note: item.note,
            payload: item.payload,
          ),
        );
      }

      ref.invalidate(recordDashboardProvider);
      ref.invalidate(todayDashboardProvider);
      ref.invalidate(reportDashboardProvider);

      state = state.copyWith(
        status: RecordNlpStatus.saved,
        errorMessage: null,
      );
      return RecordNlpSaveOutcome.saved(count: result.items.length);
    } catch (error) {
      final apiError = LucentErrorMapper.fromObject(error);
      state = state.copyWith(
        status: RecordNlpStatus.reviewing,
        errorMessage: apiError.message,
      );
      return RecordNlpSaveOutcome.error(message: apiError.message);
    }
  }

  void reset() {
    state = const RecordNlpState.idle();
  }
}

final recordNlpControllerProvider =
    NotifierProvider<RecordNlpController, RecordNlpState>(
      RecordNlpController.new,
    );

enum RecordNlpStatus { idle, generating, reviewing, saving, saved, error }

class RecordNlpState {
  const RecordNlpState({
    required this.status,
    required this.draft,
    this.result,
    this.errorMessage,
  });

  const RecordNlpState.idle() : this(status: RecordNlpStatus.idle, draft: '');

  final RecordNlpStatus status;
  final String draft;
  final DailyRecordCandidateResult? result;
  final String? errorMessage;

  bool get isGenerating => status == RecordNlpStatus.generating;
  bool get isSaving => status == RecordNlpStatus.saving;
  bool get hasResult => result != null;

  RecordNlpState copyWith({
    RecordNlpStatus? status,
    String? draft,
    DailyRecordCandidateResult? result,
    Object? errorMessage = _recordNlpNoChange,
  }) {
    return RecordNlpState(
      status: status ?? this.status,
      draft: draft ?? this.draft,
      result: result ?? this.result,
      errorMessage: identical(errorMessage, _recordNlpNoChange)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

class RecordNlpSaveOutcome {
  const RecordNlpSaveOutcome._({
    required this.kind,
    this.count,
    this.message,
  });

  const RecordNlpSaveOutcome.saved({required int count})
    : this._(kind: RecordNlpSaveOutcomeKind.saved, count: count);

  const RecordNlpSaveOutcome.empty()
    : this._(kind: RecordNlpSaveOutcomeKind.empty);

  const RecordNlpSaveOutcome.authRequired()
    : this._(kind: RecordNlpSaveOutcomeKind.authRequired);

  const RecordNlpSaveOutcome.error({required String message})
    : this._(kind: RecordNlpSaveOutcomeKind.error, message: message);

  final RecordNlpSaveOutcomeKind kind;
  final int? count;
  final String? message;
}

enum RecordNlpSaveOutcomeKind { saved, empty, authRequired, error }

const _recordNlpNoChange = Object();
