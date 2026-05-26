import 'package:flutter/material.dart';
import 'package:luminous/shared/widgets/app_surface.dart';
import 'package:luminous/shared/widgets/tinted_status_chip.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 安全辅助页统一使用的白色 section 卡片。
class SafetySectionCard extends StatelessWidget {
  const SafetySectionCard({
    super.key,
    required this.title,
    required this.child,
    required this.accentColor,
    required this.secondaryColor,
    required this.ornamentKey,
    this.titleFontSize = 15.5,
  });

  final String title;
  final Widget child;
  final Color accentColor;
  final Color secondaryColor;
  final String ornamentKey;
  final double titleFontSize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppSectionCard(
      accentColor: accentColor,
      secondaryColor: secondaryColor,
      ornamentKey: ornamentKey,
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
      radius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

/// AI 结果条目卡片。
class SafetyAiResultEntryCard extends StatelessWidget {
  const SafetyAiResultEntryCard({super.key, required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = Color.lerp(scheme.primary, scheme.secondary, 0.34)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: appTintedSurface(
          context,
          accent,
          lightAlpha: 0.06,
          darkAlpha: 0.12,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: appTintedBorder(
            context,
            accent,
            lightAlpha: 0.14,
            darkAlpha: 0.24,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 1),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
            ),
            alignment: Alignment.center,
            child: Text(
              '$index',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: accent,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.6,
                height: 1.6,
                color: Color.lerp(
                  scheme.onSurfaceVariant,
                  scheme.onSurface,
                  0.34,
                ),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 免责声明卡片。
class SafetyDisclaimerCard extends StatelessWidget {
  const SafetyDisclaimerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafetySectionCard(
      title: l10n?.safetyDisclaimerTitle ?? 'Safety Notice',
      accentColor: Theme.of(context).colorScheme.tertiary,
      secondaryColor: Theme.of(context).colorScheme.secondary,
      ornamentKey: 'safety.disclaimer',
      child: Text(
        l10n?.safetyDisclaimerText ??
            'This feature uses AI-generated content for health education and reference only, '
                'and cannot replace a doctor\'s diagnosis or prescription. '
                'If you feel unwell or are taking medication, follow medical advice and consult professionals.',
        style: TextStyle(
          fontSize: 12.5,
          height: 1.55,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Hero 区域的信息 chip。
class SafetyInfoChip extends StatelessWidget {
  const SafetyInfoChip({
    super.key,
    required this.icon,
    required this.text,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final IconData icon;
  final String text;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return TintedStatusChip(
      icon: icon,
      text: text,
      color: foregroundColor,
      backgroundColor: backgroundColor,
      showBorder: false,
      iconSize: 14,
      fontSize: 11.2,
      fontWeight: FontWeight.w700,
      textMaxLines: 1,
      textOverflow: TextOverflow.ellipsis,
      expandText: true,
      mainAxisSize: MainAxisSize.max,
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
    );
  }
}

/// 查询模式切换器（单选/双药）。
class SafetyModeSwitcher extends StatelessWidget {
  const SafetyModeSwitcher({
    super.key,
    required this.mode,
    required this.l10n,
    required this.onSelectSingle,
    required this.onSelectPair,
  });

  final String mode;
  final AppLocalizations? l10n;
  final VoidCallback onSelectSingle;
  final VoidCallback onSelectPair;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final singleColor = scheme.primary;
    final pairColor = Color.lerp(scheme.secondary, scheme.tertiary, 0.42)!;

    return Row(
      children: [
        Expanded(
          child: SafetyModeOption(
            label: l10n?.safetyModeSingle ?? 'Single-medicine guidance',
            icon: Icons.medication_rounded,
            color: singleColor,
            selected: mode == 'single',
            onTap: onSelectSingle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SafetyModeOption(
            label: l10n?.safetyModePair ?? 'Two-medicine interaction',
            icon: Icons.compare_arrows_rounded,
            color: pairColor,
            selected: mode == 'pair',
            onTap: onSelectPair,
          ),
        ),
      ],
    );
  }
}

/// 单个模式选项卡片。
class SafetyModeOption extends StatelessWidget {
  const SafetyModeOption({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
          decoration: BoxDecoration(
            color: selected
                ? appTintedSurface(
                    context,
                    color,
                    lightAlpha: 0.12,
                    darkAlpha: 0.20,
                  )
                : theme.cardColor.withValues(alpha: 0.44),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? appTintedBorder(
                      context,
                      color,
                      lightAlpha: 0.24,
                      darkAlpha: 0.34,
                    )
                  : scheme.outline,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.12),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : const [],
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.8,
                    fontWeight: FontWeight.w800,
                    color: selected ? color : scheme.onSurface,
                    height: 1.15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
