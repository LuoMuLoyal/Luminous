import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/features/scan/presentation/pages/barcode_scanner_page.dart';

import 'helpers.dart';

final scanRoute = GoRoute(
  path: AppRoutes.scanBarcode,
  pageBuilder: (context, state) =>
      slidePage(key: state.pageKey, child: const BarcodeScannerPage()),
);
