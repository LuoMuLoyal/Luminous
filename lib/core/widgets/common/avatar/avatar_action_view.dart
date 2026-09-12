import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/avatar/avatar_view.dart';
import 'package:luminous/core/widgets/common/avatar/avatar_viewer.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Avatar display with the existing edit-corner affordance.
///
/// The callbacks are supplied by the owner so this widget remains independent
/// from account state and from the future picker/upload implementation.
class AvatarActionView extends StatelessWidget {
  const AvatarActionView({
    super.key,
    this.avatarUrl,
    this.bytes,
    this.size = 64,
    this.iconSize = 32,
    this.onEdit,
    this.showEditBadge = true,
  });

  final String? avatarUrl;
  final Uint8List? bytes;
  final double size;
  final double iconSize;
  final VoidCallback? onEdit;
  final bool showEditBadge;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final url = avatarUrl?.trim();
    final canView = bytes != null || (url != null && url.isNotEmpty);

    return Semantics(
      button: canView || onEdit != null,
      label: canView
          ? l10n.profileAvatarViewerLabel
          : l10n.profileAvatarActionsTitle,
      child: GestureDetector(
        onTap: canView
            ? bytes != null
                  ? onEdit
                  : () => showAvatarViewer(context, avatarUrl: url!)
            : onEdit,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AvatarView(
              avatarUrl: avatarUrl,
              bytes: bytes,
              size: size,
              iconSize: iconSize,
              semanticLabel: l10n.profileAvatarLabel,
            ),
            if (showEditBadge && onEdit != null)
              Positioned(
                right: -2,
                bottom: -2,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: SemanticColor.primary.solid(context),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.theme.colors.background,
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(Spacing.xs),
                    child: Icon(
                      SemanticIcons.actionEdit,
                      color: SemanticColor.primary.foreground(context),
                      size: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
