import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';

// ---------------------------------------------------------------------------
// Mobile layout — unchanged single-column centered form.
// ---------------------------------------------------------------------------
class MobileAuthShell extends StatelessWidget {
  const MobileAuthShell({
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
    final width = MediaQuery.sizeOf(context).width;
    final layout = LayoutScaleResolver.resolve(width);

    return FScaffold(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: layout.pageHorizontalPadding,
            vertical: width < Breakpoints.mobile ? Spacing.xl : Spacing.xl2,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: Breakpoints.assistantContent,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AuthPageHeader(
                    title: title,
                    leading: leading,
                    centerTitle: centerTitle,
                    logo: logo,
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
    );
  }
}

class AuthPageHeader extends StatelessWidget {
  const AuthPageHeader({
    super.key,
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
            width: Spacing.xl4,
            child: leading == null
                ? null
                : Align(alignment: Alignment.centerLeft, child: leading),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: centerTitle ? TextAlign.center : TextAlign.left,
              style: typography.body.xl.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: Spacing.xl4),
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
          const SizedBox(height: Spacing.lg),
        ],
        Text(
          title,
          textAlign: TextAlign.center,
          style: typography.body.xl.copyWith(fontWeight: FontWeight.w700),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: Spacing.sm),
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

/// The auth form card.
///
/// Deliberately carries no entrance animation: the route transition already
/// brings the page in, and a second opacity/offset ramp on top of it both
/// delayed the visible appearance (the two ramps multiplied) and read as the
/// card drifting upwards.
class AuthFormPanel extends StatelessWidget {
  const AuthFormPanel({super.key, required this.form});

  final Widget form;

  @override
  Widget build(BuildContext context) {
    return FCard(
      child: Padding(padding: const EdgeInsets.all(Spacing.xl2), child: form),
    );
  }
}
