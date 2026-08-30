import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/errors/user_message.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/settings/domain/entities/user_settings.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings.dart';
import 'package:luminous/features/settings/presentation/utils/page_padding.dart';
import 'package:luminous/features/settings/presentation/widgets/shared/section_label.dart';
import 'package:luminous/features/settings/presentation/widgets/shared/subpage_tile_group_style.dart';
import 'package:luminous/l10n/app_localizations.dart';

class AiSettingsPage extends ConsumerStatefulWidget {
  const AiSettingsPage({super.key});

  @override
  ConsumerState<AiSettingsPage> createState() => _AiSettingsPageState();
}

class _AiSettingsPageState extends ConsumerState<AiSettingsPage> {
  /// Tracks any in-flight PATCH on this page. While true, every toggle is
  /// disabled so two rapid taps cannot both compute "flip false→true" off the
  /// same stale snapshot — the first tap flips this to `true` and the second
  /// tap's tile is disabled before its `onChange`/`onPress` can fire.
  bool _isPatching = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsAsync = ref.watch(userSettingsControllerProvider);
    final settings = settingsAsync.asData?.value;
    final signedIn = settings != null;
    final assistantEnabled = settings?.assistantEnabled ?? false;
    final disabled = _isPatching || settingsAsync.isLoading;
    final contextDisabled = !assistantEnabled || disabled;

    return PageScaffold(
      title: l10n.settingsAiTitle,
      child: SingleChildScrollView(
        child: ResponsiveContentFrame(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: settingsPageVerticalPadding(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FTileGroup(
                  style: settingsSubpageTileGroupStyle(context.theme),
                  children: [
                    _buildToggleTile(
                      context: context,
                      l10n: l10n,
                      signedIn: signedIn,
                      disabled: disabled,
                      title: l10n.settingsAiSummariesTitle,
                      subtitle: l10n.settingsAiSummariesSubtitle,
                      value: settings?.aiSummariesEnabled ?? false,
                      read: (r) =>
                          r
                              .read(userSettingsControllerProvider)
                              .value
                              ?.aiSummariesEnabled ??
                          false,
                      apply: (next) => ref
                          .read(userSettingsControllerProvider.notifier)
                          .setAiSummariesEnabled(next),
                    ),
                    _buildToggleTile(
                      context: context,
                      l10n: l10n,
                      signedIn: signedIn,
                      disabled: disabled,
                      title: l10n.settingsAiAssistantTitle,
                      subtitle: l10n.settingsAiAssistantSubtitle,
                      value: settings?.assistantEnabled ?? false,
                      read: (r) =>
                          r
                              .read(userSettingsControllerProvider)
                              .value
                              ?.assistantEnabled ??
                          false,
                      apply: (next) => ref
                          .read(userSettingsControllerProvider.notifier)
                          .setAssistantEnabled(next),
                    ),
                    _buildToggleTile(
                      context: context,
                      l10n: l10n,
                      signedIn: signedIn,
                      disabled: disabled,
                      title: l10n.settingsAiMemoryTitle,
                      subtitle: l10n.settingsAiMemorySubtitle,
                      value: settings?.assistantMemoryEnabled ?? false,
                      read: (r) =>
                          r
                              .read(userSettingsControllerProvider)
                              .value
                              ?.assistantMemoryEnabled ??
                          false,
                      apply: (next) => ref
                          .read(userSettingsControllerProvider.notifier)
                          .setAssistantMemoryEnabled(next),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.level5),
                SettingsSectionLabel(label: l10n.settingsAiContextSectionTitle),
                const SizedBox(height: Spacing.level3),
                if (!assistantEnabled)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: Spacing.level2,
                      right: Spacing.level2,
                      bottom: Spacing.level3,
                    ),
                    child: Text(
                      l10n.settingsAiContextDisabledHint,
                      style: context.theme.typography.body.xs.copyWith(
                        color: context.theme.colors.mutedForeground,
                      ),
                    ),
                  ),
                FTileGroup(
                  style: settingsSubpageTileGroupStyle(context.theme),
                  children: [
                    _buildContextTile(
                      context: context,
                      l10n: l10n,
                      signedIn: signedIn,
                      enabled: !contextDisabled,
                      title: l10n.settingsAiContextHealthProfile,
                      subtitle: l10n.settingsAiContextHealthProfileSubtitle,
                      value: settings?.assistantContext.healthProfile ?? false,
                      field: _AssistantContextField.healthProfile,
                    ),
                    _buildContextTile(
                      context: context,
                      l10n: l10n,
                      signedIn: signedIn,
                      enabled: !contextDisabled,
                      title: l10n.settingsAiContextDailyRecords,
                      subtitle: l10n.settingsAiContextDailyRecordsSubtitle,
                      value: settings?.assistantContext.dailyRecords ?? false,
                      field: _AssistantContextField.dailyRecords,
                    ),
                    _buildContextTile(
                      context: context,
                      l10n: l10n,
                      signedIn: signedIn,
                      enabled: !contextDisabled,
                      title: l10n.settingsAiContextSleepRecords,
                      subtitle: l10n.settingsAiContextSleepRecordsSubtitle,
                      value: settings?.assistantContext.sleepRecords ?? false,
                      field: _AssistantContextField.sleepRecords,
                    ),
                    _buildContextTile(
                      context: context,
                      l10n: l10n,
                      signedIn: signedIn,
                      enabled: !contextDisabled,
                      title: l10n.settingsAiContextCurrentMedicines,
                      subtitle: l10n.settingsAiContextCurrentMedicinesSubtitle,
                      value:
                          settings?.assistantContext.currentMedicines ?? false,
                      field: _AssistantContextField.currentMedicines,
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.level5),
                SettingsSectionLabel(label: l10n.settingsAiPrivacySectionTitle),
                const SizedBox(height: Spacing.level3),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.level2,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _privacyNote(context, l10n.settingsAiPrivacyMemoryNote),
                      const SizedBox(height: Spacing.level2),
                      _privacyNote(context, l10n.settingsAiPrivacyContextNote),
                      const SizedBox(height: Spacing.level2),
                      _privacyNote(
                        context,
                        l10n.settingsAiPrivacyHistoricalNote,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// A muted small-text line inside the AI privacy section. Describes what
  /// data (memory points / selected context sources) is sent to the AI and
  /// that turning a switch off never deletes historical data.
  Widget _privacyNote(BuildContext context, String text) {
    return Text(
      text,
      style: context.theme.typography.body.xs.copyWith(
        color: context.theme.colors.mutedForeground,
      ),
    );
  }

  /// A boolean settings tile whose `onPress` always reads the latest value
  /// from the controller state (via [read]) instead of capturing a build-time
  /// snapshot, so rapid taps cannot flip the same field twice with a stale
  /// value. PATCH failures are surfaced as a toast.
  FTile _buildToggleTile({
    required BuildContext context,
    required AppLocalizations l10n,
    required bool signedIn,
    required bool disabled,
    required String title,
    required String subtitle,
    required bool value,
    required bool Function(WidgetRef ref) read,
    required Future<void> Function(bool next) apply,
  }) {
    return FTile(
      title: Text(title),
      subtitle: Text(subtitle),
      enabled: !disabled,
      onPress: disabled
          ? null
          : () => unawaited(
              _guardedApply(
                context: context,
                l10n: l10n,
                signedIn: signedIn,
                apply: () => apply(!read(ref)),
              ),
            ),
      suffix: FSwitch(
        value: value,
        enabled: !disabled,
        onChange: disabled
            ? null
            : (next) => unawaited(
                _guardedApply(
                  context: context,
                  l10n: l10n,
                  signedIn: signedIn,
                  apply: () => apply(next),
                ),
              ),
      ),
    );
  }

  FTile _buildContextTile({
    required BuildContext context,
    required AppLocalizations l10n,
    required bool signedIn,
    required bool enabled,
    required String title,
    required String subtitle,
    required bool value,
    required _AssistantContextField field,
  }) {
    return FTile(
      title: Text(title),
      subtitle: Text(subtitle),
      enabled: enabled,
      onPress: enabled
          ? () => unawaited(
              _toggleAssistantContextField(
                context: context,
                l10n: l10n,
                signedIn: signedIn,
                field: field,
              ),
            )
          : null,
      suffix: FSwitch(
        value: value,
        enabled: enabled,
        onChange: enabled
            ? (_) => unawaited(
                _toggleAssistantContextField(
                  context: context,
                  l10n: l10n,
                  signedIn: signedIn,
                  field: field,
                ),
              )
            : null,
      ),
    );
  }

  /// Applies a settings patch, returning `true` when the patch succeeded and
  /// `false` when it was skipped (auth required, another patch in flight) or
  /// failed (failure toast already shown here). Callers that need to react to
  /// success (e.g. the context-toggle next-turn toast) branch on the returned
  /// value; generic toggles ignore it.
  Future<bool> _guardedApply({
    required BuildContext context,
    required AppLocalizations l10n,
    required bool signedIn,
    required Future<void> Function() apply,
  }) async {
    if (!signedIn) {
      unawaited(pushAuthRequiredRoute(context, Routes.settingsAi));
      return false;
    }
    if (_isPatching) return false;
    setState(() => _isPatching = true);
    try {
      await apply();
      return true;
    } catch (error) {
      if (!context.mounted) return false;
      await Toast.show(
        context,
        userMessageFromError(
          error,
          fallback: l10n.settingsSyncFailed,
          l10n: l10n,
        ),
      );
      return false;
    } finally {
      if (mounted) {
        setState(() => _isPatching = false);
      }
    }
  }

  Future<void> _toggleAssistantContextField({
    required BuildContext context,
    required AppLocalizations l10n,
    required bool signedIn,
    required _AssistantContextField field,
  }) async {
    if (!signedIn) {
      unawaited(pushAuthRequiredRoute(context, Routes.settingsAi));
      return;
    }
    // Read the freshest snapshot at click time. Combined with the
    // `_isPatching`-driven disable above, this guarantees that even two taps
    // in quick succession cannot both compute "flip false→true" off the same
    // stale snapshot: the first tap flips `_isPatching` to true and the
    // second tap's tile is disabled before it can fire.
    final current = ref.read(userSettingsControllerProvider).value;
    if (current == null) return;
    final ctx = current.assistantContext;
    final patch = switch (field) {
      _AssistantContextField.healthProfile => AssistantContextPatch(
        healthProfile: !ctx.healthProfile,
        dailyRecords: ctx.dailyRecords,
        sleepRecords: ctx.sleepRecords,
        currentMedicines: ctx.currentMedicines,
      ),
      _AssistantContextField.dailyRecords => AssistantContextPatch(
        healthProfile: ctx.healthProfile,
        dailyRecords: !ctx.dailyRecords,
        sleepRecords: ctx.sleepRecords,
        currentMedicines: ctx.currentMedicines,
      ),
      _AssistantContextField.sleepRecords => AssistantContextPatch(
        healthProfile: ctx.healthProfile,
        dailyRecords: ctx.dailyRecords,
        sleepRecords: !ctx.sleepRecords,
        currentMedicines: ctx.currentMedicines,
      ),
      _AssistantContextField.currentMedicines => AssistantContextPatch(
        healthProfile: ctx.healthProfile,
        dailyRecords: ctx.dailyRecords,
        sleepRecords: ctx.sleepRecords,
        currentMedicines: !ctx.currentMedicines,
      ),
    };
    final applied = await _guardedApply(
      context: context,
      l10n: l10n,
      signedIn: signedIn,
      apply: () => ref
          .read(userSettingsControllerProvider.notifier)
          .setAssistantContext(patch),
    );
    // The change only takes effect from the next conversation; historical
    // messages keep their already-injected context. Only surface this on
    // success — on failure `_guardedApply` already showed the error toast.
    if (applied && context.mounted) {
      await Toast.show(context, l10n.settingsAiContextChangeNextTurnToast);
    }
  }
}

/// Identifies a single field inside [AssistantContextSettings] so callers can
/// request a toggle without having to construct a full [AssistantContextPatch]
/// at build time (which is what caused the stale-snapshot bug).
enum _AssistantContextField {
  healthProfile,
  dailyRecords,
  sleepRecords,
  currentMedicines,
}
