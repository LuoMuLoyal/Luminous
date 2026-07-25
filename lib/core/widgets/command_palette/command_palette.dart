import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// A command palette dialog triggered by Ctrl/Cmd+K.
///
/// Provides quick navigation to shell tabs and common actions (new record,
/// settings, assistant, sidebar toggle). Supports fuzzy text search and
/// keyboard navigation (Up/Down/Enter/Escape).
class CommandPalette extends StatefulWidget {
  const CommandPalette({super.key});

  @override
  State<CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends State<CommandPalette> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  int _selectedIndex = 0;
  List<_Command> _filtered = [];
  List<_Command> _allCommands = [];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onQueryChanged);
    _allCommands = _buildCommands(context);
    _filtered = _allCommands;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    final query = _controller.text.toLowerCase().trim();
    setState(() {
      _filtered = _allCommands.where((cmd) {
        if (query.isEmpty) return true;
        // Match against all searchable strings (label, keywords, aliases).
        return cmd.searchStrings.any((s) => s.toLowerCase().contains(query));
      }).toList();
      _selectedIndex = 0;
    });
  }

  List<_Command> _buildCommands(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return [
      // ── Navigation ──
      _Command(
        label: l10n.tabToday,
        icon: FLucideIcons.layoutGrid,
        keywords: ['today', '今日', l10n.tabToday],
        category: l10n.commandPaletteNavigateTo,
        onExecute: () => context.go(Routes.home),
      ),
      _Command(
        label: l10n.tabRecord,
        icon: FLucideIcons.notebookPen,
        keywords: ['record', '记录', l10n.tabRecord],
        category: l10n.commandPaletteNavigateTo,
        onExecute: () => context.go(Routes.record),
      ),
      _Command(
        label: l10n.tabMedicine,
        icon: FLucideIcons.pillBottle,
        keywords: ['medicine', '用药', '药品', l10n.tabMedicine],
        category: l10n.commandPaletteNavigateTo,
        onExecute: () => context.go(Routes.medicine),
      ),
      _Command(
        label: l10n.tabReport,
        icon: FLucideIcons.barChart,
        keywords: ['report', '报告', l10n.tabReport],
        category: l10n.commandPaletteNavigateTo,
        onExecute: () => context.go(Routes.report),
      ),
      _Command(
        label: l10n.tabMine,
        icon: FLucideIcons.userRound,
        keywords: ['mine', '我的', 'profile', l10n.tabMine],
        category: l10n.commandPaletteNavigateTo,
        onExecute: () => context.go(Routes.mine),
      ),
      // ── Actions ──
      _Command(
        label: l10n.desktopSidebarSettings,
        icon: FLucideIcons.settings,
        keywords: ['settings', '设置', l10n.desktopSidebarSettings],
        category: l10n.commandPaletteActions,
        onExecute: () => context.push(Routes.settings),
      ),
      _Command(
        label: l10n.desktopSidebarHelp,
        icon: FLucideIcons.circleHelp,
        keywords: ['help', 'assistant', '帮助', '助手', l10n.desktopSidebarHelp],
        category: l10n.commandPaletteActions,
        onExecute: () => context.push(Routes.assistant),
      ),
    ];
  }

  void _executeSelected() {
    if (_filtered.isEmpty) return;
    final cmd = _filtered[_selectedIndex];
    Navigator.of(context).pop();
    cmd.onExecute();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = context.theme;

    return Dialog(
      backgroundColor: theme.colors.background,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 480),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.level4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search field.
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.commandPaletteSearchHint,
                  prefixIcon: Icon(
                    FLucideIcons.search,
                    size: 18,
                    color: theme.colors.mutedForeground,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: Spacing.level3,
                    vertical: Spacing.level3,
                  ),
                ),
                style: TypographyToken.level4.body(context),
                onSubmitted: (_) => _executeSelected(),
              ),
              Divider(color: theme.colors.border, height: 1),
              // Results list.
              if (_filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: Spacing.level6),
                  child: Center(
                    child: Text(
                      l10n.commandPaletteEmpty,
                      style: TypographyToken.level3
                          .body(context)
                          .copyWith(color: theme.colors.mutedForeground),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: Spacing.level2),
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) {
                      final cmd = _filtered[index];
                      final selected = index == _selectedIndex;
                      return _CommandTile(
                        command: cmd,
                        selected: selected,
                        onTap: () {
                          setState(() => _selectedIndex = index);
                          _executeSelected();
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Command {
  const _Command({
    required this.label,
    required this.icon,
    required this.keywords,
    required this.category,
    required this.onExecute,
  });

  final String label;
  final IconData icon;
  final List<String> keywords;
  final String category;
  final VoidCallback onExecute;

  List<String> get searchStrings => [label, ...keywords];
}

class _CommandTile extends StatefulWidget {
  const _CommandTile({
    required this.command,
    required this.selected,
    required this.onTap,
  });

  final _Command command;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_CommandTile> createState() => _CommandTileState();
}

class _CommandTileState extends State<_CommandTile> {
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Focus(
      autofocus: widget.selected,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          final key = event.logicalKey;
          if (key == LogicalKeyboardKey.enter ||
              key == LogicalKeyboardKey.numpadEnter) {
            widget.onTap();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.level3,
            vertical: Spacing.level3,
          ),
          decoration: BoxDecoration(
            color: widget.selected
                ? SemanticColor.primary.muted(context)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(RadiusTokens.level3),
          ),
          child: Row(
            children: [
              Icon(
                widget.command.icon,
                size: 18,
                color: widget.selected
                    ? theme.colors.primary
                    : theme.colors.mutedForeground,
              ),
              const SizedBox(width: Spacing.level3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.command.label,
                      style: TypographyToken.level4
                          .body(context)
                          .copyWith(
                            color: theme.colors.foreground,
                            fontWeight: widget.selected
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                    ),
                    Text(
                      widget.command.category,
                      style: TypographyToken.level2
                          .body(context)
                          .copyWith(color: theme.colors.mutedForeground),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows the command palette as a dialog.
Future<void> showCommandPalette(BuildContext context) async {
  await showDialog<void>(
    context: context,
    barrierColor: Colors.black54,
    builder: (context) => const CommandPalette(),
  );
}
