import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/constants/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/page_scaffold_shell.dart';
import 'package:luminous/features/medicine/presentation/providers/medicine_workspace_provider.dart';
import 'package:luminous/features/medicine/presentation/widgets/medicine_workspace_parts.dart';
import 'package:luminous/features/medicine/presentation/widgets/medicine_workspace_view.dart';
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
    final typography = width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(scheme.onSurface)
        : AppTypographyTokens.desktop(scheme.onSurface);

    return PageScaffoldShell(
      title: l10n.tabMedicine,
      actions: <Widget>[
        MedicineHeaderActionChip(
          label: l10n.medicineHeaderActionSearch,
          icon: Icons.search_rounded,
          typography: typography,
          surface: surface,
          onTap: () => _showHeaderActionMessage(
            context,
            l10n.medicineHeaderActionSearch,
            '会跳转到搜索药品页。',
          ),
        ),
        MedicineHeaderActionChip(
          label: l10n.medicineHeaderActionAdd,
          icon: Icons.add_rounded,
          emphasized: true,
          typography: typography,
          surface: surface,
          onTap: () => _showHeaderActionMessage(
            context,
            l10n.medicineHeaderActionAdd,
            '会打开添加药品与识别入口。',
          ),
        ),
      ],
      children: [
        workspaceAsync.when(
          data: (workspace) => MedicineWorkspaceView(workspace: workspace),
          loading: () => const MedicineLoadingView(),
          error: (_, __) => MedicineErrorView(
            onRetry: () => ref.invalidate(medicineWorkspaceProvider),
          ),
        ),
      ],
    );
  }
}

void _showHeaderActionMessage(
  BuildContext context,
  String title,
  String message,
) {
  AppToast.show(context, '$title: $message');
}
