import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/features/record/application/usecases/quick_entry_undo.dart';
import 'package:luminous/features/record/application/usecases/water_quick_entry.dart';
import 'package:luminous/features/record/data/quick_entry_preferences.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/domain/entities/type_mapping.dart';
import 'package:luminous/features/record/presentation/services/quick_entry_context.dart';
import 'package:luminous/features/record/presentation/widgets/dialogs/fast_entry_dialog.dart';
import 'package:luminous/l10n/app_localizations.dart';

class QuickEntryExecutor {
  const QuickEntryExecutor({
    required this.createRecord,
    required this.deleteDailyRecord,
    required this.emitDataChange,
    required this.preferences,
  });

  final CreateDailyRecord createRecord;
  final DeleteDailyRecord deleteDailyRecord;
  final EmitDataChange emitDataChange;
  final QuickEntryPreferences preferences;

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
        preferences,
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
    return switch (kind) {
      DailyRecordKind.water ||
      DailyRecordKind.symptom ||
      DailyRecordKind.mood ||
      DailyRecordKind.note => true,
      _ => false,
    };
  }
}
