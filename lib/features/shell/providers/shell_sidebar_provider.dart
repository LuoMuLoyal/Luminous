import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'shell_sidebar_provider.freezed.dart';

/// The desktop sidebar can be either fully expanded (showing icon + label) or
/// collapsed (showing icon only, with tooltips on hover).
@freezed
abstract class ShellSidebarState with _$ShellSidebarState {
  const factory ShellSidebarState({
    /// Whether the desktop sidebar is collapsed to its narrow form.
    @Default(false) bool collapsed,
  }) = _ShellSidebarState;
}

/// Controls the desktop sidebar collapsed/expanded state and persists it across
/// app restarts. The state is only meaningful on desktop; mobile clients should
/// ignore it.
class ShellSidebarNotifier extends AsyncNotifier<ShellSidebarState> {
  static const _storageKey = 'luminous_desktop_sidebar_collapsed';

  @override
  Future<ShellSidebarState> build() async {
    final preferences = await SharedPreferences.getInstance();
    final collapsed = preferences.getBool(_storageKey) ?? false;
    return ShellSidebarState(collapsed: collapsed);
  }

  /// Toggles between the expanded and collapsed sidebar forms.
  Future<void> toggle() async {
    final current = state.value ?? const ShellSidebarState();
    final next = current.copyWith(collapsed: !current.collapsed);
    await _save(next);
  }

  /// Explicitly sets the collapsed state.
  Future<void> setCollapsed(bool collapsed) async {
    final current = state.value ?? const ShellSidebarState();
    final next = current.copyWith(collapsed: collapsed);
    await _save(next);
  }

  Future<void> _save(ShellSidebarState next) async {
    state = AsyncData(next);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_storageKey, next.collapsed);
  }
}

final shellSidebarProvider =
    AsyncNotifierProvider<ShellSidebarNotifier, ShellSidebarState>(
      ShellSidebarNotifier.new,
    );

/// Desktop sidebar widths used by the shell layout.
abstract final class ShellSidebarDimensions {
  /// Width of the fully expanded sidebar (icon + label).
  static const double expandedWidth = 232;

  /// Width of the collapsed sidebar (icon only).
  static const double collapsedWidth = 72;
}

extension ShellSidebarStateX on ShellSidebarState {
  /// The actual width the sidebar should occupy.
  double get width => collapsed
      ? ShellSidebarDimensions.collapsedWidth
      : ShellSidebarDimensions.expandedWidth;
}
