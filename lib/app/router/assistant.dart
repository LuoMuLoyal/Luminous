import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/features/assistant/presentation/pages/page.dart';

import 'helpers.dart';

final assistantRoute = GoRoute(
  path: AppRoutes.assistant,
  pageBuilder: (context, state) =>
      slidePage(key: state.pageKey, child: const AssistantPage()),
);
