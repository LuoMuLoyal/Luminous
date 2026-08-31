import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/core/widgets/common/control/divider.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';
import 'package:luminous/features/medicine/domain/entities/workspace.dart';
import 'package:luminous/features/medicine/presentation/routes.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/copy.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/workspace_parts.dart';
import 'package:luminous/features/scan/presentation/pages/box_scan.dart';
import 'package:luminous/l10n/app_localizations.dart';

part '../sections/mobile_drugbox.dart';
part '../sections/mobile_quick_operations.dart';
part '../sections/mobile_records.dart';
part '../sections/mobile_safety.dart';
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
    // 告警由风险检查记录实时派生；bestRecord 为 null 时传可空结果，
    // medicineAlertsFromRiskCheck 对 null 已返回 const []，避免用空结果伪造
    // 「全部通过」告警（未知不得映射为 0）。
    final alerts = medicineAlertsFromRiskCheck(
      l10n,
      workspace.riskCheckRecords?.bestRecord?.result,
    );
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= Breakpoints.desktop;

    final content = isDesktop
        ? _buildDesktopLayout(
            l10n: l10n,
            nextDose: nextDose,
            alerts: alerts,
            isWide: width >= Breakpoints.wide,
          )
        : _buildMobileLayout(l10n: l10n, nextDose: nextDose, alerts: alerts);

    return SkeletonScope(isLoading: isLoading, child: content);
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
        const SizedBox(height: Spacing.level4),
        _MedicineRecordsSection(
          workspace: workspace,
          nextDose: nextDose,
          l10n: l10n,
          onMarkDose: onMarkDose,
        ),
        const SizedBox(height: Spacing.level4),
        _SafetyEngineSection(
          records: workspace.riskCheckRecords,
          alerts: alerts.take(4).toList(growable: false),
          l10n: l10n,
        ),
        const SizedBox(height: Spacing.level4),
        _QuickOperationSection(l10n: l10n, onCreateReminder: onCreateReminder),
      ],
    );
  }

  Widget _buildDesktopLayout({
    required AppLocalizations l10n,
    required _NextDose? nextDose,
    required List<MedicineAlert> alerts,
    required bool isWide,
  }) {
    // Wide screens (≥1400): three columns — drugbox | records+safety | quick ops
    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: drug box.
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DrugBoxSection(
                  workspace: workspace,
                  l10n: l10n,
                  onOpenReminder: onOpenReminder,
                ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.level5),
          // Center: records + safety.
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MedicineRecordsSection(
                  workspace: workspace,
                  nextDose: nextDose,
                  l10n: l10n,
                  onMarkDose: onMarkDose,
                ),
                const SizedBox(height: Spacing.level5),
                _SafetyEngineSection(
                  records: workspace.riskCheckRecords,
                  alerts: alerts.take(4).toList(growable: false),
                  l10n: l10n,
                ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.level5),
          // Right: quick operations.
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _QuickOperationSection(
                  l10n: l10n,
                  onCreateReminder: onCreateReminder,
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Standard desktop (1200–1400): two columns — drugbox+records | safety+ops
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
              const SizedBox(height: Spacing.level5),
              _MedicineRecordsSection(
                workspace: workspace,
                nextDose: nextDose,
                l10n: l10n,
                onMarkDose: onMarkDose,
              ),
            ],
          ),
        ),
        const SizedBox(width: Spacing.level5),
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SafetyEngineSection(
                records: workspace.riskCheckRecords,
                alerts: alerts.take(4).toList(growable: false),
                l10n: l10n,
              ),
              const SizedBox(height: Spacing.level5),
              _QuickOperationSection(
                l10n: l10n,
                onCreateReminder: onCreateReminder,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
