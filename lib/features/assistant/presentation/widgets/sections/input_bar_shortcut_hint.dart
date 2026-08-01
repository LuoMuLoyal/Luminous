import 'dart:async';

import 'package:flutter/material.dart';

/// A widget that schedules hiding a desktop shortcut hint after a short delay.
///
/// Its build is empty; it exists purely to manage the lifecycle of the timer so
/// the parent can focus on layout.
class AssistantShortcutHintAutoHide extends StatefulWidget {
  const AssistantShortcutHintAutoHide({required this.onHide, super.key});

  final VoidCallback onHide;

  @override
  State<AssistantShortcutHintAutoHide> createState() =>
      _AssistantShortcutHintAutoHideState();
}

class _AssistantShortcutHintAutoHideState
    extends State<AssistantShortcutHintAutoHide> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), () {
      widget.onHide();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
