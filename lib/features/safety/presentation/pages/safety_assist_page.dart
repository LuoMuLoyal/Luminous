import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/shared/widgets/app_canvas.dart';
import 'package:luminous/shared/design_tokens/design_tokens.dart';
import 'package:luminous/shared/widgets/app_surface.dart';
import 'package:luminous/shared/widgets/tinted_status_chip.dart';
import 'package:luminous/shared/widgets/soft_banner/soft_banner.dart';
import 'package:luminous/features/medicine_picker/presentation/medicine_picker.dart';
import 'package:luminous/features/auth/providers/user_session_provider.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/shared/models/medicine.dart';

import '../providers/safety_provider.dart';
import '../widgets/safety_assist_widgets.dart';

part '../support/safety_assist_text.dart';

/// 安全辅助页。
///
/// 页面允许用户选择一款或两款药品，并调用 AI 接口生成用药建议或相互作用提示。
class SafetyAssistPage extends ConsumerWidget {
  /// 创建安全辅助页组件。
  const SafetyAssistPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(safetyProvider);
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final secondaryAccent = Color.lerp(
      scheme.secondary,
      scheme.tertiary,
      0.52,
    )!;
    return AppCanvasPageScaffold(
      appBar: AppBar(
        title: Text(_safetyTitle(l10n)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      appBarSpacing: 20,
      accentColor: scheme.primary,
      secondaryAccentColor: secondaryAccent,
      child: RefreshIndicator(
        onRefresh: () => ref.read(safetyProvider.notifier).refreshResult(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 18),
          children: [
            _buildHeroCard(context, ref, state, l10n),
            const SizedBox(height: 8),
            _buildModeCard(context, ref, state, l10n),
            const SizedBox(height: 8),
            _buildPickCard(context, ref, state, l10n),
            const SizedBox(height: 8),
            _buildActionCard(context, ref, state, l10n),
            const SizedBox(height: 8),
            SafetyResultSection(result: state.result, l10n: l10n),
            const SizedBox(height: 8),
            const SafetyDisclaimerCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(
    BuildContext context,
    WidgetRef ref,
    SafetyState state,
    AppLocalizations? l10n,
  ) {
    final loggedIn = ref.read(currentUserProvider)?.hasData == true;

    return SoftBannerCard(
      palette: SoftBannerPalettes.drugOf(context),
      ornamentKey: 'safety.hero',
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      builder: (context, theme) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.surfaceColor,
                    border: Border.all(color: theme.borderColor),
                  ),
                  child: Icon(
                    Icons.health_and_safety_outlined,
                    color: theme.accentColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _safetyTitle(l10n),
                        style: TextStyle(
                          color: theme.textColor,
                          fontSize: 17.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _heroSubtitle(l10n),
                        style: TextStyle(
                          color: theme.secondaryTextColor,
                          fontSize: 12,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SafetyInfoChip(
                    icon: state.mode == 'pair'
                        ? Icons.compare_arrows_rounded
                        : Icons.auto_awesome_rounded,
                    text: state.mode == 'pair'
                        ? _modePairText(l10n)
                        : _modeSingleText(l10n),
                    backgroundColor: theme.surfaceColor,
                    foregroundColor: theme.surfaceTextColor,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: SafetyInfoChip(
                    icon: loggedIn
                        ? Icons.cloud_done_rounded
                        : Icons.cloud_outlined,
                    text: loggedIn
                        ? _cloudWithContextText(l10n)
                        : _cloudQueryText(l10n),
                    backgroundColor: theme.surfaceColor,
                    foregroundColor: theme.surfaceTextColor,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildModeCard(
    BuildContext context,
    WidgetRef ref,
    SafetyState state,
    AppLocalizations? l10n,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return SafetySectionCard(
      title: l10n?.safetyModeCardTitle ?? 'Query Mode',
      accentColor: scheme.secondary,
      secondaryColor: scheme.tertiary,
      ornamentKey: 'safety.mode',
      child: SafetyModeSwitcher(
        mode: state.mode,
        l10n: l10n,
        onSelectSingle: () =>
            ref.read(safetyProvider.notifier).setMode('single'),
        onSelectPair: () =>
            ref.read(safetyProvider.notifier).setMode('pair'),
      ),
    );
  }

  Widget _buildPickCard(
    BuildContext context,
    WidgetRef ref,
    SafetyState state,
    AppLocalizations? l10n,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final tileAColor = scheme.primary;
    final tileBColor = Color.lerp(scheme.secondary, scheme.tertiary, 0.35)!;
    return SafetySectionCard(
      title: l10n?.safetyPickCardTitle ?? 'Select Medicines',
      accentColor: scheme.primary,
      secondaryColor: scheme.secondary,
      ornamentKey: 'safety.pick',
      child: Column(
        children: [
          _pickTile(
            context: context,
            label:
                state.medicineA?.displayName ??
                _pickPlaceholderText(l10n, 0),
            subtitle:
                state.medicineA?.displaySubtitle ??
                _pickSubtitleText(l10n),
            color: tileAColor,
            onTap: () => _pickMedicine(context, ref, slot: 0),
            badge: _pickBadgeText(l10n, 0),
            note: state.medicineA?.displayTips,
          ),
          if (state.mode == 'pair') ...[
            const SizedBox(height: 8),
            _pickTile(
              context: context,
              label:
                  state.medicineB?.displayName ??
                  _pickPlaceholderText(l10n, 1),
              subtitle:
                  state.medicineB?.displaySubtitle ??
                  _pickSubtitleText(l10n),
              color: tileBColor,
              onTap: () => _pickMedicine(context, ref, slot: 1),
              badge: _pickBadgeText(l10n, 1),
              note: state.medicineB?.displayTips,
            ),
          ],
        ],
      ),
    );
  }

  Widget _pickTile({
    required BuildContext context,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required String badge,
    String? note,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.small),
      child: Ink(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        decoration: BoxDecoration(
          color: appTintedSurface(
            context,
            color,
            lightAlpha: 0.05,
            darkAlpha: 0.11,
          ),
          borderRadius: BorderRadius.circular(AppRadius.small),
          border: Border.all(
            color: appTintedBorder(
              context,
              color,
              lightAlpha: 0.10,
              darkAlpha: 0.18,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: Icon(Icons.medication_outlined, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: AppTypography.cardTitle,
                            fontWeight: FontWeight.w800,
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      TintedStatusChip(
                        text: badge,
                        color: color,
                        enablePopup: false,
                        showBorder: false,
                        fontSize: 10.2,
                        fontWeight: FontWeight.w700,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                  if (note != null && note.trim().isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      note.trim(),
                      style: TextStyle(
                        fontSize: 11.2,
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.88),
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    WidgetRef ref,
    SafetyState state,
    AppLocalizations? l10n,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return SafetySectionCard(
      title: l10n?.safetyActionCardTitle ?? 'Start Query',
      accentColor: scheme.tertiary,
      secondaryColor: scheme.primary,
      ornamentKey: 'safety.action',
      child: Row(
        children: [
          Expanded(
            child: FilledButton(
              onPressed: state.loading || !state.ready
                  ? null
                  : () => ref.read(safetyProvider.notifier).query(
                      refresh: state.result != null,
                    ),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
              ),
              child: state.loading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: scheme.onPrimary,
                      ),
                    )
                  : Text(
                      _actionQueryText(
                        l10n,
                        state.mode,
                        hasResult: state.result != null,
                      ),
                    ),
            ),
          ),
          if (state.loading) ...[
            const SizedBox(width: 6),
            FilledButton.tonal(
              onPressed: () =>
                  ref.read(safetyProvider.notifier).cancelQuery(),
              style: FilledButton.styleFrom(
                minimumSize: const Size(78, 44),
                backgroundColor: const Color(
                  0xFFEF4444,
                ).withValues(alpha: 0.12),
                foregroundColor: const Color(0xFFB91C1C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  side: const BorderSide(color: Color(0xFFEF4444)),
                ),
              ),
              child: Text(_cancelActionText(l10n)),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickMedicine(
    BuildContext context,
    WidgetRef ref, {
    required int slot,
  }) async {
    final l10n = AppLocalizations.of(context);
    final item = await Navigator.of(context).push<MedicineItem>(
      MaterialPageRoute<MedicineItem>(
        builder: (_) => MedicinePickerPage(title: _pickerTitleText(l10n, slot)),
      ),
    );
    if (item == null || !context.mounted) {
      return;
    }
    ref.read(safetyProvider.notifier).setMedicine(slot: slot, item: item);
  }
}
