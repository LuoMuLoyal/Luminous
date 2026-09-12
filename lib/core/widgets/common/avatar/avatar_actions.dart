import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/control/divider.dart';
import 'package:luminous/core/widgets/common/dialog/dialog_shell.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// An action selected from the avatar management dialog.
enum AvatarAction { view, camera, gallery, remove }

/// Opens the avatar management dialog.
///
/// A centered dialog rather than a bottom sheet: the actions are few and the
/// dialog keeps them on one flat surface separated by dividers, with no
/// per-option card framing.
///
/// "View avatar" is only offered when there is an avatar to look at; the other
/// three always exist, because the write path must stay reachable with no
/// avatar set.
Future<AvatarAction?> showAvatarActionsDialog(
  BuildContext context, {
  required String? avatarUrl,
}) {
  return showAppDialog<AvatarAction>(
    context: context,
    scrollable: false,
    builder: (context) =>
        _AvatarActionsDialog(hasAvatar: avatarUrl?.trim().isNotEmpty == true),
  );
}

class _AvatarActionsDialog extends StatelessWidget {
  const _AvatarActionsDialog({required this.hasAvatar});

  final bool hasAvatar;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final actions = <Widget>[
      if (hasAvatar)
        _AvatarActionRow(
          key: const Key('avatar-action-view'),
          icon: SemanticIcons.actionSearch,
          title: l10n.profileAvatarView,
          onPress: () => Navigator.of(context).pop(AvatarAction.view),
        ),
      // Camera stays available on Web too: `image_picker_for_web` maps
      // ImageSource.camera onto the file input's `capture` attribute, which
      // mobile browsers honour and desktop browsers degrade to a file picker.
      // Hiding it would leave Web users with no way to shoot an avatar.
      _AvatarActionRow(
        key: const Key('avatar-action-camera'),
        icon: SemanticIcons.actionCamera,
        title: l10n.profileAvatarTakePhoto,
        onPress: () => Navigator.of(context).pop(AvatarAction.camera),
      ),
      _AvatarActionRow(
        key: const Key('avatar-action-gallery'),
        icon: SemanticIcons.actionImage,
        title: l10n.profileAvatarChooseFromGallery,
        onPress: () => Navigator.of(context).pop(AvatarAction.gallery),
      ),
      _AvatarActionRow(
        key: const Key('avatar-action-remove'),
        icon: SemanticIcons.actionDelete,
        color: SemanticColor.destructive,
        title: l10n.profileAvatarRemove,
        onPress: () => Navigator.of(context).pop(AvatarAction.remove),
      ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.profileAvatarActionsTitle,
          textAlign: TextAlign.center,
          style: context.theme.typography.body.lg.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: Spacing.lg),
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) const AppDivider(),
          actions[i],
        ],
      ],
    );
  }
}

class _AvatarActionRow extends StatelessWidget {
  const _AvatarActionRow({
    super.key,
    required this.icon,
    required this.title,
    required this.onPress,
    this.color = SemanticColor.primary,
  });

  final IconData icon;
  final String title;
  final VoidCallback onPress;
  final SemanticColor color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm,
          vertical: Spacing.lg,
        ),
        child: Row(
          children: [
            Icon(icon, size: IconSizeTokens.lg, color: color.solid(context)),
            const SizedBox(width: Spacing.lg),
            Expanded(
              child: Text(title, style: context.theme.typography.body.md),
            ),
          ],
        ),
      ),
    );
  }
}
