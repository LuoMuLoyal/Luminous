import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';

class PageScaffoldShell extends StatelessWidget {
  const PageScaffoldShell({
    super.key,
    required this.title,
    this.description,
    this.actions,
    this.leading,
    this.centerTitle = false,
    required this.children,
    this.scrollable = true,
    this.floatingActionButton,
    this.drawer,
    this.endDrawer,
    this.scaffoldKey,
  });

  final String title;
  final String? description;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final List<Widget> children;
  final bool scrollable;
  final Widget? floatingActionButton;
  final Widget? drawer;
  final Widget? endDrawer;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;
    final useNestedHeader =
        leading != null || (centerTitle && description == null);
    final titleWidget = _PageHeaderTitle(
      title: title,
      description: description,
      centered: centerTitle && description == null,
      titleStyle: useNestedHeader
          ? textTheme.titleLarge
          : textTheme.headlineSmall,
      descriptionStyle: textTheme.bodyMedium?.copyWith(
        color: colors.mutedForeground,
      ),
    );

    final header = useNestedHeader
        ? FHeader.nested(
            title: titleWidget,
            titleAlignment: centerTitle && description == null
                ? Alignment.center
                : Alignment.centerLeft,
            prefixes: leading == null ? const [] : <Widget>[leading!],
            suffixes: actions ?? const [],
          )
        : FHeader(title: titleWidget, suffixes: actions ?? const []);

    final content = ResponsiveContentFrame(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: width < AppBreakpoints.mobile ? 24 : 32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );

    final pageContent = SafeArea(
      top: false,
      child: scrollable ? SingleChildScrollView(child: content) : content,
    );

    final materialPageContent = Material(
      color: Colors.transparent,
      child: pageContent,
    );

    final scaffoldBody = floatingActionButton == null
        ? materialPageContent
        : Stack(
            children: [
              Positioned.fill(child: materialPageContent),
              Positioned(
                right: 24,
                bottom: 24 + MediaQuery.paddingOf(context).bottom,
                child: floatingActionButton!,
              ),
            ],
          );

    final scaffold = FScaffold(
      childPad: false,
      header: SafeArea(bottom: false, child: header),
      child: scaffoldBody,
    );

    if (drawer != null || endDrawer != null) {
      return Scaffold(
        key: scaffoldKey,
        backgroundColor: colors.background,
        body: scaffold,
        drawer: drawer,
        endDrawer: endDrawer,
      );
    }

    return scaffold;
  }
}

class PageSectionCard extends StatelessWidget {
  const PageSectionCard({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.child,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;

    return FCard.raw(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: textTheme.titleLarge),
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          subtitle!,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colors.mutedForeground,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}

class _PageHeaderTitle extends StatelessWidget {
  const _PageHeaderTitle({
    required this.title,
    required this.description,
    required this.centered,
    required this.titleStyle,
    required this.descriptionStyle,
  });

  final String title;
  final String? description;
  final bool centered;
  final TextStyle? titleStyle;
  final TextStyle? descriptionStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          textAlign: centered ? TextAlign.center : TextAlign.start,
          style: titleStyle,
        ),
        if (description != null && description!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            description!,
            textAlign: centered ? TextAlign.center : TextAlign.start,
            style: descriptionStyle,
          ),
        ],
      ],
    );
  }
}
