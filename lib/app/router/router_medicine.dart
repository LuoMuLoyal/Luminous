import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/features/medicine/presentation/pages/medicine_risk_check_page.dart';
import 'package:luminous/features/medicine/presentation/pages/medicine_reminder_pages.dart';
import 'package:luminous/features/search/presentation/pages/search_page.dart';

import 'router_helpers.dart';

final medicineRoutes = [
  GoRoute(
    path: AppRoutes.medicineSearch,
    pageBuilder: (context, state) =>
        slidePage(key: state.pageKey, child: const SearchPage()),
  ),
  GoRoute(
    path: AppRoutes.medicineRiskCheck,
    pageBuilder: (context, state) =>
        slidePage(key: state.pageKey, child: const MedicineRiskCheckPage()),
  ),
  GoRoute(
    path: AppRoutes.medicineRemindersNew,
    pageBuilder: (context, state) => slidePage(
      key: state.pageKey,
      child: MedicineReminderEditPage(
        initialMedicineId: state.uri.queryParameters['medicineId'],
      ),
    ),
  ),
  GoRoute(
    path: '/medicine/reminders/:medicineId',
    pageBuilder: (context, state) => slidePage(
      key: state.pageKey,
      child: MedicineReminderDetailPage(
        currentMedicineId: state.pathParameters['medicineId']!,
      ),
    ),
  ),
  GoRoute(
    path: '/medicine/reminders/:medicineId/edit',
    pageBuilder: (context, state) => slidePage(
      key: state.pageKey,
      child: MedicineReminderEditPage(
        currentMedicineId: state.pathParameters['medicineId'],
      ),
    ),
  ),
];
