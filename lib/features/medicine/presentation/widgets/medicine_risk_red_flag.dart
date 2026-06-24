import 'package:flutter/material.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/router/external_url_launcher.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_risk_check.dart';
import 'package:luminous/features/medicine/presentation/widgets/medicine_copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MedicineRiskRedFlagBanner extends StatelessWidget {
  const MedicineRiskRedFlagBanner({
    super.key,
    required this.alerts,
    required this.campusResources,
    required this.l10n,
    required this.typography,
    required this.surface,
  });
  final List<RedFlagAlert> alerts;
  final List<SupportResourceDto> campusResources;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacingTokens.md),
      decoration: BoxDecoration(
        color: AppColorTokens.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadiusTokens.md),
        border: Border.all(color: AppColorTokens.error.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppColorTokens.error,
                size: 20,
              ),
              const SizedBox(width: AppSpacingTokens.sm),
              Text(
                redFlagBannerTitle(l10n),
                style: typography.bodyMdStrong.copyWith(
                  color: AppColorTokens.error,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacingTokens.sm),
          for (var i = 0; i < alerts.length; i += 1) ...[
            if (i > 0) const SizedBox(height: AppSpacingTokens.sm),
            MedicineRiskRedFlagAlertRow(
              alert: alerts[i],
              campusResources: campusResources,
              l10n: l10n,
              typography: typography,
              surface: surface,
            ),
          ],
        ],
      ),
    );
  }
}

class MedicineRiskRedFlagAlertRow extends StatelessWidget {
  const MedicineRiskRedFlagAlertRow({
    super.key,
    required this.alert,
    required this.campusResources,
    required this.l10n,
    required this.typography,
    required this.surface,
  });
  final RedFlagAlert alert;
  final List<SupportResourceDto> campusResources;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  SupportResourceDto? get matchedResource {
    final id = alert.resourceId;
    if (id == null) return null;
    return campusResources.where((r) => r.id == id).firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resource = matchedResource;
    final hasRealAction =
        resource != null &&
        resource.actionUrl != null &&
        resource.actionUrl!.isNotEmpty &&
        resource.actionType != null;
    return Container(
      padding: const EdgeInsets.all(AppSpacingTokens.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.64),
        borderRadius: BorderRadius.circular(AppRadiusTokens.sm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  redFlagAlertCopy(l10n, alert),
                  style: typography.bodySm.copyWith(color: surface.body),
                ),
                const SizedBox(height: AppSpacingTokens.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: AppColorTokens.error,
                      size: 16,
                    ),
                    const SizedBox(width: AppSpacingTokens.xs),
                    Expanded(
                      child: Text(
                        redFlagActionCopy(l10n, alert),
                        style: typography.bodySm.copyWith(
                          color: AppColorTokens.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (alert.resourceId != null) ...[
            const SizedBox(width: AppSpacingTokens.sm),
            TextButton.icon(
              onPressed: hasRealAction
                  ? () => openResource(context, alert.resourceId!)
                  : null,
              icon: Icon(
                Icons.open_in_new_rounded,
                size: 16,
                color: hasRealAction ? AppColorTokens.error : surface.mute,
              ),
              label: Text(
                redFlagResourceLabel(l10n, alert.resourceId!),
                style: typography.caption.copyWith(
                  color: hasRealAction ? AppColorTokens.error : surface.mute,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacingTokens.sm,
                ),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> openResource(BuildContext context, String resourceId) async {
    final resource = campusResources
        .where((r) => r.id == resourceId)
        .firstOrNull;
    if (resource == null ||
        resource.actionUrl == null ||
        resource.actionType == null) {
      return;
    }
    final target = resource.actionUrl!;
    if (target.isEmpty) {
      return;
    }
    final uri = Uri.tryParse(target);
    if (uri == null) {
      return;
    }
    await const ExternalUrlLauncher().open(uri);
  }
}
