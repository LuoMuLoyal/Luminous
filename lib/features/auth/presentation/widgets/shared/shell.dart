import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';

export 'branding.dart';

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
              style: TypographyToken.level7
                  .body(context)
                  .copyWith(fontWeight: FontWeight.w700),
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
          style: TypographyToken.level7
              .body(context)
              .copyWith(fontWeight: FontWeight.w700),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: Spacing.level2),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: typography.body.md.copyWith(
              color: context.theme.colors.mutedForeground,
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
          curve: Curves.easeOut,
        )
        .slideY(
          begin: 0.03,
          end: 0,
          duration: DurationTokens.authContentFadeIn,
          curve: Curves.easeOutCubic,
        );
  }
}
