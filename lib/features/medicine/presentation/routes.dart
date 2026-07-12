import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router/helpers.dart';
import 'package:luminous/features/medicine/presentation/pages/risk_check.dart';
import 'package:luminous/features/medicine/presentation/pages/reminder_pages.dart';
import 'package:luminous/features/search/presentation/pages/page.dart';

part 'routes.g.dart';

@TypedGoRoute<MedicineSearchRoute>(path: '/medicine/search')
class MedicineSearchRoute extends GoRouteData with $MedicineSearchRoute {
  const MedicineSearchRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return slidePage(key: state.pageKey, child: const SearchPage());
  }
}

@TypedGoRoute<MedicineRiskCheckRoute>(path: '/medicine/risk-check')
class MedicineRiskCheckRoute extends GoRouteData with $MedicineRiskCheckRoute {
  const MedicineRiskCheckRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return slidePage(key: state.pageKey, child: const MedicineRiskCheckPage());
  }
}

@TypedGoRoute<MedicineRemindersNewRoute>(path: '/medicine/reminders/new')
class MedicineRemindersNewRoute extends GoRouteData
    with $MedicineRemindersNewRoute {
  const MedicineRemindersNewRoute({this.medicineId});

  final String? medicineId;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return slidePage(
      key: state.pageKey,
      child: MedicineReminderEditPage(initialMedicineId: medicineId),
    );
  }
}

@TypedGoRoute<MedicineReminderDetailRoute>(
  path: '/medicine/reminders/:medicineId',
)
class MedicineReminderDetailRoute extends GoRouteData
    with $MedicineReminderDetailRoute {
  const MedicineReminderDetailRoute({required this.medicineId});

  final String medicineId;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return slidePage(
      key: state.pageKey,
      child: MedicineReminderDetailPage(currentMedicineId: medicineId),
    );
  }
}

@TypedGoRoute<MedicineReminderEditRoute>(
  path: '/medicine/reminders/:medicineId/edit',
)
class MedicineReminderEditRoute extends GoRouteData
    with $MedicineReminderEditRoute {
  const MedicineReminderEditRoute({required this.medicineId});

  final String medicineId;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return slidePage(
      key: state.pageKey,
      child: MedicineReminderEditPage(currentMedicineId: medicineId),
    );
  }
}
