import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart' show Size;
import 'package:luminous/core/design/tokens/breakpoints.dart';
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

  // 最小尺寸按 M3 `expanded` 档（≥840）给窗口留出双栏余地。
  //
  // 原来锁到 480×720 —— 那是手机的长宽比。窗口可以缩成比手机还窄的样子时，
  // 桌面布局会塌回单列，而 `Breakpoints` 里所有 ≥600 的分支永远走不到，
  // 等于桌面端的响应式逻辑只存在于代码里。下限必须落在「确实能算桌面」
  // 的区间，让拖动窗口本身成为可验证的分档行为。
  await windowManager.setMinimumSize(
    const Size(Breakpoints.expanded + 120, 640),
  );
  await windowManager.setTitle('Luminous');

  // Hide the native title bar so we can render a custom one in the sidebar.
  // On macOS, the traffic-light buttons are still overlaid by the system.
  // On Windows/Linux, we render our own min/max/close buttons.
  await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
}
