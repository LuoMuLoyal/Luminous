import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/common/app_state_views.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_workspace.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/medicine_copy.dart';
import 'package:luminous/features/medicine/presentation/widgets/views/medicine_mobile_dashboard_view.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/medicine_workspace_parts.dart';
import 'package:luminous/features/medicine/presentation/widgets/workspace/medicine_metrics_panel.dart';
import 'package:luminous/features/medicine/presentation/widgets/workspace/medicine_quick_action_section.dart';
import 'package:luminous/features/medicine/presentation/widgets/workspace/medicine_safety_panel.dart';
import 'package:luminous/features/medicine/presentation/widgets/workspace/medicine_today_plan_section.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MedicineWorkspaceView extends StatelessWidget {
  const MedicineWorkspaceView({
    super.key,
    required this.workspace,
    this.onMarkDose,
  });

  final MedicineWorkspace workspace;
  final void Function(String currentMedicineId, MedicineDoseAction action)?
  onMarkDose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final surface = theme.extension<AppThemeSurface>()!;
    final width = MediaQuery.sizeOf(context).width;
    final typography = width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(scheme.onSurface)
        : AppTypographyTokens.desktop(scheme.onSurface);
    final isDesktop = width >= AppBreakpoints.desktop;
    final alerts = medicineAlertsFromRiskCheck(l10n, workspace.riskCheckResult);

    if (!isDesktop) {
      return Animate(
        effects: const [
          FadeEffect(duration: Duration(milliseconds: 220)),
          SlideEffect(
            begin: Offset(0, 0.018),
            end: Offset.zero,
            duration: Duration(milliseconds: 240),
          ),
        ],
        child: MedicineMobileDashboardView(
          workspace: workspace,
          onMarkDose: onMarkDose,
        ),
      );
    }

    final primaryColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MedicineMetricsPanel(
          key: const Key('medicine-hero'),
          workspace: workspace,
          typography: typography,
          surface: surface,
          l10n: l10n,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        MedicineQuickActionSection(
          key: const Key('medicine-quick-actions'),
          workspace: workspace,
          typography: typography,
          surface: surface,
          l10n: l10n,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        MedicineTodayPlanSection(
          key: const Key('medicine-today-plan'),
          workspace: workspace,
          typography: typography,
          surface: surface,
          l10n: l10n,
          onMarkDose: onMarkDose,
        ),
      ],
    );

    final safetyColumn = MedicineSafetyPanel(
      key: const Key('medicine-safety-panel'),
      workspace: workspace,
      alerts: alerts,
      typography: typography,
      surface: surface,
      l10n: l10n,
    );

    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 7, child: primaryColumn),
        const SizedBox(width: AppSpacingTokens.lg),
        Expanded(flex: 3, child: safetyColumn),
      ],
    );

    return Animate(
      effects: const [
        FadeEffect(duration: Duration(milliseconds: 240)),
        SlideEffect(
          begin: Offset(0, 0.025),
          end: Offset.zero,
          duration: Duration(milliseconds: 260),
        ),
      ],
      child: content,
    );
  }
}

class MedicineErrorView extends StatelessWidget {
  const MedicineErrorView({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppStateErrorView(
      title: l10n.medicineErrorTitle,
      description: l10n.medicineErrorDescription,
      icon: Icons.medication_liquid_outlined,
      actionLabel: l10n.todayRetryAction,
      onAction: onRetry,
      tone: AppStateTone.warning,
    );
  }
}
