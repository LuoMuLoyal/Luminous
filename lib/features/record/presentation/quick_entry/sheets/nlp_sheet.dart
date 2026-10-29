import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/auth_session_adapter.dart';
import 'package:luminous/core/utils/hour_minute.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/features/record/application/usecases/nlp_sheet_intent.dart';
import 'package:luminous/features/record/presentation/controllers/nlp.dart';
import 'package:luminous/features/record/presentation/widgets/dialogs/nlp_sheet.dart';

/// Opens the NLP input sheet for the given date.
///
/// If the user is not authenticated, shows the auth-required dialog instead.
/// The gate itself is the application-layer [resolveNlpSheetIntent]; this
/// function only performs the resulting UI effect.
Future<void> openNlpSheet({
  required WidgetRef ref,
  required BuildContext context,
  required DateTime selectedDate,
}) async {
  final session = ref.read(authSessionProvider);
  final intent = resolveNlpSheetIntent(
    canAccessProtectedData: session.canAccessProtectedData,
    isAuthLoading: session.isLoading,
    occurredAt: formatCalendarDateKey(selectedDate),
  );

  switch (intent) {
    case NlpSheetAuthLoadingIntent():
      return;
    case NlpSheetNeedsSignInIntent():
      await showAuthRequiredDialog(
        context,
        onLogin: () => context.push(loginRouteForCurrentLocation(context)),
      );
      return;
    case NlpSheetOpenIntent(:final occurredAt):
      ref.read(recordNlpControllerProvider.notifier).reset();
      await showFSheet<void>(
        context: context,
        side: FLayout.btt,
        useSafeArea: true,
        resizeToAvoidBottomInset: true,
        mainAxisMaxRatio: null,
        builder: (sheetContext) => RecordNlpSheet(occurredAt: occurredAt),
      );
  }
}
