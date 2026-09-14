import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/core/utils/image_compressor.dart';
import 'package:luminous/features/record/data/providers/record_access.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/domain/services/sleep_entry.dart';
import 'package:luminous/features/record/presentation/utils/date_time_formatters.dart';
import 'package:luminous/features/record/presentation/utils/meal_analysis_payload_parser.dart';
import 'package:luminous/features/record/presentation/widgets/forms/form_fields.dart';
import 'package:luminous/features/record/presentation/widgets/forms/pending_image.dart';

/// Outcome of a save attempt, mapped to user-facing feedback by the page.
enum RecordEditSaveResult { saved, invalidSleep, failed }

/// Immutable form state for the record edit page.
///
/// Text fields (value/unit/title/note) live in page-level
/// [TextEditingController]s; this state tracks everything else plus the
/// initial text snapshot used for dirty detection.
@immutable
class RecordEditState {
  const RecordEditState({
    this.loading = false,
    this.loaded = false,
    this.loadFailed = false,
    this.kind = DailyRecordKind.water,
    this.initialValue = '',
    this.initialUnit = '',
    this.initialTitle = '',
    this.initialNote = '',
    this.existingImageAttachment,
    this.selectedImage,
    this.attachmentsChanged = false,
    this.occurredAt,
    this.occurredTime,
    this.bedtime,
    this.wakeTime,
    this.sleepKind = SleepEntryKind.nightSleep,
    this.sleepQuality,
    this.deepMinutes,
    this.lightMinutes,
    this.remMinutes,
    this.initialSleepDuration,
    this.dishNames = const [],
    this.canConfirmMealAnalysis = false,
    this.confirmMealAnalysis = false,
    this.saving = false,
    this.deleting = false,
  });

  /// Whether an initial load is in flight.
  final bool loading;

  /// Whether the record has been loaded successfully at least once.
  final bool loaded;

  /// Whether the initial load failed.
  final bool loadFailed;

  /// Record kind currently being edited.
  final DailyRecordKind kind;

  /// Loaded text snapshot used for dirty detection.
  final String initialValue;
  final String initialUnit;
  final String initialTitle;
  final String initialNote;

  final DailyRecordAttachment? existingImageAttachment;
  final PendingDailyRecordImage? selectedImage;
  final bool attachmentsChanged;

  final DateTime? occurredAt;
  final String? occurredTime;

  final TimeOfDay? bedtime;
  final TimeOfDay? wakeTime;
  final SleepEntryKind sleepKind;
  final String? sleepQuality;
  final int? deepMinutes;
  final int? lightMinutes;
  final int? remMinutes;

  final List<String> dishNames;
  final bool canConfirmMealAnalysis;
  final bool confirmMealAnalysis;

  /// Loaded sleep duration (minutes) used as a fallback when the current
  /// bedtime/wake-time fields cannot produce a duration.
  final int? initialSleepDuration;

  final bool saving;
  final bool deleting;

  RecordEditState copyWith({
    bool? loading,
    bool? loaded,
    bool? loadFailed,
    DailyRecordKind? kind,
    String? initialValue,
    String? initialUnit,
    String? initialTitle,
    String? initialNote,
    DailyRecordAttachment? existingImageAttachment,
    PendingDailyRecordImage? selectedImage,
    bool? attachmentsChanged,
    DateTime? occurredAt,
    String? occurredTime,
    TimeOfDay? bedtime,
    TimeOfDay? wakeTime,
    SleepEntryKind? sleepKind,
    String? sleepQuality,
    int? deepMinutes,
    int? lightMinutes,
    int? remMinutes,
    List<String>? dishNames,
    bool? canConfirmMealAnalysis,
    bool? confirmMealAnalysis,
    int? initialSleepDuration,
    bool? saving,
    bool? deleting,
  }) {
    return RecordEditState(
      loading: loading ?? this.loading,
      loaded: loaded ?? this.loaded,
      loadFailed: loadFailed ?? this.loadFailed,
      kind: kind ?? this.kind,
      initialValue: initialValue ?? this.initialValue,
      initialUnit: initialUnit ?? this.initialUnit,
      initialTitle: initialTitle ?? this.initialTitle,
      initialNote: initialNote ?? this.initialNote,
      existingImageAttachment:
          existingImageAttachment ?? this.existingImageAttachment,
      selectedImage: selectedImage ?? this.selectedImage,
      attachmentsChanged: attachmentsChanged ?? this.attachmentsChanged,
      occurredAt: occurredAt ?? this.occurredAt,
      occurredTime: occurredTime ?? this.occurredTime,
      bedtime: bedtime ?? this.bedtime,
      wakeTime: wakeTime ?? this.wakeTime,
      sleepKind: sleepKind ?? this.sleepKind,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      deepMinutes: deepMinutes ?? this.deepMinutes,
      lightMinutes: lightMinutes ?? this.lightMinutes,
      remMinutes: remMinutes ?? this.remMinutes,
      dishNames: dishNames ?? this.dishNames,
      canConfirmMealAnalysis:
          canConfirmMealAnalysis ?? this.canConfirmMealAnalysis,
      confirmMealAnalysis: confirmMealAnalysis ?? this.confirmMealAnalysis,
      initialSleepDuration: initialSleepDuration ?? this.initialSleepDuration,
      saving: saving ?? this.saving,
      deleting: deleting ?? this.deleting,
    );
  }
}

/// State + data operations for [RecordEditPage], extracted from the page to
/// keep the widget a thin form renderer.
class RecordEditController extends Notifier<RecordEditState> {
  @override
  RecordEditState build() => const RecordEditState();

  /// Immutable snapshot captured right after a successful load, used for
  /// dirty detection. Never mutated afterwards (states are immutable).
  RecordEditState? _loadedSnapshot;

  /// Whether the form differs from the loaded record.
  ///
  /// Text fields are passed in because they live in page-level controllers.
  bool isDirty({
    required String value,
    required String unit,
    required String title,
    required String note,
  }) {
    final snap = _loadedSnapshot;
    if (snap == null) return false;
    if (value != snap.initialValue) return true;
    if (unit != snap.initialUnit) return true;
    if (title != snap.initialTitle) return true;
    if (note != snap.initialNote) return true;
    if (state.kind != snap.kind) return true;
    if (state.occurredAt != snap.occurredAt) return true;
    if (state.occurredTime != snap.occurredTime) return true;
    if (!listEquals(state.dishNames, snap.dishNames)) return true;
    if (state.bedtime != snap.bedtime) return true;
    if (state.wakeTime != snap.wakeTime) return true;
    if (state.sleepQuality != snap.sleepQuality) return true;
    if (state.deepMinutes != snap.deepMinutes) return true;
    if (state.lightMinutes != snap.lightMinutes) return true;
    if (state.remMinutes != snap.remMinutes) return true;
    if (state.confirmMealAnalysis != snap.confirmMealAnalysis) return true;
    if (state.attachmentsChanged != snap.attachmentsChanged) return true;
    if (state.selectedImage != snap.selectedImage) return true;
    return false;
  }

  String defaultUnitTextForKind(DailyRecordKind kind) {
    return kind == DailyRecordKind.water ? dailyRecordWaterDefaultUnit : '';
  }

  Future<void> load(String recordId) async {
    if (state.loaded || state.loading) return;
    state = state.copyWith(loading: true);
    try {
      final repo = ref.read(dailyRecordRepositoryProvider);
      final result = await repo.get(recordId).run();
      final record = result.fold((failure) => throw failure, (item) => item);
      final mealAnalysis = parseMealAnalysisViewData(record.payload);
      final startAt = record.payload?['startedAt'] as String?;
      final endAt = record.payload?['endedAt'] as String?;
      final deep = record.payload?['deepMinutes'];
      final light = record.payload?['lightMinutes'];
      final rem = record.payload?['remMinutes'];

      state = RecordEditState(
        loading: false,
        loaded: true,
        kind: record.kind,
        initialValue: record.value ?? '',
        initialUnit: record.unit ?? defaultUnitTextForKind(record.kind),
        initialTitle: record.title ?? '',
        initialNote: record.note ?? '',
        existingImageAttachment: record.attachments
            .where((a) => a.kind == DailyRecordAttachmentKind.image)
            .firstOrNull,
        selectedImage: null,
        attachmentsChanged: false,
        occurredAt: parseRecordDate(record.occurredAt),
        occurredTime: record.occurredTime?.trim(),
        bedtime: _extractTimeOfDay(startAt),
        wakeTime: _extractTimeOfDay(endAt),
        sleepKind: SleepEntryKind.fromPayload(record.payload?['sleepType']),
        sleepQuality: record.payload?['quality'] as String?,
        deepMinutes: deep is num && deep > 0 ? deep.round() : null,
        lightMinutes: light is num && light > 0 ? light.round() : null,
        remMinutes: rem is num && rem > 0 ? rem.round() : null,
        initialSleepDuration: _positiveInt(record.payload?['durationMinutes']),
        dishNames: parseMealDishDraftNames(record.payload),
        canConfirmMealAnalysis:
            mealAnalysis != null &&
            (mealAnalysis.status == 'unconfirmed' ||
                mealAnalysis.status == 'confirmed'),
        confirmMealAnalysis: false,
      );
      _loadedSnapshot = state;
    } catch (e) {
      ref.read(talkerProvider).error('RecordEditController.load: failed: $e');
      state = state.copyWith(loading: false, loadFailed: true);
    }
  }

  void setKind(DailyRecordKind kind) {
    state = state.copyWith(
      kind: kind,
      bedtime: null,
      wakeTime: null,
      sleepQuality: null,
      deepMinutes: null,
      lightMinutes: null,
      remMinutes: null,
    );
  }

  void setOccurredAt(DateTime? date, {String? time}) {
    state = state.copyWith(occurredAt: date, occurredTime: time);
  }

  void setBedtime(TimeOfDay? value) => state = state.copyWith(bedtime: value);
  void setWakeTime(TimeOfDay? value) => state = state.copyWith(wakeTime: value);
  void setSleepKind(SleepEntryKind value) =>
      state = state.copyWith(sleepKind: value);
  void setSleepQuality(String? value) =>
      state = state.copyWith(sleepQuality: value);
  void setDeepMinutes(int? value) => state = state.copyWith(deepMinutes: value);
  void setLightMinutes(int? value) =>
      state = state.copyWith(lightMinutes: value);
  void setRemMinutes(int? value) => state = state.copyWith(remMinutes: value);

  void setDishName(int index, String value) {
    final next = [...state.dishNames];
    if (index >= 0 && index < next.length) {
      next[index] = value;
      state = state.copyWith(dishNames: next);
    }
  }

  void addDish() {
    state = state.copyWith(dishNames: [...state.dishNames, '']);
  }

  void removeDish(int index) {
    final next = [...state.dishNames]..removeAt(index);
    state = state.copyWith(dishNames: next);
  }

  void setConfirmMealAnalysis(bool value) =>
      state = state.copyWith(confirmMealAnalysis: value);

  void setSelectedImage(PendingDailyRecordImage? image) {
    state = state.copyWith(
      selectedImage: image,
      attachmentsChanged: image != null || state.attachmentsChanged,
    );
  }

  void removeImage() {
    state = state.copyWith(selectedImage: null, attachmentsChanged: true);
  }

  /// Picks, compresses and stages an image for upload.
  Future<void> pickImage() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        requestFullMetadata: false,
      );
      if (image == null) return;
      final contentType = resolveImageContentType(image);
      if (contentType == null) return;
      final rawBytes = await image.readAsBytes();
      final compressedBytes = await ImageCompressor.compressForUpload(rawBytes);
      setSelectedImage(
        PendingDailyRecordImage(
          bytes: compressedBytes,
          fileName: image.name,
          contentType: 'image/jpeg',
        ),
      );
    } catch (e) {
      ref
          .read(talkerProvider)
          .error('RecordEditController.pickImage: failed: $e');
    }
  }

  int? resolvedSleepDurationMinutes() {
    final computed = computeSleepDurationMinutes(state.bedtime, state.wakeTime);
    if (computed != null && computed > 0) return computed;
    return state.initialSleepDuration;
  }

  /// 当前睡眠草稿的校验错误；非睡眠类型或草稿合法时为 null。
  SleepEntryValidationError? sleepValidationError() {
    if (state.kind != DailyRecordKind.sleep) return null;

    // 设备导入的记录可能只有时长、没有时刻（`durationMinutes`）；这类记录仍要能
    // 只改备注后保存，因此两个时刻都为空且有可用时长时不报错。
    if (state.bedtime == null &&
        state.wakeTime == null &&
        (state.initialSleepDuration ?? 0) > 0) {
      return null;
    }

    return validateSleepEntry(
      bedtime: state.bedtime,
      wakeTime: state.wakeTime,
      kind: state.sleepKind,
    );
  }

  bool isValidSleepValue() =>
      state.kind != DailyRecordKind.sleep || sleepValidationError() == null;

  Future<RecordEditSaveResult> save(
    String recordId, {
    required String value,
    required String unit,
    required String title,
    required String note,
    required String? occurredTime,
  }) async {
    if (state.kind == DailyRecordKind.sleep && !isValidSleepValue()) {
      return RecordEditSaveResult.invalidSleep;
    }
    state = state.copyWith(saving: true);
    try {
      final repo = ref.read(dailyRecordRepositoryProvider);
      final attachmentPatch = await _buildAttachmentPatch();
      final rules = dailyRecordFormRules(state.kind);
      final trimmedValue = value.trim();
      final trimmedUnit = unit.trim();
      final trimmedTitle = title.trim();
      final trimmedNote = note.trim();
      final result = await repo
          .update(
            recordId,
            DailyRecordUpdateInput(
              kind: state.kind,
              occurredAt: formatRecordDate(state.occurredAt ?? clock.now()),
              occurredTime: occurredTime,
              title: rules.showTitle ? _optional(trimmedTitle) : null,
              value: state.kind == DailyRecordKind.sleep
                  ? null
                  : _optional(trimmedValue),
              unit: _resolvedUnit(trimmedUnit),
              note: _optional(trimmedNote),
              payload: _buildPayload(),
              attachments: attachmentPatch,
            ),
          )
          .run();
      result.fold((failure) => throw failure, (_) {});
      _invalidateData(recordId);
      return RecordEditSaveResult.saved;
    } catch (e) {
      ref.read(talkerProvider).error('RecordEditController.save: failed: $e');
      return RecordEditSaveResult.failed;
    } finally {
      if (state.saving) state = state.copyWith(saving: false);
    }
  }

  String? _resolvedUnit(String trimmedUnit) {
    if (trimmedUnit.isNotEmpty) return trimmedUnit;
    return state.kind == DailyRecordKind.water
        ? dailyRecordWaterDefaultUnit
        : null;
  }

  String? _optional(String value) => value.isEmpty ? null : value;

  void _invalidateData(String recordId) {
    ref.invalidate(dailyRecordDetailProvider(recordId));
    ref.read(dataChangeBusProvider.notifier).emit(DataChangeTopic.dailyRecords);
  }

  Future<Object> _buildAttachmentPatch() async {
    if (!state.attachmentsChanged) return dailyRecordNoChange;
    final image = state.selectedImage;
    if (image == null) return const <DailyRecordAttachmentInput>[];
    final repo = ref.read(dailyRecordRepositoryProvider);
    final result = await repo
        .uploadImage(
          DailyRecordImageUploadInput(
            bytes: image.bytes,
            contentType: image.contentType,
            sizeBytes: image.bytes.length,
            fileName: image.fileName,
          ),
        )
        .run();
    final attachment = result.fold(
      (failure) => throw failure,
      (attachment) => attachment,
    );
    return <DailyRecordAttachmentInput>[attachment];
  }

  Map<String, dynamic>? _buildPayload() {
    return switch (state.kind) {
      DailyRecordKind.sleep => _buildSleepPayload(),
      DailyRecordKind.meal => _buildMealPayload(),
      _ => null,
    };
  }

  Map<String, dynamic>? _buildSleepPayload() {
    final kind = state.sleepKind;
    final occurredAt = state.occurredAt ?? clock.now();
    final payload = buildSleepPayload(
      recordDate: occurredAt,
      bedtime: state.bedtime,
      wakeTime: state.wakeTime,
      kind: kind,
      quality: state.sleepQuality,
      deepMinutes: state.deepMinutes,
      lightMinutes: state.lightMinutes,
      remMinutes: state.remMinutes,
    );
    if (payload != null) return payload;

    // Records imported from a device may carry a duration without clock times;
    // keep that duration editable rather than dropping the payload entirely.
    final minutes = resolvedSleepDurationMinutes();
    if (minutes == null || minutes <= 0) return null;
    return <String, dynamic>{
      'durationMinutes': minutes,
      'sleepType': kind.wireValue,
      if (state.sleepQuality != null) 'quality': state.sleepQuality,
      if (state.deepMinutes != null && state.deepMinutes! > 0)
        'deepMinutes': state.deepMinutes,
      if (state.lightMinutes != null && state.lightMinutes! > 0)
        'lightMinutes': state.lightMinutes,
      if (state.remMinutes != null && state.remMinutes! > 0)
        'remMinutes': state.remMinutes,
    };
  }

  Map<String, dynamic>? _buildMealPayload() {
    final dishes = state.dishNames
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .map((item) => <String, dynamic>{'rawName': item})
        .toList(growable: false);
    final payload = <String, dynamic>{
      'mealInput': <String, dynamic>{'recognizedDishes': dishes},
    };
    if (state.confirmMealAnalysis) {
      payload['mealAnalysis'] = <String, dynamic>{
        'analysisStatus': 'confirmed',
      };
    }
    return payload;
  }
}

/// Extracts a [TimeOfDay] from an ISO-8601 timestamp string, or null when
/// the value is missing / unparseable.
TimeOfDay? _extractTimeOfDay(String? iso) {
  final dt = DateTime.tryParse(iso ?? '');
  if (dt == null) return null;
  final local = dt.toLocal();
  return TimeOfDay(hour: local.hour, minute: local.minute);
}

/// Returns [value] as a positive int, or null otherwise.
int? _positiveInt(Object? value) {
  if (value is! num || value <= 0) return null;
  return value.round();
}

final recordEditControllerProvider =
    NotifierProvider<RecordEditController, RecordEditState>(
      RecordEditController.new,
    );
