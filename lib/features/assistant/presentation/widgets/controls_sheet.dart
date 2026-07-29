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
    final width = MediaQuery.sizeOf(context).width < 600
        ? MediaQuery.sizeOf(context).width * 0.85
        : 400.0;

    return SizedBox(
      width: width,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.level5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              Expanded(
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
