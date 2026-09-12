import 'package:flutter/material.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/avatar/avatar_view.dart';
import 'package:luminous/core/widgets/common/dialog/dialog_shell.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Shows an avatar in a focused, pannable surface without changing account data.
Future<void> showAvatarViewer(
  BuildContext context, {
  required String avatarUrl,
}) {
  final isDesktop = MediaQuery.sizeOf(context).width >= Breakpoints.desktop;
  final content = AvatarViewer(avatarUrl: avatarUrl);

  if (isDesktop) {
    return showAppDialog<void>(
      context: context,
      maxWidth: LayoutScaleResolver.dialogStandardMaxWidth,
      scrollable: false,
      builder: (_) => content,
    );
  }

  return showDialog<void>(
    context: context,
    barrierColor: Colors.black87,
    builder: (_) => content,
  );
}

class AvatarViewer extends StatelessWidget {
  const AvatarViewer({super.key, required this.avatarUrl});

  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      label: l10n.profileAvatarViewerLabel,
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          SizedBox(
            width: double.infinity,
            height: 420,
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 4,
              child: AvatarView(
                avatarUrl: avatarUrl,
                size: 280,
                iconSize: 96,
                semanticLabel: l10n.profileAvatarViewerLabel,
                borderWidth: 0,
              ),
            ),
          ),
          IconButton(
            tooltip: l10n.commonClose,
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(SemanticIcons.actionClose),
          ),
        ],
      ),
    );
  }
}
