import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/features/mine/presentation/pages/allergy_edit.dart';
import 'package:luminous/features/mine/presentation/pages/condition_edit.dart';
import 'package:luminous/features/mine/presentation/pages/current_medicine_edit.dart';
import 'package:luminous/features/mine/presentation/pages/profile_edit.dart';

import 'helpers.dart';

final mineRoutes = [
  GoRoute(
    path: AppRoutes.mineProfileEdit,
    pageBuilder: (context, state) =>
        slidePage(key: state.pageKey, child: const ProfileEditPage()),
  ),
  GoRoute(
    path: AppRoutes.mineAllergyNew,
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
    path: AppRoutes.mineConditionNew,
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
    path: AppRoutes.mineMedicineNew,
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
