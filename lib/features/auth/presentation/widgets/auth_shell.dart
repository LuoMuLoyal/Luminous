import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';

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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final surface = theme.extension<AppThemeSurface>()!;
    final width = MediaQuery.sizeOf(context).width;
    final layout = AppLayoutTokens.resolve(width);
    final typography = width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(scheme.onSurface)
        : AppTypographyTokens.desktop(scheme.onSurface);

    return Scaffold(
      backgroundColor: surface.canvasSoft,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[AppColorTokens.canvas, surface.canvasSoft],
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
                      typography: typography,
                      logo: logo,
                      subtitle: subtitle,
                    ),
                    const SizedBox(height: AppSpacingTokens.lg),
                    _AuthFormPanel(
                      form: form,
                      surface: surface,
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
    required this.typography,
    this.logo,
    this.subtitle,
  });

  final String title;
  final Widget? leading;
  final bool centerTitle;
  final AppTypographyScale typography;
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
              style: typography.displaySm,
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
        Text(title, textAlign: TextAlign.center, style: typography.displaySm),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacingTokens.xs),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: typography.bodySm.copyWith(
              color: Theme.of(context).extension<AppThemeSurface>()!.mute,
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
    final surface = Theme.of(context).extension<AppThemeSurface>()!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface.canvasSoft,
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        border: Border.all(color: surface.hairline),
        boxShadow: AppShadowTokens.level1,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.lg),
        child: child,
      ),
    );
  }
}

class _AuthFormPanel extends StatelessWidget {
  const _AuthFormPanel({
    required this.form,
    required this.surface,
    required this.enableAnimation,
  });

  final Widget form;
  final AppThemeSurface surface;
  final bool enableAnimation;

  @override
  Widget build(BuildContext context) {
    final panel = DecoratedBox(
      decoration: BoxDecoration(
        color: surface.canvas,
        borderRadius: BorderRadius.circular(AppRadiusTokens.xl),
        border: Border.all(color: surface.hairline),
        boxShadow: AppShadowTokens.level4,
      ),
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
