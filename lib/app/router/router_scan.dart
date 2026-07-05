import 'package:go_router/go_router.dart';
import 'package:luminous/features/scan/presentation/pages/barcode_scanner_page.dart';

import 'router_helpers.dart';

final scanRoute = GoRoute(
  path: '/scan/barcode',
  pageBuilder: (context, state) =>
      slidePage(key: state.pageKey, child: const BarcodeScannerPage()),
);
