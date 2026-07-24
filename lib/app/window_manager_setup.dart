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
///
/// Call this before [runApp] in `main.dart`, after [WidgetsFlutterBinding.ensureInitialized].
Future<void> initDesktopWindow() async {
  if (kIsWeb) return;
  if (!Platform.isWindows && !Platform.isMacOS && !Platform.isLinux) return;

  await windowManager.ensureInitialized();

  await windowManager.setMinimumSize(const Size(480, 720));
  await windowManager.setTitle('Luminous');
}
