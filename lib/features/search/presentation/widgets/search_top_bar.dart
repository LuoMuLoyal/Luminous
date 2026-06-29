import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/l10n/app_localizations.dart';

class SearchTopBar extends StatelessWidget {
  const SearchTopBar({
    super.key,
    required this.l10n,
    required this.typography,
    required this.surface,
  });
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      BackButton(onPressed: () => context.pop()),
      Expanded(
        child: Text(
          l10n.medicineSearchPageTitle,
          textAlign: TextAlign.center,
          style: typography.displaySm,
        ),
      ),
    ],
  );
}
