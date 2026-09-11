import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/record/data/providers/record_access.dart';
import 'package:luminous/features/record/presentation/widgets/detail/body.dart';
import 'package:luminous/features/record/presentation/widgets/detail/loading.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordDetailPage extends ConsumerWidget {
  const RecordDetailPage({super.key, required this.recordId});

  final String recordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(authSessionProvider);

    final Widget content;

    if (!session.canAccessProtectedData) {
      final width = MediaQuery.sizeOf(context).width;
      content = ResponsiveContentFrame(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: width < Breakpoints.mobile ? Spacing.xl2 : Spacing.xl3,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              session.isLoading
                  ? const RecordDetailLoading()
                  : AuthRequiredDialogGate(
                      onLogin: () =>
                          context.push(loginRouteForCurrentLocation(context)),
                    ),
            ],
          ),
        ),
      );
    } else {
      final detail = ref.watch(dailyRecordDetailProvider(recordId));

      final width = MediaQuery.sizeOf(context).width;
      content = ResponsiveContentFrame(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: width < Breakpoints.mobile ? Spacing.xl2 : Spacing.xl3,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              detail.when(
                data: (record) => RecordDetailBody(record: record),
                loading: () => const RecordDetailLoading(),
                error: (_, __) => StateErrorView(
                  title: l10n.recordDetailErrorTitle,
                  description: l10n.recordErrorDescription,
                  icon: SemanticIcons.tabRecord,
                  actionLabel: l10n.todayRetryAction,
                  onAction: () =>
                      ref.invalidate(dailyRecordDetailProvider(recordId)),
                  tone: StateTone.warning,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // The edit entry point lives in the page body as the primary action,
    // keeping the header clean and the detail page clearly read-only.
    return PageScaffold(
      title: l10n.recordDetailTitle,
      child: SingleChildScrollView(child: content),
    );
  }
}
