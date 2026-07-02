import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/widgets/common/app_icon_badge.dart';
import 'package:luminous/features/report/domain/entities/report_dashboard.dart';
import 'package:luminous/features/report/presentation/widgets/shared/report_section_models.dart';
import 'package:luminous/features/settings/presentation/providers/data_export_controller.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ReportExportSection extends StatelessWidget {
  const ReportExportSection({
    super.key,
    required this.actions,
    required this.latestRequest,
    required this.requestInFlight,
    required this.l10n,
    this.onActionTap,
  });

  final List<ReportExportAction> actions;
  final DataExportRequestDataDto? latestRequest;
  final DataExportRequestInFlightState requestInFlight;
  final AppLocalizations l10n;
  final Future<void> Function(ReportExportKind kind)? onActionTap;

  double _exportCardHeight(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= AppBreakpoints.desktop) return 124;
    if (width >= AppBreakpoints.tablet) return 112;
    return 104;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.reportExportSectionTitle,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacingTokens.level3),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacingTokens.level3,
            mainAxisSpacing: AppSpacingTokens.level3,
            mainAxisExtent: _exportCardHeight(context),
          ),
          itemBuilder: (context, index) {
            return _ExportCard(
              action: actions[index],
              latestRequest: latestRequest,
              requestInFlight: requestInFlight,
              onTap: onActionTap,
              l10n: l10n,
            );
          },
        ),
      ],
    );
  }
}

class _ExportCard extends StatelessWidget {
  const _ExportCard({
    required this.action,
    required this.latestRequest,
    required this.requestInFlight,
    required this.l10n,
    this.onTap,
  });

  final ReportExportAction action;
  final DataExportRequestDataDto? latestRequest;
  final DataExportRequestInFlightState requestInFlight;
  final AppLocalizations l10n;
  final Future<void> Function(ReportExportKind kind)? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;
    final title = reportExportTitle(l10n, action.kind);
    final subtitle = reportExportCardSubtitle(l10n, action.kind, latestRequest);
    final enabled = onTap != null;
    final exportInput = reportExportInputForKind(action.kind);
    final showProgress =
        exportInput != null && requestInFlight.matches(exportInput);
    final trailingIcon = showProgress
        ? FLucideIcons.loaderCircle
        : enabled
        ? FLucideIcons.chevronRight
        : FLucideIcons.lock;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: !enabled || requestInFlight.inFlight
            ? null
            : () async {
                await onTap!(action.kind);
              },
        borderRadius: BorderRadius.circular(AppRadiusTokens.level4),
        child: FCard.raw(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacingTokens.level4),
            child: Row(
              children: [
                AppIconBadge(icon: action.icon, color: action.color),
                const SizedBox(width: AppSpacingTokens.level4),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacingTokens.level1),
                      Text(
                        subtitle,
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.mutedForeground,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(trailingIcon, color: colors.mutedForeground, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
