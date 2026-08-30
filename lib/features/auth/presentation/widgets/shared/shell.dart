import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/l10n/app_localizations.dart';

class AuthShell extends StatelessWidget {
  const AuthShell({
    super.key,
    required this.title,
    required this.form,
    this.formModeSelector,
    this.enableFormAnimation = true,
    this.leading,
    this.centerTitle = false,
    this.logo,
    this.subtitle,
  });

  final String title;
  final Widget form;
  final Widget? formModeSelector;
  final bool enableFormAnimation;
  final Widget? leading;
  final bool centerTitle;
  final Widget? logo;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= Breakpoints.desktop;

    if (isDesktop) {
      return _DesktopAuthShell(
        title: title,
        subtitle: subtitle,
        logo: logo,
        leading: leading,
        centerTitle: centerTitle,
        formModeSelector: formModeSelector,
        form: form,
        enableFormAnimation: enableFormAnimation,
      );
    }

    return _MobileAuthShell(
      title: title,
      subtitle: subtitle,
      logo: logo,
      leading: leading,
      centerTitle: centerTitle,
      formModeSelector: formModeSelector,
      form: form,
      enableFormAnimation: enableFormAnimation,
    );
  }
}

// ---------------------------------------------------------------------------
// Desktop layout — split: left brand panel + right form.
// ---------------------------------------------------------------------------
class _DesktopAuthShell extends StatelessWidget {
  const _DesktopAuthShell({
    required this.title,
    required this.form,
    this.formModeSelector,
    this.enableFormAnimation = true,
    this.leading,
    this.centerTitle = false,
    this.logo,
    this.subtitle,
  });

  final String title;
  final Widget form;
  final Widget? formModeSelector;
  final bool enableFormAnimation;
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
                    const Expanded(flex: 5, child: _DesktopBrandPanel()),
                    const SizedBox(width: Spacing.level6),
                    Expanded(
                      flex: 4,
                      child: SafeArea(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Spacing.level8,
                            vertical: Spacing.level6,
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 420),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _AuthPageHeader(
                                    title: title,
                                    leading: null,
                                    centerTitle: centerTitle,
                                    logo: null,
                                    subtitle: subtitle,
                                  ),
                                  if (formModeSelector != null) ...[
                                    const SizedBox(height: Spacing.level6),
                                    formModeSelector!,
                                  ],
                                  const SizedBox(height: Spacing.level6),
                                  _AuthFormPanel(
                                    form: form,
                                    enableAnimation: enableFormAnimation,
                                  ),
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
                    padding: const EdgeInsets.all(Spacing.level4),
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
class _DesktopBrandPanel extends StatelessWidget {
  const _DesktopBrandPanel();

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
                      child: Image.asset(
                        'assets/icon/app_icon.png',
                        width: logoSize,
                        height: logoSize,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              // Brand content.
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.level10,
                  vertical: Spacing.level8,
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
                    const SizedBox(height: Spacing.level4),
                    // Description
                    Text(
                      l10n.authBrandDescription,
                      style: context.theme.typography.body.md.copyWith(
                        color: SemanticColor.neutral.solid(context),
                      ),
                    ),
                    const SizedBox(height: Spacing.level9),
                    // Feature list
                    _BrandFeatureItem(
                      icon: SemanticIcons.tabRecord,
                      title: l10n.authBrandFeatureRecords,
                      description: l10n.authBrandFeatureRecordsDesc,
                    ),
                    const SizedBox(height: Spacing.level5),
                    _BrandFeatureItem(
                      icon: SemanticIcons.aiEntry,
                      title: l10n.authBrandFeatureAnalysis,
                      description: l10n.authBrandFeatureAnalysisDesc,
                    ),
                    const SizedBox(height: Spacing.level5),
                    _BrandFeatureItem(
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

class _BrandFeatureItem extends StatelessWidget {
  const _BrandFeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

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
            child: Icon(
              icon,
              color: SemanticColor.primary.solid(context),
              size: IconSizeTokens.level4,
            ),
          ),
        ),
        const SizedBox(width: Spacing.level4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.theme.typography.body.md.copyWith(
                  color: colors.foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: Spacing.level1),
              Text(
                description,
                style: context.theme.typography.body.xs.copyWith(
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

// ---------------------------------------------------------------------------
// Mobile layout — unchanged single-column centered form.
// ---------------------------------------------------------------------------
class _MobileAuthShell extends StatelessWidget {
  const _MobileAuthShell({
    required this.title,
    required this.form,
    this.formModeSelector,
    this.enableFormAnimation = true,
    this.leading,
    this.centerTitle = false,
    this.logo,
    this.subtitle,
  });

  final String title;
  final Widget form;
  final Widget? formModeSelector;
  final bool enableFormAnimation;
  final Widget? leading;
  final bool centerTitle;
  final Widget? logo;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final layout = LayoutScaleResolver.resolve(width);

    return FScaffold(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: layout.pageHorizontalPadding,
            vertical: width < Breakpoints.mobile
                ? Spacing.level5
                : Spacing.level6,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: Breakpoints.assistantContent,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _AuthPageHeader(
                    title: title,
                    leading: leading,
                    centerTitle: centerTitle,
                    logo: logo,
                    subtitle: subtitle,
                  ),
                  if (formModeSelector != null) ...[
                    const SizedBox(height: Spacing.level6),
                    formModeSelector!,
                  ],
                  const SizedBox(height: Spacing.level6),
                  _AuthFormPanel(
                    form: form,
                    enableAnimation: enableFormAnimation,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthPageHeader extends StatelessWidget {
  const _AuthPageHeader({
    required this.title,
    required this.leading,
    required this.centerTitle,
    this.logo,
    this.subtitle,
  });

  final String title;
  final Widget? leading;
  final bool centerTitle;
  final Widget? logo;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;

    if (logo == null && subtitle == null) {
      return Row(
        children: [
          SizedBox(
            width: Spacing.level8,
            child: leading == null
                ? null
                : Align(alignment: Alignment.centerLeft, child: leading),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: centerTitle ? TextAlign.center : TextAlign.left,
              style: context.theme.typography.body.xl.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: Spacing.level8),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (leading != null)
          Align(alignment: Alignment.centerLeft, child: leading),
        if (logo != null) ...[
          Center(child: logo),
          const SizedBox(height: Spacing.level4),
        ],
        Text(
          title,
          textAlign: TextAlign.center,
          style: context.theme.typography.body.xl.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: Spacing.level2),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: typography.body.md.copyWith(
              color: SemanticColor.neutral.solid(context),
            ),
          ),
        ],
      ],
    );
  }
}

class _AuthFormPanel extends StatelessWidget {
  const _AuthFormPanel({required this.form, required this.enableAnimation});

  final Widget form;
  final bool enableAnimation;

  @override
  Widget build(BuildContext context) {
    final panel = FCard(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level6),
        child: form,
      ),
    );

    if (!enableAnimation) {
      return panel;
    }

    return panel
        .animate()
        .fadeIn(
          duration: DurationTokens.authContentFadeIn,
          curve: MotionTokens.snappy,
        )
        .slideY(
          begin: 0.03,
          end: 0,
          duration: DurationTokens.authContentFadeIn,
          curve: MotionTokens.entrance,
        );
  }
}
