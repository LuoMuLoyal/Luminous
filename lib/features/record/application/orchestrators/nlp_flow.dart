import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/features/record/presentation/controllers/nlp.dart';
import 'package:luminous/features/record/presentation/utils/date_time_formatters.dart';
import 'package:luminous/features/record/presentation/widgets/dialogs/nlp_sheet.dart';

/// Opens the NLP input sheet for the given date.
///
/// If the user is not authenticated, shows the auth-required dialog instead.
Future<void> openNlpSheet({
  required WidgetRef ref,
  required BuildContext context,
  required bool canAccessProtectedData,
  required bool isAuthLoading,
  required DateTime selectedDate,
}) async {
  if (!canAccessProtectedData) {
    if (isAuthLoading) {
      return;
    }
    await showAuthRequiredDialog(
      context,
      onLogin: () => context.push(loginRouteForCurrentLocation(context)),
    );
    return;
  }

  ref.read(recordNlpControllerProvider.notifier).reset();
  await showFSheet<void>(
    context: context,
    side: FLayout.btt,
    useSafeArea: true,
    resizeToAvoidBottomInset: true,
    mainAxisMaxRatio: 0.85,
    builder: (sheetContext) =>
        RecordNlpSheet(occurredAt: formatRecordDate(selectedDate)),
  );
}
