import 'package:flutter/material.dart';
import 'package:luminous/features/record/domain/constants/symptom_catalog.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// A single quick-entry option shown in the fast record dialog.
///
/// The quick-entry option lists (labels, default values, supported units) are
/// currently hardcoded per [DailyRecordKind]. When a remote-configuration or
/// local-config system becomes available, [recordFastEntryChoicesFor] should
/// read from it so that options can be adjusted without a full app release.
@immutable
class RecordFastChoice {
  const RecordFastChoice({
    required this.label,
    this.prefix,
    this.title,
    this.value,
    this.unit,
    this.note,
    this.payload,
  });

  final String label;
  final Widget? prefix;
  final String? title;
  final String? value;
  final String? unit;
  final String? note;
  final Map<String, dynamic>? payload;
}

/// 快速选项的稳定码（症状目前取 payload `symptom` 的目录码）。
///
/// 偏好里「启用了哪些症状」必须存码：以前存的是本地化标题，切换语言后
/// 目录文案变了，已存的标题匹配不上，弹窗会直接变空。
String? recordFastChoiceCode(RecordFastChoice choice) {
  final code = choice.payload?['symptom'];
  return code is String && code.isNotEmpty ? code : null;
}

/// 按偏好里的启用目录码筛出症状项；[enabledCodes] 为空表示全部启用。
List<RecordFastChoice> filterSymptomChoices(
  List<RecordFastChoice> choices, {
  required List<String> enabledCodes,
}) {
  if (enabledCodes.isEmpty) return choices;
  final enabled = enabledCodes.toSet();
  return choices
      .where((choice) => enabled.contains(recordFastChoiceCode(choice)))
      .toList(growable: false);
}

/// Returns the quick-entry choices for the given record [kind].
List<RecordFastChoice> recordFastEntryChoicesFor(
  DailyRecordKind kind,
  AppLocalizations l10n,
) {
  return switch (kind) {
    DailyRecordKind.water => [
      RecordFastChoice(
        label: l10n.recordFastChoiceWater250ml,
        value: '250',
        unit: l10n.recordWaterUnitMl,
      ),
      RecordFastChoice(
        label: l10n.recordFastChoiceWater500ml,
        value: '500',
        unit: l10n.recordWaterUnitMl,
      ),
      RecordFastChoice(
        label: l10n.recordFastChoiceWater1Cup,
        value: '1',
        unit: l10n.recordWaterUnitCup,
      ),
      RecordFastChoice(
        label: l10n.recordFastChoiceWater1Time,
        value: '1',
        unit: l10n.recordWaterUnitTimes,
      ),
    ],
    DailyRecordKind.symptom => [
      // 目录码进 payload（数据真相）；严重度由调用方按当前设置补进 payload，
      // 本地化文案只作展示。目录源在后端，这里是与后端同码同序的兜底清单。
      for (final entry in fallbackSymptomCatalog(l10n))
        RecordFastChoice(
          label: entry.label,
          title: entry.label,
          payload: <String, dynamic>{'symptom': entry.code},
        ),
    ],
    DailyRecordKind.note => [
      RecordFastChoice(
        label: l10n.recordFastChoiceNoteStable,
        title: l10n.recordFastChoiceNoteStable,
        note: l10n.recordFastChoiceNoteStable,
      ),
      RecordFastChoice(
        label: l10n.recordFastChoiceNoteTired,
        title: l10n.recordFastChoiceNoteTired,
        note: l10n.recordFastChoiceNoteTired,
      ),
      RecordFastChoice(
        label: l10n.recordFastChoiceNoteBusy,
        title: l10n.recordFastChoiceNoteBusy,
        note: l10n.recordFastChoiceNoteBusy,
      ),
      RecordFastChoice(
        label: l10n.recordFastChoiceNoteRecovered,
        title: l10n.recordFastChoiceNoteRecovered,
        note: l10n.recordFastChoiceNoteRecovered,
      ),
    ],
    DailyRecordKind.mood => [
      RecordFastChoice(
        label: l10n.recordFastChoiceMoodGreat,
        prefix: const Text('😄'),
        payload: <String, dynamic>{'moodLevel': 5, 'moodLabel': 'great'},
      ),
      RecordFastChoice(
        label: l10n.recordFastChoiceMoodGood,
        prefix: const Text('🙂'),
        payload: <String, dynamic>{'moodLevel': 4, 'moodLabel': 'good'},
      ),
      RecordFastChoice(
        label: l10n.recordFastChoiceMoodOkay,
        prefix: const Text('😐'),
        payload: <String, dynamic>{'moodLevel': 3, 'moodLabel': 'okay'},
      ),
      RecordFastChoice(
        label: l10n.recordFastChoiceMoodBad,
        prefix: const Text('😟'),
        payload: <String, dynamic>{'moodLevel': 2, 'moodLabel': 'bad'},
      ),
      RecordFastChoice(
        label: l10n.recordFastChoiceMoodTerrible,
        prefix: const Text('😫'),
        payload: <String, dynamic>{'moodLevel': 1, 'moodLabel': 'terrible'},
      ),
    ],
    // 餐食没有选项式快录：单击走相机 + 确认弹窗（`MealQuickConfirmationDialog`），
    // 长按走无照片手动录入，落库路径都不经过这里。
    _ => const [],
  };
}

/// 症状目录的本地兜底清单（与 Lucent `SYMPTOM_CATALOG_CODES` 同码同序）。
///
/// 后端目录（`symptomCatalogProvider`）拉取失败时用它渲染；目录项文案优先取本地
/// 文案（换语言即时生效），后端新增的未知码用后端给的 label。
List<SymptomCatalogEntry> fallbackSymptomCatalog(AppLocalizations l10n) => [
  for (final code in SymptomCode.values)
    SymptomCatalogEntry(code: code.wireValue, label: _symptomLabel(l10n, code)),
];

/// 客户端认识的目录码 → 本地文案；未知码返回 null（回落后端 label 或码本身）。
String? symptomCodeLabel(AppLocalizations l10n, String code) {
  final known = SymptomCode.fromWire(code);
  return known == null ? null : _symptomLabel(l10n, known);
}

String _symptomLabel(AppLocalizations l10n, SymptomCode code) {
  return switch (code) {
    SymptomCode.headache => l10n.recordFastChoiceSymptomHeadache,
    SymptomCode.stomachache => l10n.recordFastChoiceSymptomStomachache,
    SymptomCode.dizzy => l10n.recordFastChoiceSymptomDizzy,
    SymptomCode.fever => l10n.recordFastChoiceSymptomFever,
    SymptomCode.nausea => l10n.recordFastChoiceSymptomNausea,
    SymptomCode.cough => l10n.recordFastChoiceSymptomCough,
    SymptomCode.fatigue => l10n.recordFastChoiceSymptomFatigue,
    SymptomCode.insomnia => l10n.recordFastChoiceSymptomInsomnia,
    SymptomCode.other => l10n.recordFastChoiceSymptomOther,
  };
}

/// 后端目录 → 快速录入选项。
///
/// 顺序与成员资格以后端为准，文案优先取本地文案（换语言即时生效），后端新增的未知码
/// 用后端给的 label；后端目录为空（离线/拉取失败）时回落本地兜底清单。
List<RecordFastChoice> resolveSymptomChoices({
  required List<SymptomCatalogEntry> catalog,
  required AppLocalizations l10n,
}) {
  final entries = catalog.isEmpty ? fallbackSymptomCatalog(l10n) : catalog;
  return [
    for (final entry in entries)
      RecordFastChoice(
        label: symptomCodeLabel(l10n, entry.code) ?? entry.label,
        title: symptomCodeLabel(l10n, entry.code) ?? entry.label,
        payload: <String, dynamic>{'symptom': entry.code},
      ),
  ];
}
