import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/shared/widgets/app_canvas.dart';
import 'package:luminous/constants/constants.dart';
import 'package:luminous/features/today/presentation/today.dart';
import 'package:luminous/features/record/presentation/record_page.dart';
import 'package:luminous/features/search/presentation/search.dart';
import 'package:luminous/features/settings/presentation/settings.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/features/drug/presentation/drug.dart';
import 'package:luminous/features/mine/presentation/mine.dart';
import 'package:luminous/features/more/presentation/more_page.dart';
import 'package:luminous/features/safety/presentation/safety.dart';
import 'package:luminous/shared/layout/adaptive_layout.dart';

import 'providers/main_shell_provider.dart';

export 'providers/main_shell_provider.dart';

part 'pages/main_page.dart';
part 'support/main_tab_item.dart';
part 'widgets/main_navigation_rail.dart';
