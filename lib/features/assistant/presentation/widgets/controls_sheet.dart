// Experimental/legacy — not part of the shipping assistant path.
// Kept for reference only; no entry points wire this component.
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/assistant/presentation/widgets/sections/controls_panel.dart';
import 'package:luminous/features/settings/domain/entities/user_settings.dart';

/// Sheet wrapper for the assistant controls panel (settings, memory,
/// context toggles).
class AssistantControlsSheet extends StatelessWidget {
  const AssistantControlsSheet({
    super.key,
    required this.title,
    required this.settings,
    required this.fallbackContext,
    required this.capabilities,
    required this.onToggleEnabled,
    required this.onToggleMemoryEnabled,
    required this.onToggleContext,
  });

  final String title;
  final UserSettings? settings;
  final AssistantContextPatch? fallbackContext;
  final AssistantCapabilities capabilities;
  final Future<void> Function(bool) onToggleEnabled;
  final Future<void> Function(bool) onToggleMemoryEnabled;
  final Future<void> Function({
    bool? healthProfile,
    bool? dailyRecords,
    bool? sleepRecords,
    bool? currentMedicines,
  })
  onToggleContext;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width < Breakpoints.tablet
        ? MediaQuery.sizeOf(context).width * 0.92
        : 400.0;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return SizedBox(
      width: width,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            Spacing.level5,
            Spacing.level4,
            Spacing.level5,
            Spacing.level5 + bottomPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TypographyToken.level7.display(context),
                    ),
                  ),
                  FButton.icon(
                    variant: FButtonVariant.ghost,
                    onPress: () => Navigator.of(context).pop(),
                    child: const Icon(SemanticIcons.actionClose),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.level4),
              Flexible(
                child: SingleChildScrollView(
                  child: AssistantControlsPanel(
                    settings: settings,
                    fallbackContext: fallbackContext,
                    capabilities: capabilities,
                    onToggleEnabled: onToggleEnabled,
                    onToggleMemoryEnabled: onToggleMemoryEnabled,
                    onToggleContext:
                        ({
                          bool? healthProfile,
                          bool? dailyRecords,
                          bool? sleepRecords,
                          bool? currentMedicines,
                        }) => onToggleContext(
                          healthProfile: healthProfile,
                          dailyRecords: dailyRecords,
                          sleepRecords: sleepRecords,
                          currentMedicines: currentMedicines,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
