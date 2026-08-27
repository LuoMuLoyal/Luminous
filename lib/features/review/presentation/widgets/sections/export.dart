import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';
import 'package:luminous/features/review/presentation/widgets/shared/section_models.dart';
import 'package:luminous/features/settings/presentation/providers/data_export.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ReviewExportSection extends StatelessWidget {
  const ReviewExportSection({
    super.key,
    required this.actions,
    required this.latestRequest,
    required this.requestInFlight,
    required this.l10n,
    this.onActionTap,
    this.isDataInsufficient = false,
    this.clinicShareInFlight = false,
  });

  final List<ReviewExportAction> actions;
  final DataExportRequestDataDto? latestRequest;
  final DataExportRequestInFlightState requestInFlight;
  final AppLocalizations l10n;
  final Future<void> Function(ReviewExportKind kind)? onActionTap;
  final bool isDataInsufficient;
  final bool clinicShareInFlight;

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
          l10n.reviewExportSectionTitle,
          style: TypographyToken.level5
              .body(context)
              .copyWith(fontWeight: FontWeight.w700),
        ),
        if (isDataInsufficient) ...[
          const SizedBox(height: Spacing.level2),
          Text(
            l10n.reviewExportInsufficientReason,
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
              clinicShareInFlight: clinicShareInFlight,
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
    this.clinicShareInFlight = false,
  });

  final ReviewExportAction action;
  final DataExportRequestDataDto? latestRequest;
  final DataExportRequestInFlightState requestInFlight;
  final AppLocalizations l10n;
  final Future<void> Function(ReviewExportKind kind)? onTap;
  final bool clinicShareInFlight;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    final title = reportExportTitle(l10n, action.kind);
    final subtitle = reportExportCardSubtitle(l10n, action.kind, latestRequest);
    final enabled = onTap != null;
    final exportInput = reportExportInputForKind(action.kind);
    final isClinicShare = action.kind == ReviewExportKind.clinicShare;
    final showProgress = isClinicShare
        ? clinicShareInFlight
        : exportInput != null && requestInFlight.matches(exportInput);
    final anyInFlight = isClinicShare
        ? clinicShareInFlight
        : requestInFlight.inFlight;
    final trailingIcon = showProgress
        ? SemanticIcons.aiAnalyzing
        : enabled && !anyInFlight
        ? SemanticIcons.actionNext
        : SemanticIcons.statusBlocked;

    return FButton.raw(
      onPress: !enabled || anyInFlight
          ? null
          : () async {
              await onTap!(action.kind);
            },
      variant: FButtonVariant.ghost,
      style: const .delta(
        contentStyle: .delta(padding: .value(EdgeInsets.zero)),
      ),
      child: FCard(
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
              Icon(
                trailingIcon,
                color: colors.mutedForeground,
                size: IconSizeTokens.level3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
