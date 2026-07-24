import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/config/pref_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controller for the desktop sidebar collapsed preference.
///
/// Uses [AsyncNotifier] because [SharedPreferences.getInstance] is asynchronous.
/// Consumers should read the synchronous data value via
/// `ref.watch(sidebarPreferenceProvider).asData?.value ?? false`.
///
/// When `true`, the sidebar shows only icons (rail mode). When `false`,
/// the sidebar shows icons and labels (full mode). Only relevant on desktop
/// layouts (width >= [Breakpoints.desktop]).
class SidebarPreferenceController extends AsyncNotifier<bool> {
  static const _key = PrefKeys.sidebarCollapsed;

  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  /// Toggles between collapsed (rail) and expanded (full) sidebar.
  Future<void> toggle() async {
    final current = state.asData?.value ?? false;
    final next = !current;
    state = AsyncData(next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, next);
  }

  /// Sets the sidebar collapsed state directly.
  Future<void> setCollapsed(bool collapsed) async {
    if (state.asData?.value == collapsed) return;
    state = AsyncData(collapsed);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, collapsed);
  }
}

final sidebarPreferenceProvider =
    AsyncNotifierProvider<SidebarPreferenceController, bool>(
      SidebarPreferenceController.new,
    );
