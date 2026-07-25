import 'package:flutter/widgets.dart';

/// Intent to open the command palette (Ctrl/Cmd+K).
class OpenCommandPaletteIntent extends Intent {
  const OpenCommandPaletteIntent();
}

/// Intent to create a new record (Ctrl/Cmd+N).
class CreateRecordIntent extends Intent {
  const CreateRecordIntent();
}

/// Intent to open settings (Ctrl/Cmd+,).
class OpenSettingsIntent extends Intent {
  const OpenSettingsIntent();
}

/// Intent to open the assistant (Ctrl/Cmd+Shift+A).
class OpenAssistantIntent extends Intent {
  const OpenAssistantIntent();
}

/// Intent to switch to a specific shell tab by index (Ctrl/Cmd+1..5).
class SwitchTabIntent extends Intent {
  const SwitchTabIntent(this.index);

  final int index;
}
