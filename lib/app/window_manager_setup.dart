import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart' show Size;
import 'package:window_manager/window_manager.dart';

/// Initializes desktop window settings on Windows / macOS / Linux.
///
/// On web and mobile this is a no-op. On desktop it:
/// - Ensures the window manager is initialized.
/// - Sets a minimum window size so the app cannot be resized to an unusable state.
/// - Sets the window title to "Luminous".
/// - Hides the native title bar so a custom one can be rendered in the sidebar.
///
/// Call this before [runApp] in `main.dart`, after [WidgetsFlutterBinding.ensureInitialized].
Future<void> initDesktopWindow() async {
  if (kIsWeb) return;
  if (!Platform.isWindows && !Platform.isMacOS && !Platform.isLinux) return;

  await windowManager.ensureInitialized();

  await windowManager.setMinimumSize(const Size(480, 720));
  await windowManager.setTitle('Luminous');

  // Hide the native title bar so we can render a custom one in the sidebar.
  // On macOS, the traffic-light buttons are still overlaid by the system.
  // On Windows/Linux, we render our own min/max/close buttons.
  await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
}
