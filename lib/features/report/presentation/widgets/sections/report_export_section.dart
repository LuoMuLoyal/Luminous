import 'package:flutter/material.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/widgets/common/app_section_surface.dart';
import 'package:luminous/core/widgets/common/app_section_header.dart';
import 'package:luminous/core/widgets/common/app_icon_badge.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
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
    required this.typography,
    required this.surface,
    this.onActionTap,
  });

  final List<ReportExportAction> actions;
  final DataExportRequestDataDto? latestRequest;
  final DataExportRequestInFlightState requestInFlight;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final Future<void> Function(ReportExportKind kind)? onActionTap;

  double _exportCardHeight(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= AppBreakpoints.desktop) return 124;
    if (width >= AppBreakpoints.tablet) return 112;
    return 104;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(title: l10n.reportExportSectionTitle),
        const SizedBox(height: AppSpacingTokens.sm),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacingTokens.sm,
            mainAxisSpacing: AppSpacingTokens.sm,
            mainAxisExtent: _exportCardHeight(context),
          ),
          itemBuilder: (context, index) {
            return _ExportCard(
              action: actions[index],
              latestRequest: latestRequest,
              requestInFlight: requestInFlight,
              onTap: onActionTap,
              l10n: l10n,
              typography: typography,
              surface: surface,
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
    required this.typography,
    required this.surface,
    this.onTap,
  });

  final ReportExportAction action;
  final DataExportRequestDataDto? latestRequest;
  final DataExportRequestInFlightState requestInFlight;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final Future<void> Function(ReportExportKind kind)? onTap;

  @override
  Widget build(BuildContext context) {
    final title = reportExportTitle(l10n, action.kind);
    final subtitle = reportExportCardSubtitle(l10n, action.kind, latestRequest);
    final enabled = onTap != null;
    final exportInput = reportExportInputForKind(action.kind);
    final showProgress =
        exportInput != null && requestInFlight.matches(exportInput);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: !enabled || requestInFlight.inFlight
            ? null
            : () async {
                await onTap!(action.kind);
              },
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: AppSectionSurface(
          child: Row(
            children: [
              AppIconBadge(icon: action.icon, color: action.color),
              const SizedBox(width: AppSpacingTokens.md),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: typography.bodyMdStrong.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacingTokens.xxs),
                    Text(
                      subtitle,
                      style: typography.caption.copyWith(
                        color: surface.body,
                        letterSpacing: 0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                showProgress
                    ? Icons.hourglass_top_rounded
                    : enabled
                    ? Icons.chevron_right_rounded
                    : Icons.lock_outline_rounded,
                color: surface.body,
                size: AppSpacingTokens.lg,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
