import 'package:flutter/material.dart';
import 'package:luminous/core/widgets/app_state_views.dart';

class AssistantStateCard extends StatelessWidget {
  const AssistantStateCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.actionLabel,
    this.onAction,
    this.tone = AppStateTone.neutral,
  });

  final String title;
  final String description;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final AppStateTone tone;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: AppStateMessageView(
          title: title,
          description: description,
          icon: icon,
          actionLabel: actionLabel,
          onAction: onAction,
          tone: tone,
        ),
      ),
    );
  }
}
