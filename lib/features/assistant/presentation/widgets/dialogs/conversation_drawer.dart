import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/assistant/presentation/widgets/dialogs/conversation_drawer_header.dart';
import 'package:luminous/features/assistant/presentation/widgets/dialogs/conversation_drawer_list.dart';
import 'package:luminous/features/assistant/presentation/widgets/dialogs/conversation_drawer_state.dart';

/// The conversation manager rendered inside the page's opaque push drawer.
///
/// Conversations are grouped by recency (today / last 7 days / older) and the
/// currently active conversation is visually highlighted. Rename and delete
/// actions are currently disabled because the backend does not expose
/// `PATCH /conversations/:id` or `DELETE /conversations/:id` yet.
class AssistantConversationDrawer extends StatefulWidget {
  const AssistantConversationDrawer({
    super.key,
    this.width,
    required this.state,
    required this.title,
    required this.emptyTitle,
    required this.emptyDescription,
    required this.searchHint,
    required this.searchEmptyTitle,
    required this.searchEmptyDescription,
    required this.onClose,
    required this.onRetry,
    required this.onSelect,
    this.onNewConversation,
  });

  final AssistantDrawerState state;
  final double? width;
  final String title;
  final String emptyTitle;
  final String emptyDescription;
  final String searchHint;
  final String searchEmptyTitle;
  final String searchEmptyDescription;
  final VoidCallback onClose;
  final VoidCallback onRetry;
  final ValueChanged<String> onSelect;
  final VoidCallback? onNewConversation;

  @override
  State<AssistantConversationDrawer> createState() =>
      _AssistantConversationDrawerState();
}

class _AssistantConversationDrawerState
    extends State<AssistantConversationDrawer> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController()..addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final width =
        widget.width ??
        (MediaQuery.sizeOf(context).width < Breakpoints.tablet
            ? MediaQuery.sizeOf(context).width * 0.85
            : 320.0);

    return SizedBox(
      key: const Key('assistant-conversation-drawer'),
      width: width,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.level5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AssistantConversationDrawerHeader(
                title: widget.title,
                searchField: FTextField(
                  key: const Key('assistant-conversation-search'),
                  control: FTextFieldControl.managed(
                    controller: _searchController,
                  ),
                  hint: widget.searchHint,
                  prefixBuilder: (context, style, variants) =>
                      FTextField.prefixIconBuilder(
                        context,
                        style,
                        variants,
                        const Icon(FLucideIcons.search),
                      ),
                ),
                onNewConversation: widget.onNewConversation,
                onClose: widget.onClose,
              ),
              const SizedBox(height: Spacing.level4),
              Expanded(
                child: AssistantConversationDrawerList(
                  state: widget.state,
                  emptyTitle: widget.emptyTitle,
                  emptyDescription: widget.emptyDescription,
                  searchQuery: _searchController.text,
                  searchEmptyTitle: widget.searchEmptyTitle,
                  searchEmptyDescription: widget.searchEmptyDescription,
                  onRetry: widget.onRetry,
                  onSelect: widget.onSelect,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
