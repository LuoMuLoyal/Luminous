import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/network/lucent_error_mapper.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/record/data/providers/daily_record_providers.dart';
import 'package:luminous/features/record/domain/entities/daily_record.dart';
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
    final drafts = state.candidates;
    if (index < 0 || index >= drafts.length) return;

    final nextDrafts = [...drafts]..removeAt(index);
    state = state.copyWith(
      status: RecordNlpStatus.reviewing,
      candidates: nextDrafts,
      errorMessage: null,
    );
  }

  void toggleCandidateSelected(int index, bool selected) {
    final drafts = state.candidates;
    if (index < 0 || index >= drafts.length) return;

    final nextDrafts = [...drafts];
    nextDrafts[index] = nextDrafts[index].copyWith(selected: selected);
    state = state.copyWith(
      status: RecordNlpStatus.reviewing,
      candidates: nextDrafts,
      errorMessage: null,
    );
  }

  void updateCandidateAt(int index, RecordNlpCandidateDraft candidate) {
    final drafts = state.candidates;
    if (index < 0 || index >= drafts.length) return;

    final nextDrafts = [...drafts];
    nextDrafts[index] = candidate;
    state = state.copyWith(
      status: RecordNlpStatus.reviewing,
      candidates: nextDrafts,
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

    final previousCandidates = state.candidates;
    final previousMetadata = state.resultMeta;
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
        resultMeta: RecordNlpResultMeta.fromResult(result),
        candidates: result.items
            .map(RecordNlpCandidateDraft.fromCandidate)
            .toList(growable: false),
        errorMessage: null,
      );
      return state;
    } catch (error) {
      final apiError = LucentErrorMapper.fromObject(error);
      state = state.copyWith(
        status: previousCandidates.isEmpty
            ? RecordNlpStatus.error
            : RecordNlpStatus.reviewing,
        resultMeta: previousMetadata,
        candidates: previousCandidates,
        errorMessage: apiError.message,
      );
      return state;
    }
  }

  Future<RecordNlpSaveOutcome> saveSelected() async {
    return _saveCandidates(
      (candidate) => candidate.selected,
    );
  }

  Future<RecordNlpSaveOutcome> retryFailed() async {
    return _saveCandidates(
      (candidate) => candidate.hasFailedSave,
    );
  }

  Future<RecordNlpSaveOutcome> _saveCandidates(
    bool Function(RecordNlpCandidateDraft candidate) shouldSave,
  ) async {
    final session = ref.read(authSessionProvider);
    if (!session.canAccessProtectedData) {
      return const RecordNlpSaveOutcome.authRequired();
    }

    final currentCandidates = state.candidates;
    final targetIndexes = <int>[
      for (var index = 0; index < currentCandidates.length; index += 1)
        if (shouldSave(currentCandidates[index])) index,
    ];
    if (targetIndexes.isEmpty) {
      return const RecordNlpSaveOutcome.empty();
    }

    final repo = ref.read(dailyRecordRepositoryProvider);
    final targetIndexSet = targetIndexes.toSet();
    state = state.copyWith(status: RecordNlpStatus.saving, errorMessage: null);

    final failedItemsByIndex = <int, RecordNlpCandidateDraft>{};
    var savedCount = 0;
    String? lastErrorMessage;

    for (final index in targetIndexes) {
      final item = currentCandidates[index];
      try {
        await repo.create(item.toCreateInput());
        savedCount += 1;
      } catch (error) {
        final apiError = LucentErrorMapper.fromObject(error);
        lastErrorMessage = apiError.message;
        failedItemsByIndex[index] = item.copyWith(
          selected: true,
          lastErrorMessage: apiError.message,
        );
      }
    }

    if (savedCount > 0) {
      ref.invalidate(recordDashboardProvider);
      ref.invalidate(todayDashboardProvider);
      ref.invalidate(reportDashboardProvider);
    }

    final failedItems = [
      for (final index in targetIndexes)
        if (failedItemsByIndex.containsKey(index)) failedItemsByIndex[index]!,
    ];
    final unselectedItems = <RecordNlpCandidateDraft>[
      for (var index = 0; index < currentCandidates.length; index += 1)
        if (!targetIndexSet.contains(index))
          currentCandidates[index].copyWith(lastErrorMessage: null),
    ];
    final remainingItems = [...failedItems, ...unselectedItems];

    if (failedItems.isEmpty) {
      state = state.copyWith(
        status: RecordNlpStatus.saved,
        candidates: remainingItems,
        errorMessage: null,
      );
      return RecordNlpSaveOutcome.saved(
        savedCount: savedCount,
        failedCount: 0,
      );
    }

    state = state.copyWith(
      status: RecordNlpStatus.reviewing,
      candidates: remainingItems,
      errorMessage: null,
    );
    return RecordNlpSaveOutcome.partial(
      savedCount: savedCount,
      failedCount: failedItems.length,
      message: lastErrorMessage ?? 'Unexpected error.',
    );
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
    required this.candidates,
    this.resultMeta,
    this.errorMessage,
  });

  const RecordNlpState.idle()
    : this(
        status: RecordNlpStatus.idle,
        draft: '',
        candidates: const <RecordNlpCandidateDraft>[],
      );

  final RecordNlpStatus status;
  final String draft;
  final List<RecordNlpCandidateDraft> candidates;
  final RecordNlpResultMeta? resultMeta;
  final String? errorMessage;

  bool get isGenerating => status == RecordNlpStatus.generating;
  bool get isSaving => status == RecordNlpStatus.saving;
  bool get hasResult => resultMeta != null;
  List<RecordNlpCandidateDraft> get selectedCandidates => candidates
      .where((candidate) => candidate.selected)
      .toList(growable: false);
  List<RecordNlpCandidateDraft> get failedCandidates => candidates
      .where((candidate) => candidate.hasFailedSave)
      .toList(growable: false);
  int get selectedCount => selectedCandidates.length;
  int get failedCount => failedCandidates.length;
  bool get hasFailedCandidates => failedCount > 0;

  RecordNlpState copyWith({
    RecordNlpStatus? status,
    String? draft,
    List<RecordNlpCandidateDraft>? candidates,
    Object? resultMeta = _recordNlpNoChange,
    Object? errorMessage = _recordNlpNoChange,
  }) {
    return RecordNlpState(
      status: status ?? this.status,
      draft: draft ?? this.draft,
      candidates: candidates ?? this.candidates,
      resultMeta: identical(resultMeta, _recordNlpNoChange)
          ? this.resultMeta
          : resultMeta as RecordNlpResultMeta?,
      errorMessage: identical(errorMessage, _recordNlpNoChange)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

class RecordNlpResultMeta {
  const RecordNlpResultMeta({
    required this.locale,
    required this.generatedAt,
    required this.confirmationHint,
  });

  factory RecordNlpResultMeta.fromResult(DailyRecordCandidateResult result) {
    return RecordNlpResultMeta(
      locale: result.locale,
      generatedAt: result.generatedAt,
      confirmationHint: result.confirmationHint,
    );
  }

  final String locale;
  final String generatedAt;
  final String confirmationHint;
}

class RecordNlpCandidateDraft {
  const RecordNlpCandidateDraft({
    required this.kind,
    required this.occurredAt,
    this.title,
    this.value,
    this.unit,
    this.note,
    this.payload,
    required this.rationale,
    required this.selected,
    this.lastErrorMessage,
  });

  factory RecordNlpCandidateDraft.fromCandidate(DailyRecordCandidateItem item) {
    return RecordNlpCandidateDraft(
      kind: item.kind,
      occurredAt: item.occurredAt,
      title: item.title,
      value: item.value,
      unit: item.unit,
      note: item.note,
      payload: item.payload == null ? null : Map<String, dynamic>.from(item.payload!),
      rationale: item.rationale,
      selected: true,
    );
  }

  final DailyRecordKind kind;
  final String occurredAt;
  final String? title;
  final String? value;
  final String? unit;
  final String? note;
  final Map<String, dynamic>? payload;
  final String rationale;
  final bool selected;
  final String? lastErrorMessage;

  bool get hasFailedSave => lastErrorMessage?.trim().isNotEmpty ?? false;

  RecordNlpCandidateDraft copyWith({
    DailyRecordKind? kind,
    String? occurredAt,
    Object? title = _recordNlpNoChange,
    Object? value = _recordNlpNoChange,
    Object? unit = _recordNlpNoChange,
    Object? note = _recordNlpNoChange,
    Object? payload = _recordNlpNoChange,
    String? rationale,
    bool? selected,
    Object? lastErrorMessage = _recordNlpNoChange,
  }) {
    return RecordNlpCandidateDraft(
      kind: kind ?? this.kind,
      occurredAt: occurredAt ?? this.occurredAt,
      title: identical(title, _recordNlpNoChange)
          ? this.title
          : title as String?,
      value: identical(value, _recordNlpNoChange)
          ? this.value
          : value as String?,
      unit: identical(unit, _recordNlpNoChange)
          ? this.unit
          : unit as String?,
      note: identical(note, _recordNlpNoChange)
          ? this.note
          : note as String?,
      payload: identical(payload, _recordNlpNoChange)
          ? this.payload
          : payload as Map<String, dynamic>?,
      rationale: rationale ?? this.rationale,
      selected: selected ?? this.selected,
      lastErrorMessage: identical(lastErrorMessage, _recordNlpNoChange)
          ? this.lastErrorMessage
          : lastErrorMessage as String?,
    );
  }

  DailyRecordCreateInput toCreateInput() {
    return DailyRecordCreateInput(
      kind: kind,
      occurredAt: occurredAt,
      title: _normalizeText(title),
      value: _normalizeValue(kind, value),
      unit: _normalizeUnit(kind, unit),
      note: _normalizeText(note),
      payload: _normalizePayload(kind, payload),
    );
  }

  static String? _normalizeText(String? text) {
    final normalized = text?.trim();
    if (normalized == null || normalized.isEmpty) return null;
    return normalized;
  }

  static String? _normalizeValue(DailyRecordKind kind, String? value) {
    if (kind == DailyRecordKind.sleep) return null;
    return _normalizeText(value);
  }

  static String? _normalizeUnit(DailyRecordKind kind, String? unit) {
    final normalized = _normalizeText(unit);
    if (normalized != null) return normalized;
    if (kind == DailyRecordKind.water) return 'ml';
    return null;
  }

  static Map<String, dynamic>? _normalizePayload(
    DailyRecordKind kind,
    Map<String, dynamic>? payload,
  ) {
    if (kind != DailyRecordKind.sleep || payload == null) return payload;
    return Map<String, dynamic>.from(payload);
  }
}

class RecordNlpSaveOutcome {
  const RecordNlpSaveOutcome._({
    required this.kind,
    this.savedCount,
    this.failedCount,
    this.message,
  });

  const RecordNlpSaveOutcome.saved({
    required int savedCount,
    required int failedCount,
  }) : this._(
         kind: RecordNlpSaveOutcomeKind.saved,
         savedCount: savedCount,
         failedCount: failedCount,
       );

  const RecordNlpSaveOutcome.partial({
    required int savedCount,
    required int failedCount,
    required String message,
  }) : this._(
         kind: RecordNlpSaveOutcomeKind.partial,
         savedCount: savedCount,
         failedCount: failedCount,
         message: message,
       );

  const RecordNlpSaveOutcome.empty()
    : this._(kind: RecordNlpSaveOutcomeKind.empty);

  const RecordNlpSaveOutcome.authRequired()
    : this._(kind: RecordNlpSaveOutcomeKind.authRequired);

  const RecordNlpSaveOutcome.error({required String message})
    : this._(kind: RecordNlpSaveOutcomeKind.error, message: message);

  final RecordNlpSaveOutcomeKind kind;
  final int? savedCount;
  final int? failedCount;
  final String? message;
}

enum RecordNlpSaveOutcomeKind { saved, partial, empty, authRequired, error }

const _recordNlpNoChange = Object();
