import 'package:go_router/go_router.dart';
import 'package:luminous/features/mine/presentation/pages/allergy_edit.dart';
import 'package:luminous/features/mine/presentation/pages/condition_edit.dart';
import 'package:luminous/features/mine/presentation/pages/current_medicine_edit.dart';
import 'package:luminous/features/mine/presentation/pages/profile_edit.dart';

import 'router_helpers.dart';

final mineRoutes = [
  GoRoute(
    path: '/mine/profile/edit',
    pageBuilder: (context, state) =>
        slidePage(key: state.pageKey, child: const ProfileEditPage()),
  ),
  GoRoute(
    path: '/mine/allergy/new',
    pageBuilder: (context, state) =>
        slidePage(key: state.pageKey, child: const AllergyEditPage()),
  ),
  GoRoute(
    path: '/mine/allergy/:id/edit',
    pageBuilder: (context, state) => slidePage(
      key: state.pageKey,
      child: AllergyEditPage(allergyId: state.pathParameters['id']),
    ),
  ),
  GoRoute(
    path: '/mine/condition/new',
    pageBuilder: (context, state) =>
        slidePage(key: state.pageKey, child: const ConditionEditPage()),
  ),
  GoRoute(
    path: '/mine/condition/:id/edit',
    pageBuilder: (context, state) => slidePage(
      key: state.pageKey,
      child: ConditionEditPage(conditionId: state.pathParameters['id']),
    ),
  ),
  GoRoute(
    path: '/mine/medicine/new',
    pageBuilder: (context, state) =>
        slidePage(key: state.pageKey, child: const CurrentMedicineEditPage()),
  ),
  GoRoute(
    path: '/mine/medicine/:id/edit',
    pageBuilder: (context, state) => slidePage(
      key: state.pageKey,
      child: CurrentMedicineEditPage(medicineId: state.pathParameters['id']),
    ),
  ),
];
