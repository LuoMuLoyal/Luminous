import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/dialog/dialog_shell.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/settings/presentation/providers/data_storage.dart';
import 'package:luminous/features/settings/presentation/utils/page_padding.dart';
import 'package:luminous/features/settings/presentation/widgets/shared/section_label.dart';
import 'package:luminous/features/settings/presentation/widgets/shared/selection_icon.dart';
import 'package:luminous/features/settings/presentation/widgets/shared/subpage_tile_group_style.dart';
import 'package:luminous/l10n/app_localizations.dart';

class DataStorageSettingsPage extends ConsumerWidget {
  const DataStorageSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settingsAsync = ref.watch(dataStorageSettingsControllerProvider);
    final settings =
        settingsAsync.asData?.value ?? const DataStorageSettingsState();
    final controller = ref.read(dataStorageSettingsControllerProvider.notifier);

    return PageScaffold(
      title: l10n.settingsDataStorageTitle,
      child: SingleChildScrollView(
        child: ResponsiveContentFrame(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: settingsPageVerticalPadding(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SettingsSectionLabel(
                  label: l10n.settingsDataStorageRetentionSection,
                ),
                const SizedBox(height: Spacing.level3),
                FTileGroup(
                  style: settingsSubpageTileGroupStyle(context.theme),
                  children: [
                    for (final period in DataRetentionPeriod.values)
                      FTile(
                        key: Key('data-retention-row-${period.storageValue}'),
                        title: Text(_retentionLabel(l10n, period)),
                        subtitle: Text(_retentionSubtitle(l10n, period)),
                        suffix: SettingsSelectionIcon(
                          selected: settings.retentionPeriod == period,
                        ),
                        onPress: () async {
                          if (_isShortening(settings.retentionPeriod, period)) {
                            final confirmed = await showDangerConfirmationDialog(
                              context: context,
                              title: l10n
                                  .settingsDataStorageRetentionShortenConfirmTitle,
                              message: l10n
                                  .settingsDataStorageRetentionShortenConfirmMessage,
                              confirmLabel: l10n.commonConfirm,
                            );
                            if (!confirmed) return;
                          }
                          await controller.setRetentionPeriod(period);
                        },
                      ),
                  ],
                ),
                const SizedBox(height: Spacing.level5),
                SettingsSectionLabel(
                  label: l10n.settingsDataStorageImageQualitySection,
                ),
                const SizedBox(height: Spacing.level3),
                FTileGroup(
                  style: settingsSubpageTileGroupStyle(context.theme),
                  children: [
                    for (final quality in ImageQualityPreference.values)
                      FTile(
                        key: Key('image-quality-row-${quality.storageValue}'),
                        title: Text(_imageQualityLabel(l10n, quality)),
                        subtitle: Text(_imageQualitySubtitle(l10n, quality)),
                        suffix: SettingsSelectionIcon(
                          selected: settings.imageQuality == quality,
                        ),
                        onPress: () => controller.setImageQuality(quality),
                      ),
                  ],
                ),
                const SizedBox(height: Spacing.level5),
                SettingsSectionLabel(
                  label: l10n.settingsDataStorageSyncSection,
                ),
                const SizedBox(height: Spacing.level3),
                FTileGroup(
                  style: settingsSubpageTileGroupStyle(context.theme),
                  children: [
                    for (final pref in SyncPreference.values)
                      FTile(
                        key: Key('sync-pref-row-${pref.storageValue}'),
                        title: Text(_syncLabel(l10n, pref)),
                        subtitle: Text(_syncSubtitle(l10n, pref)),
                        suffix: SettingsSelectionIcon(
                          selected: settings.syncPreference == pref,
                        ),
                        onPress: () => controller.setSyncPreference(pref),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Returns true if switching from [current] to [next] shortens the
  /// retention period (i.e. old cached data may be deleted).
  bool _isShortening(DataRetentionPeriod current, DataRetentionPeriod next) {
    if (next == DataRetentionPeriod.forever) return false;
    if (current == DataRetentionPeriod.forever) return true;
    return next.days < current.days;
  }

  String _retentionLabel(AppLocalizations l10n, DataRetentionPeriod period) {
    return switch (period) {
      DataRetentionPeriod.thirtyDays => l10n.settingsDataStorageRetention30Days,
      DataRetentionPeriod.ninetyDays => l10n.settingsDataStorageRetention90Days,
      DataRetentionPeriod.forever => l10n.settingsDataStorageRetentionForever,
    };
  }

  String _retentionSubtitle(AppLocalizations l10n, DataRetentionPeriod period) {
    return switch (period) {
      DataRetentionPeriod.thirtyDays =>
        l10n.settingsDataStorageRetention30DaysSubtitle,
      DataRetentionPeriod.ninetyDays =>
        l10n.settingsDataStorageRetention90DaysSubtitle,
      DataRetentionPeriod.forever =>
        l10n.settingsDataStorageRetentionForeverSubtitle,
    };
  }

  String _imageQualityLabel(
    AppLocalizations l10n,
    ImageQualityPreference quality,
  ) {
    return switch (quality) {
      ImageQualityPreference.standard =>
        l10n.settingsDataStorageImageQualityStandard,
      ImageQualityPreference.dataSaver =>
        l10n.settingsDataStorageImageQualityDataSaver,
    };
  }

  String _imageQualitySubtitle(
    AppLocalizations l10n,
    ImageQualityPreference quality,
  ) {
    return switch (quality) {
      ImageQualityPreference.standard =>
        l10n.settingsDataStorageImageQualityStandardSubtitle,
      ImageQualityPreference.dataSaver =>
        l10n.settingsDataStorageImageQualityDataSaverSubtitle,
    };
  }

  String _syncLabel(AppLocalizations l10n, SyncPreference pref) {
    return switch (pref) {
      SyncPreference.wifiOnly => l10n.settingsDataStorageSyncWifiOnly,
      SyncPreference.wifiAndMobile => l10n.settingsDataStorageSyncWifiAndMobile,
    };
  }

  String _syncSubtitle(AppLocalizations l10n, SyncPreference pref) {
    return switch (pref) {
      SyncPreference.wifiOnly => l10n.settingsDataStorageSyncWifiOnlySubtitle,
      SyncPreference.wifiAndMobile =>
        l10n.settingsDataStorageSyncWifiAndMobileSubtitle,
    };
  }
}
