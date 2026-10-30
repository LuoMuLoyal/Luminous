import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/medicine/presentation/providers/surface.dart';
import 'package:luminous/features/medicine/presentation/widgets/sections/mobile_safety.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 安全引擎区块：风险检查结论 + 告警。
///
/// 自取 `medicineSurfaceStateProvider`；风险检查记录仍来自同一个工作区读模型。
/// 无数据时整块不渲染（不留空占位），与其它区块一致。
class SafetyEngineSection extends ConsumerWidget {
  const SafetyEngineSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(medicineSurfaceStateProvider).dataOrNull;
    if (workspace == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    // 告警由风险检查记录实时派生；bestRecord 为 null 时传可空结果，
    // medicineAlertsFromRiskCheck 对 null 已返回 const []，避免用空结果伪造
    // 「全部通过」告警（未知不得映射为 0）。
    final alerts = medicineAlertsFromRiskCheck(
      l10n,
      workspace.riskCheckRecords?.bestRecord?.result,
    );

    return SafetyEngineSummary(
      records: workspace.riskCheckRecords,
      alerts: alerts.take(4).toList(growable: false),
      l10n: l10n,
    );
  }
}
