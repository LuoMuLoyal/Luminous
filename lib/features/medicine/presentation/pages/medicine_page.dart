import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/constants/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/page_scaffold_shell.dart';
import 'package:luminous/features/medicine/data/repositories/mock_medicine_workspace_repository.dart';
import 'package:luminous/features/medicine/presentation/providers/medicine_workspace_provider.dart';
import 'package:luminous/features/medicine/presentation/widgets/medicine_workspace_parts.dart';
import 'package:luminous/features/medicine/presentation/widgets/medicine_workspace_view.dart';
import 'package:luminous/features/today/presentation/providers/today_dashboard_provider.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MedicinePage extends ConsumerWidget {
  const MedicinePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspaceAsync = ref.watch(medicineWorkspaceProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final surface = theme.extension<AppThemeSurface>()!;
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < AppBreakpoints.mobile;
    final typography = width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(scheme.onSurface)
        : AppTypographyTokens.desktop(scheme.onSurface);

    return PageScaffoldShell(
      title: l10n.tabMedicine,
      actions: <Widget>[
        MedicineHeaderActionChip(
          label: isCompact
              ? l10n.medicineHeaderActionSearchCompact
              : l10n.medicineHeaderActionSearch,
          icon: Icons.search_rounded,
          typography: typography,
          surface: surface,
          onTap: () => context.push('/medicine/search'),
        ),
        MedicineHeaderActionChip(
          label: isCompact
              ? l10n.medicineHeaderActionAddCompact
              : l10n.medicineHeaderActionAdd,
          icon: Icons.add_rounded,
          emphasized: true,
          typography: typography,
          surface: surface,
          onTap: () => _showHeaderActionMessage(
            context,
            l10n.medicineHeaderActionAdd,
            l10n.medicineHeaderAddToast,
          ),
        ),
      ],
      children: [
        workspaceAsync.when(
          data: (workspace) => MedicineWorkspaceView(
            workspace: workspace,
            onMarkDose: (currentMedicineId, action) =>
                _markDose(context, ref, currentMedicineId, action),
          ),
          loading: () => const MedicineWorkspaceLoadingView(),
          error: (_, __) => MedicineErrorView(
            onRetry: () => ref.invalidate(medicineWorkspaceProvider),
          ),
        ),
      ],
    );
  }
}

Future<void> _markDose(
  BuildContext context,
  WidgetRef ref,
  String currentMedicineId,
  MedicineDoseAction action,
) async {
  final l10n = AppLocalizations.of(context)!;
  final today = DateTime.now();
  final dateStr =
      '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

  try {
    await ref
        .read(doseLogRemoteDataSourceProvider)
        .create(currentMedicineId, action.name, dateStr);
    ref.invalidate(medicineWorkspaceProvider);
    ref.invalidate(todayDashboardProvider);
    if (context.mounted) {
      AppToast.show(context, l10n.medicineDoseActionSavedToast);
    }
  } catch (error) {
    if (context.mounted) {
      AppToast.show(context, l10n.medicineDoseActionFailedToast);
    }
  }
}

void _showHeaderActionMessage(
  BuildContext context,
  String title,
  String message,
) {
  AppToast.show(context, '$title: $message');
}
