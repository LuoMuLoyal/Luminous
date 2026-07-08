import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/widgets/common/divider.dart';
import 'package:luminous/core/design/colors.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';
import 'package:luminous/features/medicine/domain/entities/workspace.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/copy.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/workspace_parts.dart';
import 'package:luminous/l10n/app_localizations.dart';

part '../sections/mobile_drugbox_section.dart';
part '../sections/mobile_quick_operations_section.dart';
part '../sections/mobile_records_section.dart';
part '../sections/mobile_safety_section.dart';
part '../shared/mobile_shared.dart';

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
  final void Function(MedicineDoseMarkRequest request)? onMarkDose;
  final void Function(String currentMedicineId)? onOpenReminder;
  final VoidCallback? onCreateReminder;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final nextDose = _nextDoseFor(workspace);
    final alerts = medicineAlertsFromRiskCheck(l10n, workspace.riskCheckResult);
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= AppBreakpoints.desktop;

    final content = isDesktop
        ? _buildDesktopLayout(l10n: l10n, nextDose: nextDose, alerts: alerts)
        : _buildMobileLayout(l10n: l10n, nextDose: nextDose, alerts: alerts);

    return AppSkeletonScope(isLoading: isLoading, child: content);
  }

  Widget _buildMobileLayout({
    required AppLocalizations l10n,
    required _NextDose? nextDose,
    required List<MedicineAlert> alerts,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DrugBoxSection(
          workspace: workspace,
          l10n: l10n,
          onOpenReminder: onOpenReminder,
        ),
        const SizedBox(height: AppSpacingTokens.level4),
        _MedicineRecordsSection(
          workspace: workspace,
          nextDose: nextDose,
          l10n: l10n,
          onMarkDose: onMarkDose,
        ),
        const SizedBox(height: AppSpacingTokens.level4),
        _SafetyEngineSection(
          result: workspace.riskCheckResult,
          alerts: alerts.take(4).toList(growable: false),
          l10n: l10n,
        ),
        const SizedBox(height: AppSpacingTokens.level4),
        _QuickOperationSection(l10n: l10n, onCreateReminder: onCreateReminder),
      ],
    );
  }

  Widget _buildDesktopLayout({
    required AppLocalizations l10n,
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
                l10n: l10n,
                onOpenReminder: onOpenReminder,
              ),
              const SizedBox(height: AppSpacingTokens.level5),
              _MedicineRecordsSection(
                workspace: workspace,
                nextDose: nextDose,
                l10n: l10n,
                onMarkDose: onMarkDose,
              ),
              const SizedBox(height: AppSpacingTokens.level5),
              _SafetyEngineSection(
                result: workspace.riskCheckResult,
                alerts: alerts.take(4).toList(growable: false),
                l10n: l10n,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacingTokens.level5),
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _QuickOperationSection(
                l10n: l10n,
                onCreateReminder: onCreateReminder,
              ),
              const SizedBox(height: AppSpacingTokens.level5),
            ],
          ),
        ),
      ],
    );
  }
}
