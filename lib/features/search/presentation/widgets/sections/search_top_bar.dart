import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/l10n/app_localizations.dart';

import 'package:luminous/core/design/app_design.dart';

class SearchTopBar extends StatelessWidget {
  const SearchTopBar({super.key, required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FButton(
          variant: FButtonVariant.ghost,
          size: FButtonSizeVariant.sm,
          onPress: () => context.pop(),
          child: const Icon(FLucideIcons.chevronLeft, size: 18),
        ),
        Expanded(
          child: Text(
            l10n.medicineSearchPageTitle,
            textAlign: TextAlign.center,
            style: AppTypographyToken.level6
                .body(context)
                .copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(width: 40),
      ],
    );
  }
}
