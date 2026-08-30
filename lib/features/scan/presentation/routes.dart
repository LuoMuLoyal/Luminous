import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router_helpers.dart';
import 'package:luminous/features/scan/presentation/pages/barcode_scanner.dart';

part 'routes.g.dart';

@TypedGoRoute<ScanBarcodeRoute>(path: '/scan/barcode')
class ScanBarcodeRoute extends GoRouteData with $ScanBarcodeRoute {
  const ScanBarcodeRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return slidePage(key: state.pageKey, child: const BarcodeScannerPage());
  }
}
