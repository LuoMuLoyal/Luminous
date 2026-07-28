import 'dart:async';

import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/domain/entities/type_mapping.dart';
import 'package:luminous/features/record/presentation/services/quick_entry_context.dart';
import 'package:luminous/features/record/presentation/widgets/dialogs/fast_entry_dialog.dart';

class QuickEntryExecutor {
  const QuickEntryExecutor();

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
      DailyRecordKind.meal ||
      DailyRecordKind.symptom ||
      DailyRecordKind.mood ||
      DailyRecordKind.note ||
      DailyRecordKind.sleep => true,
      _ => false,
    };
  }
}
