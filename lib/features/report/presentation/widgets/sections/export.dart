import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:lucent_api/api/export.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/report/domain/entities/dashboard.dart';
import 'package:luminous/features/report/presentation/widgets/shared/section_models.dart';
import 'package:luminous/features/settings/presentation/providers/data_export.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ReportExportSection extends StatelessWidget {
  const ReportExportSection({
    super.key,
    required this.actions,
    required this.latestRequest,
    required this.requestInFlight,
    required this.l10n,
    this.onActionTap,
    this.isDataInsufficient = false,
  });

  final List<ReportExportAction> actions;
  final DataExportRequestDataDto? latestRequest;
  final DataExportRequestInFlightState requestInFlight;
  final AppLocalizations l10n;
  final Future<void> Function(ReportExportKind kind)? onActionTap;
  final bool isDataInsufficient;

  double _exportCardHeight(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= Breakpoints.desktop) return 124;
    if (width >= Breakpoints.tablet) return 112;
    return 104;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.reportExportSectionTitle,
          style: TypographyToken.level5
              .body(context)
              .copyWith(fontWeight: FontWeight.w700),
        ),
        if (isDataInsufficient) ...[
          const SizedBox(height: Spacing.level2),
          Text(
            l10n.reportExportInsufficientReason,
            style: TypographyToken.level3
                .body(context)
                .copyWith(color: colors.mutedForeground),
          ),
        ],
        const SizedBox(height: Spacing.level3),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: Spacing.level3,
            mainAxisSpacing: Spacing.level3,
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

    return FButton.raw(
      onPress: !enabled || requestInFlight.inFlight
          ? null
          : () async {
              await onTap!(action.kind);
            },
      variant: FButtonVariant.ghost,
      style: const .delta(
        contentStyle: .delta(padding: .value(EdgeInsets.zero)),
      ),
      child: FCard.raw(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.level4),
          child: Row(
            children: [
              FAvatar.raw(
                size: Spacing.level8,
                child: Icon(
                  action.icon,
                  color: action.color.solid(context),
                  size: Spacing.level5,
                ),
              ),
              const SizedBox(width: Spacing.level4),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TypographyToken.level5
                          .body(context)
                          .copyWith(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: Spacing.level1),
                    Text(
                      subtitle,
                      style: TypographyToken.level3
                          .body(context)
                          .copyWith(color: colors.mutedForeground),
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
    );
  }
}
