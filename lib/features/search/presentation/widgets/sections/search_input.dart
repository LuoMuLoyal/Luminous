import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/l10n/app_localizations.dart';

class SearchInput extends StatefulWidget {
  const SearchInput({
    super.key,
    required this.l10n,
    required this.typography,
    required this.surface,
    required this.query,
    required this.onChanged,
  });
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final String query;
  final ValueChanged<String> onChanged;
  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  late final TextEditingController _controller;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SearchInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query && widget.query != _controller.text) {
      _controller.text = widget.query;
    }
  }

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: widget.surface.canvas,
      borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
      border: Border.all(
        color: widget.surface.hairlineStrong.withValues(alpha: 0.28),
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacingTokens.md,
        vertical: AppSpacingTokens.sm,
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: widget.surface.mute),
          const SizedBox(width: AppSpacingTokens.sm),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: widget.l10n.medicineSearchFieldHint,
                hintStyle: widget.typography.bodySm.copyWith(
                  color: widget.surface.mute,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: widget.typography.bodySm,
              onChanged: widget.onChanged,
              textInputAction: TextInputAction.search,
              onSubmitted: widget.onChanged,
            ),
          ),
          if (_controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _controller.clear();
                widget.onChanged('');
              },
              child: Icon(
                Icons.cancel_rounded,
                color: widget.surface.mute,
                size: 18,
              ),
            ),
        ],
      ),
    ),
  );
}
