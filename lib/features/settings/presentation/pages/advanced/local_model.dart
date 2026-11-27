import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/control/settings/tile_group.dart';
import 'package:luminous/core/widgets/common/feedback/skeleton.dart';
import 'package:luminous/core/widgets/common/feedback/state_message.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/settings/presentation/providers/local_model/picker.dart';
import 'package:luminous/features/settings/presentation/utils/page_padding.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

/// Lets the user choose which on-device model the assistant runs.
///
/// ## Why models that do not fit are shown disabled, not omitted
///
/// A 2.3 GB model on a 4 GB phone is not "slower" — the OS kills the process after
/// the download has already been paid for. So those rows appear disabled with the
/// reason: a user who wonders why the big model is greyed out gets an answer instead
/// of a shorter list they cannot explain.
class LocalModelPage extends ConsumerWidget {
  const LocalModelPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final stateAsync = ref.watch(modelPickerControllerProvider);

    return PageScaffold(
      title: l10n.settingsLocalModelTitle,
      child: switch (stateAsync) {
        AsyncError(:final error) => StateErrorView(
          title: l10n.settingsLocalModelUnavailable,
          description: '$error',
          icon: SemanticIcons.statusWarning,
          tone: StateTone.danger,
        ),
        AsyncData(:final value) when value.loading => const _Loading(),
        AsyncData(:final value) => _Body(state: value),
        _ => const _Loading(),
      },
    );
  }
}

/// Skeleton while the listing is prepared.
///
/// Row-shaped blocks rather than a spinner: the content that arrives is a list of
/// tiles, so the placeholder should have the same shape as what replaces it.
class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const StateSkeletonView(
      blocks: <StateSkeletonBlock>[
        StateSkeletonBlock(height: 64),
        StateSkeletonBlock(height: 64),
        StateSkeletonBlock(height: 64),
        StateSkeletonBlock(height: 64),
      ],
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state});

  final ModelPickerState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      child: ResponsiveContentFrame(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: settingsPageVerticalPadding(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: Spacing.sm,
                  right: Spacing.sm,
                  bottom: Spacing.lg,
                ),
                child: Text(
                  l10n.settingsLocalModelDescription,
                  style: context.theme.typography.body.xs.copyWith(
                    color: SemanticColor.neutral.solid(context),
                  ),
                ),
              ),
              for (final choice in state.choices)
                Padding(
                  padding: const EdgeInsets.only(bottom: Spacing.sm),
                  child: _ModelRow(choice: choice, state: state),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModelRow extends ConsumerWidget {
  const _ModelRow({required this.choice, required this.state});

  final ModelChoice choice;
  final ModelPickerState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final controller = ref.read(modelPickerControllerProvider.notifier);
    final busy = state.isBusy(choice.source.id);
    final downloading = state.downloadingId == choice.source.id;
    final progress = downloading ? state.downloadProgress : null;

    // Selectable only when it can actually be used: a resolvable file, and a device
    // that can hold it.
    final actionable = choice.isUsable && choice.fitsDevice && !busy;

    Future<void> onPress() async {
      if (choice.downloaded) {
        await controller.select(choice.source);
      } else {
        await controller.download(choice.source);
      }
    }

    return FTileGroup(
      style: settingsTileGroup(context.theme),
      children: [
        FTile(
          title: Text(choice.source.name),
          subtitle: Text(_subtitle(l10n, choice, progress)),
          suffix: _Suffix(
            choice: choice,
            busy: busy,
            progress: progress,
            onDownload: actionable && !choice.downloaded
                ? () => controller.download(choice.source)
                : null,
            onSelect: actionable && choice.downloaded
                ? () => controller.select(choice.source)
                : null,
            onRemove: choice.downloaded && !choice.selected
                ? () => controller.remove(choice.source)
                : null,
          ),
          // Pressing the row does the next sensible thing: download when missing,
          // otherwise select.
          onPress: actionable ? onPress : null,
        ),
      ],
    );
  }

  String _subtitle(
    AppLocalizations l10n,
    ModelChoice choice,
    double? progress,
  ) {
    final model = choice.model;
    if (model == null) return l10n.settingsLocalModelUnavailable;
    if (progress != null) {
      return '${l10n.settingsLocalModelDownloading} '
          '${(progress * 100).round()}%';
    }
    if (!choice.fitsDevice) {
      return l10n.settingsLocalModelTooLarge(model.minDeviceMemoryGb);
    }
    final details = '${model.sizeLabel} · ${model.note}';
    if (choice.selected) return '${l10n.settingsLocalModelInUse} · $details';
    if (choice.downloaded) {
      return '${l10n.settingsLocalModelReady} · $details';
    }
    return details;
  }
}

/// The trailing control for one row.
///
/// Extracted because the branch order is the whole point and it is worth naming:
/// busy → selected → removable → actionable. Getting that order wrong shows a
/// "Download" button on a row that is already downloading.
class _Suffix extends StatelessWidget {
  const _Suffix({
    required this.choice,
    required this.busy,
    required this.progress,
    required this.onDownload,
    required this.onSelect,
    required this.onRemove,
  });

  final ModelChoice choice;
  final bool busy;
  final double? progress;
  final VoidCallback? onDownload;
  final VoidCallback? onSelect;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (busy) {
      // Determinate while downloading, indeterminate while loading the model into
      // memory; the bar itself tells the user which phase they are in.
      return SizedBox(
        width: IconSizeTokens.lg,
        child: LinearProgressIndicator(value: progress, minHeight: 2),
      );
    }
    if (choice.selected) {
      return Icon(
        SemanticIcons.statusDone,
        size: IconSizeTokens.sm,
        color: SemanticColor.primary.solid(context),
      );
    }
    if (onRemove != null) {
      return FButton(
        variant: FButtonVariant.ghost,
        onPress: onRemove,
        child: Text(l10n.settingsLocalModelRemove),
      );
    }
    if (onSelect != null) {
      return FButton(
        variant: FButtonVariant.outline,
        onPress: onSelect,
        child: Text(l10n.settingsLocalModelUse),
      );
    }
    if (onDownload != null) {
      return FButton(
        variant: FButtonVariant.outline,
        onPress: onDownload,
        child: Text(l10n.settingsLocalModelDownload),
      );
    }
    return const SizedBox.shrink();
  }
}
