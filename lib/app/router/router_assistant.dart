import 'package:go_router/go_router.dart';
import 'package:luminous/features/assistant/presentation/pages/assistant_page.dart';

import 'router_helpers.dart';

final assistantRoute = GoRoute(
  path: '/assistant',
  pageBuilder: (context, state) =>
      slidePage(key: state.pageKey, child: const AssistantPage()),
);
