import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';

export 'auth_branding.dart';

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
    final textTheme = Theme.of(context).textTheme;
    final width = MediaQuery.sizeOf(context).width;
    final layout = AppLayoutTokens.resolve(width);

    return FScaffold(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: layout.pageHorizontalPadding,
            vertical: width < AppBreakpoints.mobile
                ? AppSpacingTokens.level5
                : AppSpacingTokens.level6,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _AuthPageHeader(
                    title: title,
                    leading: leading,
                    centerTitle: centerTitle,
                    textTheme: textTheme,
                    logo: logo,
                    subtitle: subtitle,
                  ),
                  if (formModeSelector != null) ...[
                    const SizedBox(height: AppSpacingTokens.level6),
                    formModeSelector!,
                  ],
                  const SizedBox(height: AppSpacingTokens.level6),
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
    required this.textTheme,
    this.logo,
    this.subtitle,
  });

  final String title;
  final Widget? leading;
  final bool centerTitle;
  final TextTheme textTheme;
  final Widget? logo;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    if (logo == null && subtitle == null) {
      return Row(
        children: [
          SizedBox(
            width: 48,
            child: leading == null
                ? null
                : Align(alignment: Alignment.centerLeft, child: leading),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: centerTitle ? TextAlign.center : TextAlign.left,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 48),
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
          const SizedBox(height: AppSpacingTokens.level4),
        ],
        Text(
          title,
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacingTokens.level2),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: context.theme.colors.mutedForeground,
            ),
          ),
        ],
      ],
    );
  }
}

class AuthSectionCard extends StatelessWidget {
  const AuthSectionCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FCard.raw(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.level5),
        child: child,
      ),
    );
  }
}

class _AuthFormPanel extends StatelessWidget {
  const _AuthFormPanel({required this.form, required this.enableAnimation});

  final Widget form;
  final bool enableAnimation;

  @override
  Widget build(BuildContext context) {
    final panel = FCard.raw(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.level6),
        child: form,
      ),
    );

    if (!enableAnimation) {
      return panel;
    }

    return panel
        .animate()
        .fadeIn(duration: 180.ms, curve: Curves.easeOut)
        .slideY(
          begin: 0.03,
          end: 0,
          duration: 180.ms,
          curve: Curves.easeOutCubic,
        );
  }
}
