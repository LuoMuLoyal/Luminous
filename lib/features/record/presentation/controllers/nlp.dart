import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/network/contract/error_mapper.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/record/data/providers/record_access.dart';
import 'package:luminous/features/record/domain/entities/candidates.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/record.dart';

part 'nlp.freezed.dart';

class RecordNlpController extends Notifier<RecordNlpState> {
  @override
  RecordNlpState build() => RecordNlpState.idle();

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
      state = state.copyWith(status: RecordNlpStatus.error, errorMessage: null);
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
          .generateCandidates(text: text, occurredAt: occurredAt)
          .run();
      final nextState = result.fold(
        (failure) =>
            _onGenerateFailure(failure, previousCandidates, previousMetadata),
        (result) {
          state = state.copyWith(
            status: RecordNlpStatus.reviewing,
            resultMeta: RecordNlpResultMeta.fromResult(result),
            candidates: result.items
                .map(RecordNlpCandidateDraft.fromCandidate)
                .toList(growable: false),
            errorMessage: null,
          );
          return state;
        },
      );
      return nextState;
    } catch (error, st) {
      ref
          .read(talkerProvider)
          .error('RecordNlpController.generate: failed: $error', st);
      return _onGenerateFailure(
        LucentErrorMapper.fromObject(error),
        previousCandidates,
        previousMetadata,
      );
    }
  }

  /// Projects a generate failure into the controller state: with previous
  /// candidates the flow returns to reviewing; only with nothing to fall back
  /// to does it enter the error state.
  RecordNlpState _onGenerateFailure(
    LucentFailure failure,
    List<RecordNlpCandidateDraft> previousCandidates,
    RecordNlpResultMeta? previousMetadata,
  ) {
    final hasPreviousCandidates = previousCandidates.isNotEmpty;
    state = state.copyWith(
      // 保留旧候选时回到 reviewing；只有无候选可回退时才进入 error。
      status: hasPreviousCandidates
          ? RecordNlpStatus.reviewing
          : RecordNlpStatus.error,
      resultMeta: previousMetadata,
      candidates: previousCandidates,
      // errorMessage 仅伴随 error 状态展示，避免"审查中 + 错误横幅"并存。
      errorMessage: hasPreviousCandidates ? null : failure.message,
    );
    return state;
  }

  Future<RecordNlpSaveOutcome> saveSelected() async {
    return _saveCandidates((candidate) => candidate.selected);
  }

  Future<RecordNlpSaveOutcome> retryFailed() async {
    return _saveCandidates((candidate) => candidate.hasFailedSave);
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

    // Save all selected candidates in parallel to reduce user wait time.
    final results = await Future.wait(
      targetIndexes.map((index) async {
        final item = currentCandidates[index];
        try {
          final result = await repo.create(item.toCreateInput()).run();
          return result.fold((failure) {
            ref
                .read(talkerProvider)
                .error(
                  'RecordNlpController._saveCandidates: failed: '
                  '$failure',
                );
            return (index: index, success: false, error: failure.message);
          }, (_) => (index: index, success: true, error: null as String?));
        } catch (error) {
          ref
              .read(talkerProvider)
              .error('RecordNlpController._saveCandidates: failed: $error');
          final apiError = LucentErrorMapper.fromObject(error);
          return (index: index, success: false, error: apiError.message);
        }
      }),
    );

    var savedCount = 0;
    final errorMessages = <String>{};
    final failedItemsByIndex = <int, RecordNlpCandidateDraft>{};

    for (final result in results) {
      if (result.success) {
        savedCount += 1;
      } else {
        final item = currentCandidates[result.index];
        if (result.error != null && result.error!.isNotEmpty) {
          errorMessages.add(result.error!);
        }
        failedItemsByIndex[result.index] = item.copyWith(
          selected: true,
          lastErrorMessage: result.error,
        );
      }
    }

    if (savedCount > 0) {
      ref
          .read(dataChangeBusProvider.notifier)
          .emit(DataChangeTopic.dailyRecords);
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
      return RecordNlpSaveOutcome.saved(savedCount: savedCount, failedCount: 0);
    }

    state = state.copyWith(
      status: RecordNlpStatus.reviewing,
      candidates: remainingItems,
      errorMessage: null,
    );
    return RecordNlpSaveOutcome.partial(
      savedCount: savedCount,
      failedCount: failedItems.length,
      // 汇总所有失败原因（去重），而不是只暴露最后一个。
      message: errorMessages.isEmpty
          ? 'Unexpected error.'
          : errorMessages.join('\n'),
    );
  }

  void reset() {
    state = RecordNlpState.idle();
  }
}

final recordNlpControllerProvider =
    NotifierProvider<RecordNlpController, RecordNlpState>(
      RecordNlpController.new,
    );

enum RecordNlpStatus { idle, generating, reviewing, saving, saved, error }

@freezed
abstract class RecordNlpState with _$RecordNlpState {
  const RecordNlpState._();

  const factory RecordNlpState({
    @Default(RecordNlpStatus.idle) RecordNlpStatus status,
    @Default('') String draft,
    @Default([]) List<RecordNlpCandidateDraft> candidates,
    RecordNlpResultMeta? resultMeta,
    String? errorMessage,
  }) = _RecordNlpState;

  factory RecordNlpState.idle() => const RecordNlpState();

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

@freezed
abstract class RecordNlpCandidateDraft with _$RecordNlpCandidateDraft {
  const RecordNlpCandidateDraft._();

  const factory RecordNlpCandidateDraft({
    required DailyRecordKind kind,
    required String occurredAt,
    String? title,
    String? value,
    String? unit,
    String? note,
    Map<String, dynamic>? payload,
    required String rationale,
    @Default(true) bool selected,
    String? lastErrorMessage,
  }) = _RecordNlpCandidateDraft;

  factory RecordNlpCandidateDraft.fromCandidate(DailyRecordCandidateItem item) {
    return RecordNlpCandidateDraft(
      kind: item.kind,
      occurredAt: item.occurredAt,
      title: item.title,
      value: item.value,
      unit: item.unit,
      note: item.note,
      payload: item.payload == null
          ? null
          : Map<String, dynamic>.from(item.payload!),
      rationale: item.rationale,
      selected: true,
    );
  }

  bool get hasFailedSave => lastErrorMessage?.trim().isNotEmpty ?? false;

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
