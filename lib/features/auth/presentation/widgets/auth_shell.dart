import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';

export 'auth_action_row.dart';

export 'auth_branding.dart';
export 'auth_field_error.dart';
export 'auth_status_message.dart';
export 'auth_text_field.dart';

class AuthShell extends StatelessWidget {
  const AuthShell({
    super.key,
    required this.title,
    required this.form,
    this.enableFormAnimation = true,
    this.leading,
    this.centerTitle = false,
    this.logo,
    this.subtitle,
  });

  final String title;
  final Widget form;
  final bool enableFormAnimation;
  final Widget? leading;
  final bool centerTitle;
  final Widget? logo;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;
    final width = MediaQuery.sizeOf(context).width;
    final layout = AppLayoutTokens.resolve(width);

    return Scaffold(
      backgroundColor: colors.secondary.withValues(alpha: 0.32),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              colors.background,
              colors.secondary.withValues(alpha: 0.55),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: layout.pageHorizontalPadding,
              vertical: width < AppBreakpoints.mobile
                  ? AppSpacingTokens.lg
                  : AppSpacingTokens.xl,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: layout.maxContentWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _AuthPageHeader(
                      title: title,
                      leading: leading,
                      centerTitle: centerTitle,
                      textTheme: textTheme,
                      colors: colors,
                      logo: logo,
                      subtitle: subtitle,
                    ),
                    const SizedBox(height: AppSpacingTokens.lg),
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
    );
  }
}

class _AuthPageHeader extends StatelessWidget {
  const _AuthPageHeader({
    required this.title,
    required this.leading,
    required this.centerTitle,
    required this.textTheme,
    required this.colors,
    this.logo,
    this.subtitle,
  });

  final String title;
  final Widget? leading;
  final bool centerTitle;
  final TextTheme textTheme;
  final FColors colors;
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
          const SizedBox(height: AppSpacingTokens.md),
        ],
        Text(
          title,
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacingTokens.xs),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(color: colors.mutedForeground),
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
        padding: const EdgeInsets.all(AppSpacingTokens.lg),
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
        padding: const EdgeInsets.all(AppSpacingTokens.xl),
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
