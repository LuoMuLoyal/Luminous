import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:luminous/core/widgets/app_section_surface.dart';
import 'package:luminous/core/widgets/app_text_action.dart';
import 'package:luminous/core/widgets/app_status_pill.dart';
import 'package:luminous/core/widgets/app_section_header.dart';
import 'package:luminous/core/widgets/app_icon_badge.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_required_dialog.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_safety_tip.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_workspace.dart';
import 'package:luminous/features/medicine/presentation/providers/medicine_safety_tips_provider.dart';
import 'package:luminous/features/medicine/presentation/widgets/medicine_copy.dart';
import 'package:luminous/features/shell/providers/shell_provider.dart';
import 'package:luminous/features/medicine/presentation/widgets/medicine_workspace_parts.dart';
import 'package:luminous/l10n/app_localizations.dart';

part 'medicine_mobile_drugbox_section.dart';
part 'medicine_mobile_quick_operations_section.dart';
part 'medicine_mobile_records_section.dart';
part 'medicine_mobile_reference_section.dart';
part 'medicine_mobile_safety_section.dart';
part 'medicine_mobile_shared.dart';

class MedicineMobileDashboardView extends StatelessWidget {
  const MedicineMobileDashboardView({
    super.key,
    required this.workspace,
    this.onMarkDose,
    this.onOpenReminder,
    this.onCreateReminder,
    this.isLoading = false,
  });

  final MedicineWorkspace workspace;
  final void Function(String currentMedicineId, MedicineDoseAction action)?
  onMarkDose;
  final void Function(String currentMedicineId)? onOpenReminder;
  final VoidCallback? onCreateReminder;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);
    final nextDose = _nextDoseFor(workspace);
    final alerts = medicineAlertsFromRiskCheck(l10n, workspace.riskCheckResult);
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= AppBreakpoints.desktop;

    final content = isDesktop
        ? _buildDesktopLayout(
            l10n: l10n,
            surface: surface,
            typography: typography,
            nextDose: nextDose,
            alerts: alerts,
          )
        : _buildMobileLayout(
            l10n: l10n,
            surface: surface,
            typography: typography,
            nextDose: nextDose,
            alerts: alerts,
          );

    return AppSkeletonScope(isLoading: isLoading, child: content);
  }

  Widget _buildMobileLayout({
    required AppLocalizations l10n,
    required AppThemeSurface surface,
    required AppTypographyScale typography,
    required _NextDose? nextDose,
    required List<MedicineAlert> alerts,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DrugBoxSection(
          workspace: workspace,
          nextDose: nextDose,
          l10n: l10n,
          typography: typography,
          surface: surface,
          onMarkDose: onMarkDose,
          onOpenReminder: onOpenReminder,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        _SafetyEngineSection(
          alerts: alerts.take(4).toList(growable: false),
          l10n: l10n,
          typography: typography,
          surface: surface,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        _QuickOperationSection(
          l10n: l10n,
          typography: typography,
          surface: surface,
          onCreateReminder: onCreateReminder,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        _MedicineRecordsSection(
          items: workspace.plan.items,
          l10n: l10n,
          typography: typography,
          surface: surface,
          onMarkDose: onMarkDose,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        _ReferenceNotice(l10n: l10n, typography: typography, surface: surface),
        const SizedBox(height: AppSpacingTokens.md),
        _SafetyTipsSection(
          l10n: l10n,
          typography: typography,
          surface: surface,
        ),
      ],
    );
  }

  Widget _buildDesktopLayout({
    required AppLocalizations l10n,
    required AppThemeSurface surface,
    required AppTypographyScale typography,
    required _NextDose? nextDose,
    required List<MedicineAlert> alerts,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DrugBoxSection(
                workspace: workspace,
                nextDose: nextDose,
                l10n: l10n,
                typography: typography,
                surface: surface,
                onMarkDose: onMarkDose,
                onOpenReminder: onOpenReminder,
              ),
              const SizedBox(height: AppSpacingTokens.lg),
              _SafetyEngineSection(
                alerts: alerts.take(4).toList(growable: false),
                l10n: l10n,
                typography: typography,
                surface: surface,
              ),
              const SizedBox(height: AppSpacingTokens.lg),
              _MedicineRecordsSection(
                items: workspace.plan.items,
                l10n: l10n,
                typography: typography,
                surface: surface,
                onMarkDose: onMarkDose,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacingTokens.lg),
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ReferenceNotice(
                l10n: l10n,
                typography: typography,
                surface: surface,
              ),
              const SizedBox(height: AppSpacingTokens.lg),
              _QuickOperationSection(
                l10n: l10n,
                typography: typography,
                surface: surface,
                onCreateReminder: onCreateReminder,
              ),
              const SizedBox(height: AppSpacingTokens.lg),
              _SafetyTipsSection(
                l10n: l10n,
                typography: typography,
                surface: surface,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
