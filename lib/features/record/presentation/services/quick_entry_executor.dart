import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/features/record/application/usecases/quick_entry_undo.dart';
import 'package:luminous/features/record/application/usecases/water_quick_entry.dart';
import 'package:luminous/features/record/data/datasources/quick_entry_preferences.dart';
import 'package:luminous/features/record/domain/constants/fast_entry_choices.dart';
import 'package:luminous/features/record/domain/constants/symptom_catalog.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/domain/entities/type_mapping.dart';
import 'package:luminous/features/record/presentation/quick_entry/symptom_flow.dart';
import 'package:luminous/features/record/presentation/services/quick_entry_context.dart';
import 'package:luminous/features/record/presentation/widgets/dialogs/fast_entry_dialog.dart';
import 'package:luminous/features/record/presentation/widgets/dialogs/symptom_quick_entry_sheet.dart';
import 'package:luminous/features/record/presentation/widgets/dialogs/water_quick_entry_sheet.dart';
import 'package:luminous/features/record/presentation/widgets/shared/copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

class QuickEntryExecutor {
  const QuickEntryExecutor({
    required this.createRecord,
    required this.deleteDailyRecord,
    required this.emitDataChange,
    required this.preferences,
    required this.loadSymptomCatalog,
  });

  final CreateDailyRecord createRecord;
  final DeleteDailyRecord deleteDailyRecord;
  final EmitDataChange emitDataChange;
  final QuickEntryPreferences preferences;

  /// 读取当前已缓存的后端症状目录；为空时调用方回落本地兜底清单。
  final List<SymptomCatalogEntry> Function() loadSymptomCatalog;

  Future<void> execute(QuickEntryExecutionContext context) async {
    final buildContext = context.buildContext;
    if (!context.canAccessProtectedData) {
      if (context.isAuthLoading) return;
      await showAuthRequiredDialog(
        buildContext,
        onLogin: () =>
            buildContext.push(loginRouteForCurrentLocation(buildContext)),
      );
      return;
    }

    final kind = dailyRecordKindForEntryType(context.action.type);
    final route = _createRoute(context, kind);

    if (kind == DailyRecordKind.water) {
      await _recordWater(context);
      return;
    }

    if (kind == DailyRecordKind.symptom) {
      await _recordSymptom(context, route);
      return;
    }

    if (kind == null || !_usesLegacyFastEntry(kind)) {
      if (!buildContext.mounted) return;
      unawaited(buildContext.push(route));
      return;
    }

    await showFDialog<void>(
      context: buildContext,
      builder: (dialogContext, style, animation) => RecordFastEntryDialog(
        kind: kind,
        occurredAt: context.occurredAt,
        currentDateTime: context.now,
        moreRoute: route,
        animation: animation,
      ),
    );
  }

  Future<void> _recordWater(QuickEntryExecutionContext context) async {
    final buildContext = context.buildContext;
    final l10n = AppLocalizations.of(buildContext)!;
    QuickEntryUndoAction? undoAction;

    // Show the water amount sheet; the user picks a preset or enters a custom
    // ml amount. Dismissing the sheet records nothing.
    final result = await showWaterQuickEntrySheet(buildContext);
    if (result == null || !buildContext.mounted) return;

    try {
      await WaterQuickEntryFlow(
        createRecord: createRecord,
        emitDataChange: emitDataChange,
        registerUndo: (action) => undoAction = action,
      ).record(
        QuickEntryRecordContext(
          occurredAt: context.occurredAt,
          occurredTime: context.occurredTime,
        ),
        preferences.copyWith(
          waterDefault: QuickEntryWaterDefault.custom,
          waterCustomMl: result.amountMl,
        ),
      );
    } catch (e, st) {
      appTalker.error('QuickEntryExecutor: water record failed: $e', st);
      if (!buildContext.mounted) return;
      await Toast.show(buildContext, l10n.recordCreateFailedToast);
      return;
    }

    final action = undoAction;
    if (!buildContext.mounted || action == null) return;
    await Toast.showWithAction(
      buildContext,
      l10n.recordQuickSavedToast,
      l10n.recordQuickUndoAction,
      // The undo action fires on a later user tap; the calling surface
      // (e.g. the quick-entry flow) may have been closed in between, so
      // guard before using the context (deactivated context trips the
      // `_dependents.isEmpty` assertion).
      () {
        if (!buildContext.mounted) return;
        unawaited(_undo(buildContext, action));
      },
    );
  }

  /// 症状：sheet 只收集选择，落库与撤销都在这里（application 层）做。
  ///
  /// 撤销 toast 的 action 用的是页面 context：若让 sheet 自己落库 + 弹 toast，等用户点
  /// 撤销时 sheet 的 context 已失活，撤销会静默失效。
  Future<void> _recordSymptom(
    QuickEntryExecutionContext context,
    String moreRoute,
  ) async {
    final buildContext = context.buildContext;
    final l10n = AppLocalizations.of(buildContext)!;
    // 不等网络：首屏用本地目录立刻打开 sheet，后端目录（顺序/未知码）由 provider
    // 在后台刷新，下一次打开生效。
    final catalog = loadSymptomCatalog();
    final choices = filterSymptomChoices(
      resolveSymptomChoices(catalog: catalog, l10n: l10n),
      enabledCodes: preferences.symptomEnabledChoices,
    );
    // 设置层保证至少启用一项；真被全部停用时不做任何事。
    if (choices.isEmpty) return;

    final outcome = await showSymptomQuickEntrySheet(
      buildContext,
      recordDate: context.selectedDate,
      choices: choices,
      initialSeverity: preferences.symptomDefaultSeverity,
    );
    if (outcome == null || !buildContext.mounted) return;

    switch (outcome) {
      case SymptomQuickEntryMore():
        unawaited(buildContext.push(moreRoute));
      case SymptomQuickEntrySelection(
        :final choices,
        :final severity,
        :final customLabel,
      ):
        await _saveSymptomSelection(
          context,
          choices,
          severity,
          customLabel: customLabel,
        );
    }
  }

  Future<void> _saveSymptomSelection(
    QuickEntryExecutionContext context,
    List<RecordFastChoice> choices,
    String severity, {
    String? customLabel,
  }) async {
    final buildContext = context.buildContext;
    final l10n = AppLocalizations.of(buildContext)!;
    final severityLabel = symptomSeverityLabel(l10n, severity);
    final flow = SymptomQuickEntryFlow(
      createRecord: createRecord,
      emitDataChange: emitDataChange,
      registerUndo: (_) {},
    );
    final recordContext = QuickEntryRecordContext(
      occurredAt: context.occurredAt,
      occurredTime: context.occurredTime,
    );
    final selections = [
      for (final choice in choices)
        SymptomQuickChoice(
          title: _isOtherSymptom(choice)
              ? (customLabel ?? choice.title ?? choice.label)
              : (choice.title ?? choice.label),
          value: severityLabel,
          note: choice.note,
          payload: <String, dynamic>{
            ...?choice.payload,
            'severity': severity,
            if (_isOtherSymptom(choice) && customLabel != null)
              'customLabel': customLabel,
          },
        ),
    ];

    QuickEntryUndoAction? undo;
    var message = l10n.recordQuickSavedToast;
    try {
      if (selections.length == 1) {
        final item = await flow.recordSingle(recordContext, selections.single);
        undo = QuickEntryUndoAction.deleteDailyRecord(recordId: item.id);
      } else {
        final result = await flow.recordBatch(recordContext, selections);
        if (result.succeeded.isEmpty) {
          if (!buildContext.mounted) return;
          await Toast.show(buildContext, l10n.recordCreateFailedToast);
          return;
        }
        undo = result.batchUndo;
        if (result.failed.isNotEmpty) {
          message = l10n.recordFastEntryPartialFailedToast(
            result.succeeded.length,
            result.failed.length,
          );
        }
      }
    } catch (e, st) {
      appTalker.error('QuickEntryExecutor: symptom record failed: $e', st);
      if (!buildContext.mounted) return;
      await Toast.show(buildContext, l10n.recordCreateFailedToast);
      return;
    }

    final action = undo;
    if (!buildContext.mounted) return;
    if (action == null) {
      await Toast.show(buildContext, message);
      return;
    }
    await Toast.showWithAction(
      buildContext,
      message,
      l10n.recordQuickUndoAction,
      // The undo action fires on a later user tap; the calling page may have
      // been popped in between, so guard before using the context (deactivated
      // context trips the `_dependents.isEmpty` assertion).
      () {
        if (!buildContext.mounted) return;
        unawaited(_undo(buildContext, action));
      },
    );
  }

  bool _isOtherSymptom(RecordFastChoice choice) =>
      recordFastChoiceCode(choice) == SymptomCode.other.wireValue;

  Future<void> _undo(
    BuildContext buildContext,
    QuickEntryUndoAction action,
  ) async {
    try {
      await QuickEntryUndoService(
        deleteDailyRecord: deleteDailyRecord,
        emitDataChange: emitDataChange,
      ).undo(action);
    } catch (e, st) {
      appTalker.error('QuickEntryExecutor: undo failed: $e', st);
      if (!buildContext.mounted) return;
      await Toast.show(
        buildContext,
        AppLocalizations.of(buildContext)!.recordQuickUndoFailedToast,
      );
    }
  }

  String _createRoute(
    QuickEntryExecutionContext context,
    DailyRecordKind? kind,
  ) {
    if (kind == null) {
      return '/record/create?date=${Uri.encodeComponent(context.occurredAt)}';
    }
    return '/record/create?kind=${Uri.encodeComponent(kind.name)}'
        '&date=${Uri.encodeComponent(context.occurredAt)}'
        '&time=${Uri.encodeComponent(context.occurredTime)}';
  }

  bool _usesLegacyFastEntry(DailyRecordKind kind) {
    // water / symptom 各有专用入口（下方分支已拦截）；这里只剩情绪与备注。
    return switch (kind) {
      DailyRecordKind.mood || DailyRecordKind.note => true,
      _ => false,
    };
  }
}
