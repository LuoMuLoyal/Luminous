import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/theme/app_theme_controller.dart';
import 'package:luminous/core/theme/theme.dart';
import 'package:luminous/features/settings/presentation/utils/theme_preference_labels.dart';
import 'package:luminous/l10n/app_localizations.dart';

void main() {
  Future<AppLocalizations> loadL10n(Locale locale) async {
    return AppLocalizations.delegate.load(locale);
  }

  group('themeModeLabel', () {
    testWidgets('returns system label for system mode (zh)', (tester) async {
      final l10n = await loadL10n(const Locale('zh'));
      expect(
        themeModeLabel(l10n, AppThemeModePreference.system),
        l10n.mineThemeModeSystem,
      );
    });

    testWidgets('returns light label for light mode (zh)', (tester) async {
      final l10n = await loadL10n(const Locale('zh'));
      expect(
        themeModeLabel(l10n, AppThemeModePreference.light),
        l10n.mineThemeModeLight,
      );
    });

    testWidgets('returns dark label for dark mode (zh)', (tester) async {
      final l10n = await loadL10n(const Locale('zh'));
      expect(
        themeModeLabel(l10n, AppThemeModePreference.dark),
        l10n.mineThemeModeDark,
      );
    });

    testWidgets('returns correct labels in English', (tester) async {
      final l10n = await loadL10n(const Locale('en'));
      expect(
        themeModeLabel(l10n, AppThemeModePreference.system),
        l10n.mineThemeModeSystem,
      );
      expect(
        themeModeLabel(l10n, AppThemeModePreference.light),
        l10n.mineThemeModeLight,
      );
      expect(
        themeModeLabel(l10n, AppThemeModePreference.dark),
        l10n.mineThemeModeDark,
      );
    });
  });

  group('themeFamilyLabel', () {
    testWidgets('returns correct label for each family (zh)', (tester) async {
      final l10n = await loadL10n(const Locale('zh'));
      for (final family in AppThemeFamily.values) {
        expect(themeFamilyLabel(l10n, family), isNotEmpty);
      }
    });

    testWidgets('returns blue family label (en)', (tester) async {
      final l10n = await loadL10n(const Locale('en'));
      expect(
        themeFamilyLabel(l10n, AppThemeFamily.blue),
        l10n.settingsThemeFamilyBlue,
      );
    });

    testWidgets('returns green family label (en)', (tester) async {
      final l10n = await loadL10n(const Locale('en'));
      expect(
        themeFamilyLabel(l10n, AppThemeFamily.green),
        l10n.settingsThemeFamilyGreen,
      );
    });

    testWidgets('returns zinc family label (en)', (tester) async {
      final l10n = await loadL10n(const Locale('en'));
      expect(
        themeFamilyLabel(l10n, AppThemeFamily.zinc),
        l10n.settingsThemeFamilyZinc,
      );
    });
  });

  group('themePreferenceSummary', () {
    testWidgets('combines mode and family labels with separator (zh)', (
      tester,
    ) async {
      final l10n = await loadL10n(const Locale('zh'));
      const preference = AppThemePreference(
        mode: AppThemeModePreference.dark,
        family: AppThemeFamily.blue,
      );

      final summary = themePreferenceSummary(l10n, preference);
      expect(summary, contains(l10n.mineThemeModeDark));
      expect(summary, contains(l10n.settingsThemeFamilyBlue));
      expect(summary, contains('·'));
    });

    testWidgets('combines system mode and neutral family (en)', (tester) async {
      final l10n = await loadL10n(const Locale('en'));
      const preference = AppThemePreference(
        mode: AppThemeModePreference.system,
        family: AppThemeFamily.neutral,
      );

      final summary = themePreferenceSummary(l10n, preference);
      expect(summary, contains(l10n.mineThemeModeSystem));
      expect(summary, contains(l10n.settingsThemeFamilyNeutral));
    });
  });
}
