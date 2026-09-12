import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/avatar/avatar_view.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Avatar display with the edit-corner affordance.
///
/// The whole avatar — body and corner badge — opens the owner's management
/// surface via [onEdit]. The body has no separate action: everything the user
/// can do with the avatar (view it full-screen, replace it, remove it) is an
/// entry in that surface, so a tap can never be ambiguous.
///
/// The widget holds no account state; the picker, crop and upload live in the
/// owner.
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

  /// Opens the avatar management surface (the actions sheet).
  final VoidCallback? onEdit;
  final bool showEditBadge;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final url = avatarUrl?.trim();
    final hasAvatar = bytes != null || (url != null && url.isNotEmpty);

    return Semantics(
      button: onEdit != null,
      label: hasAvatar
          ? l10n.profileAvatarViewerLabel
          : l10n.profileAvatarActionsTitle,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AvatarView(
            avatarUrl: avatarUrl,
            bytes: bytes,
            size: size,
            iconSize: iconSize,
            semanticLabel: l10n.profileAvatarLabel,
            onTap: onEdit,
          ),
          if (showEditBadge && onEdit != null)
            Positioned(
              right: -2,
              bottom: -2,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onEdit,
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
            ),
        ],
      ),
    );
  }
}
