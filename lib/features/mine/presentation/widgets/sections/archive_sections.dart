import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/health_context/domain/services/unit_conversion.dart';
import 'package:luminous/features/mine/domain/entities/dashboard.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Structured empty state shown when the archive has no signed-in data yet.
class ArchiveEmpty extends StatelessWidget {
  const ArchiveEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typography = context.theme.typography;
    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level4),
        child: Row(
          children: [
            FAvatar.raw(
              size: Spacing.level8,
              child: Icon(
                SemanticIcons.recordClipboard,
                color: SemanticColor.primary.solid(context),
                size: Spacing.level5,
              ),
            ),
            const SizedBox(width: Spacing.level4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.mineArchiveEmptyTitle,
                    style: typography.body.sm.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: Spacing.level1),
                  Text(
                    l10n.mineArchiveEmptyDescription,
                    style: typography.body.xs.copyWith(
                      color: SemanticColor.neutral.solid(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Builds the profile summary line for the basic-archive subtitle, joining
/// age / height / weight with the locale separator (「 · 」), falling back to
/// the basic-archive subtitle copy when no value is set.
String buildArchiveProfileMeta(
  AppLocalizations l10n,
  MineProfileSnapshot profile,
) {
  final parts = <String>[
    if (profile.age != null) l10n.mineProfileAgeYears(profile.age!),
    if (profile.heightCm != null)
      l10n.mineProfileHeightCm(profile.heightCm?.round() ?? 0),
    if (profile.weightKg != null)
      isImperialUnitSystem(profile.unitSystem)
          ? l10n.mineProfileWeightLb(weightInLb(profile.weightKg)?.round() ?? 0)
          : l10n.mineProfileWeightKg(profile.weightKg?.round() ?? 0),
  ];
  if (parts.isEmpty) return l10n.mineArchiveBasicSubtitle;
  return parts.join(' · ');
}
