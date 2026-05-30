part of '../settings.dart';

class _DisplayPreferencesSection extends StatelessWidget {
  const _DisplayPreferencesSection({
    required this.themeNotifier,
    required this.themeState,
  });

  final ThemeNotifier themeNotifier;
  final ThemeState themeState;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return (() {
      final l10n = AppLocalizations.of(context);
      final preference = themeState.modePreference;
      final selectedStyle = themeState.style;
      final systemBrightness = MediaQuery.platformBrightnessOf(context);
      final resolvedDark = preference == AppThemeModePreference.system
          ? systemBrightness == Brightness.dark
          : preference == AppThemeModePreference.dark;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SettingsFieldTitle(
            icon: preference == AppThemeModePreference.system
                ? Icons.brightness_auto_rounded
                : (resolvedDark
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded),
            title: l10n?.settingsThemeModeFieldTitle ?? '主题模式',
            description:
                l10n?.settingsThemeModeFieldSubtitle ?? '支持跟随系统、固定浅色和固定深色三种方式',
            color: scheme.primary,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppThemeModePreference.values
                .map(
                  (item) => ChoiceChip(
                    label: Text(_themeModeLabel(item, l10n: l10n)),
                    avatar: Icon(
                      _themeModeIcon(item),
                      size: 18,
                      color: preference == item
                          ? scheme.primary
                          : scheme.onSurfaceVariant,
                    ),
                    selected: preference == item,
                    onSelected: (_) {
                      themeNotifier.setThemePreference(item);
                    },
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: preference == item
                          ? scheme.primary
                          : scheme.onSurface,
                    ),
                    side: BorderSide(
                      color: preference == item
                          ? scheme.primary.withValues(alpha: 0.28)
                          : scheme.outline,
                    ),
                    backgroundColor: theme.cardColor.withValues(alpha: 0.45),
                    selectedColor: scheme.primary.withValues(alpha: 0.12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          Text(
            preference == AppThemeModePreference.system
                ? (l10n?.settingsThemeModeCurrentSystem(
                        resolvedDark
                            ? (l10n.settingsThemeModeOptionDark)
                            : (l10n.settingsThemeModeOptionLight),
                      ) ??
                      '当前跟随系统，系统正在使用${resolvedDark ? '深色' : '浅色'}外观')
                : (l10n?.settingsThemeModeCurrentFixed(
                        resolvedDark
                            ? (l10n.settingsThemeModeOptionDark)
                            : (l10n.settingsThemeModeOptionLight),
                      ) ??
                      '当前固定为${resolvedDark ? '深色' : '浅色'}外观'),
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _SettingsFieldTitle(
            icon: Icons.palette_outlined,
            title: l10n?.settingsThemeStyleFieldTitle ?? '主题风格',
            description:
                l10n?.settingsThemeStyleFieldSubtitle ??
                '柔岚、月雾、神树、虚霭、浅砂五套配色会一起影响环境光、横幅和分区块',
            color: scheme.secondary,
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final styles = AppThemeStyle.values;
              final columnCount = constraints.maxWidth >= 720
                  ? 3
                  : (constraints.maxWidth >= 500 ? 2 : 1);
              const spacing = 10.0;
              final itemWidth =
                  (constraints.maxWidth - (columnCount - 1) * spacing) /
                  columnCount;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: styles
                    .map(
                      (style) => SizedBox(
                        width: itemWidth,
                        child: _ThemeStyleCard(
                          style: style,
                          selected: selectedStyle == style,
                          l10n: l10n,
                          onTap: () => themeNotifier.setThemeStyle(style),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      );
    })();
  }
}
