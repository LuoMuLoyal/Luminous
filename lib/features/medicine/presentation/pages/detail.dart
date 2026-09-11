import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/features/medicine/presentation/pages/medicine_detail_content.dart';
import 'package:luminous/features/medicine/presentation/providers/medicine_detail.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Mobile medication knowledge detail page (F-14).
///
/// Renders the package-insert / DrugBank sections for a medicine identified by
/// [source] (`cn` | `drugbank`) and [id], plus an "add to drugbox" action and
/// a risk-check entry.
class MedicineDetailPage extends ConsumerWidget {
  const MedicineDetailPage({super.key, required this.source, required this.id});

  final String source;
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    if (source != 'cn' && source != 'drugbank') {
      return PageScaffold(
        title: l10n.medicineDetailPageTitle,
        child: StateErrorView(
          title: l10n.medicineDetailUnknownSourceTitle,
          description: '',
          icon: SemanticIcons.statusError,
        ),
      );
    }

    final detailAsync = ref.watch(medicineDetailProvider(source, id));

    return PageScaffold(
      title: l10n.medicineDetailPageTitle,
      child: detailAsync.when(
        data: (detail) => MedicineDetailContent(detail: detail, source: source),
        loading: () => const MedicineDetailLoading(),
        error: (_, __) => StateErrorView(
          title: l10n.medicineDetailErrorTitle,
          description: l10n.medicineDetailErrorDescription,
          icon: SemanticIcons.statusError,
          actionLabel: l10n.todayRetryAction,
          onAction: () => ref.invalidate(medicineDetailProvider(source, id)),
        ),
      ),
    );
  }
}

/// Loading skeleton for medicine detail page.
class MedicineDetailLoading extends StatelessWidget {
  const MedicineDetailLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.lg,
        vertical: Spacing.lg,
      ),
      child: InlineSkeletonSection(
        children: [
          InlineSkeletonBlock(height: 96),
          InlineSkeletonBlock(height: 40),
          InlineSkeletonBlock(height: 160),
          InlineSkeletonBlock(height: 52),
        ],
      ),
    );
  }
}
