import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/control/brand_icon.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/mobile_shell.dart';
import 'package:luminous/l10n/app_localizations.dart';

// ---------------------------------------------------------------------------
// Desktop layout — split: left brand panel + right form.
// ---------------------------------------------------------------------------
class DesktopAuthShell extends StatelessWidget {
  const DesktopAuthShell({
    super.key,
    required this.title,
    required this.form,
    this.formModeSelector,
    this.leading,
    this.centerTitle = false,
    this.logo,
    this.subtitle,
  });

  final String title;
  final Widget form;
  final Widget? formModeSelector;
  final Widget? leading;
  final bool centerTitle;
  final Widget? logo;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return FScaffold(
      childPad: false,
      child: ColoredBox(
        color: colors.background,
        child: Stack(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1280),
                child: Row(
                  children: [
                    const Expanded(flex: 5, child: DesktopBrandPanel()),
                    const SizedBox(width: Spacing.xl2),
                    Expanded(
                      flex: 4,
                      child: SafeArea(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Spacing.xl4,
                            vertical: Spacing.xl2,
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 420),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  AuthPageHeader(
                                    title: title,
                                    leading: null,
                                    centerTitle: centerTitle,
                                    logo: null,
                                    subtitle: subtitle,
                                  ),
                                  if (formModeSelector != null) ...[
                                    const SizedBox(height: Spacing.xl2),
                                    formModeSelector!,
                                  ],
                                  const SizedBox(height: Spacing.xl2),
                                  AuthFormPanel(form: form),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (leading != null)
              Positioned(
                top: 0,
                left: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(Spacing.lg),
                    child: leading,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Desktop brand panel — gradient background + logo + tagline + features.
// ---------------------------------------------------------------------------
class DesktopBrandPanel extends StatelessWidget {
  const DesktopBrandPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final logoSize = constraints.maxWidth * 1.4;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Faded logo watermark — adaptive size, centered behind text.
              // OverflowBox bypasses Align's loose constraints so the image
              // can render larger than the Stack's own bounds.
              Positioned.fill(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: OverflowBox(
                    maxWidth: logoSize,
                    maxHeight: logoSize,
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        colors.foreground.withValues(alpha: 0.03),
                        BlendMode.srcIn,
                      ),
                      child: BrandIcon(size: logoSize),
                    ),
                  ),
                ),
              ),
              // Brand content.
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.xl6,
                  vertical: Spacing.xl4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Tagline
                    Text(
                      l10n.authBrandTagline,
                      style: context.theme.typography.display.xl3.copyWith(
                        color: colors.foreground,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: Spacing.lg),
                    // Description
                    Text(
                      l10n.authBrandDescription,
                      style: context.theme.typography.body.md.copyWith(
                        color: SemanticColor.neutral.solid(context),
                      ),
                    ),
                    const SizedBox(height: Spacing.xl5),
                    // Feature list
                    BrandFeatureItem(
                      icon: SemanticIcons.tabRecord,
                      title: l10n.authBrandFeatureRecords,
                      description: l10n.authBrandFeatureRecordsDesc,
                    ),
                    const SizedBox(height: Spacing.xl),
                    BrandFeatureItem(
                      icon: SemanticIcons.aiEntry,
                      svgIcon: SemanticIconSvg.aiEntry(
                        size: IconSizeTokens.lg,
                        color: SemanticColor.primary.solid(context),
                      ),
                      title: l10n.authBrandFeatureAnalysis,
                      description: l10n.authBrandFeatureAnalysisDesc,
                    ),
                    const SizedBox(height: Spacing.xl),
                    BrandFeatureItem(
                      icon: SemanticIcons.safetySafe,
                      title: l10n.authBrandFeaturePrivacy,
                      description: l10n.authBrandFeaturePrivacyDesc,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class BrandFeatureItem extends StatelessWidget {
  const BrandFeatureItem({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.svgIcon,
  });

  final IconData icon;
  final String title;
  final String description;

  /// Optional SVG glyph (iconMind AI 语义图标) shown instead of [icon] when
  /// set — the AI analysis feature carries the AI icon.
  final Widget? svgIcon;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: SemanticColor.primary.subtle(context),
            borderRadius: context.theme.style.borderRadius.md,
          ),
          child: Center(
            child:
                svgIcon ??
                Icon(
                  icon,
                  color: SemanticColor.primary.solid(context),
                  size: IconSizeTokens.lg,
                ),
          ),
        ),
        const SizedBox(width: Spacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: typography.body.md.copyWith(
                  color: colors.foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                description,
                style: typography.body.xs.copyWith(
                  color: SemanticColor.neutral.solid(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
