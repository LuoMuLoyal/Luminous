import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router_helpers.dart';
import 'package:luminous/features/mine/presentation/pages/allergy_edit.dart';
import 'package:luminous/features/mine/presentation/pages/condition_edit.dart';
import 'package:luminous/features/mine/presentation/pages/current_medicine_edit.dart';
import 'package:luminous/features/mine/presentation/pages/profile_edit.dart';

part 'routes.g.dart';

@TypedGoRoute<MineProfileEditRoute>(path: '/mine/profile/edit')
class MineProfileEditRoute extends GoRouteData with $MineProfileEditRoute {
  const MineProfileEditRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return slidePage(key: state.pageKey, child: const ProfileEditPage());
  }
}

@TypedGoRoute<MineAllergyNewRoute>(path: '/mine/allergy/new')
class MineAllergyNewRoute extends GoRouteData with $MineAllergyNewRoute {
  const MineAllergyNewRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return slidePage(key: state.pageKey, child: const AllergyEditPage());
  }
}

@TypedGoRoute<MineAllergyEditRoute>(path: '/mine/allergy/:id/edit')
class MineAllergyEditRoute extends GoRouteData with $MineAllergyEditRoute {
  const MineAllergyEditRoute({required this.id});

  final String id;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return slidePage(
      key: state.pageKey,
      child: AllergyEditPage(allergyId: id),
    );
  }
}

@TypedGoRoute<MineConditionNewRoute>(path: '/mine/condition/new')
class MineConditionNewRoute extends GoRouteData with $MineConditionNewRoute {
  const MineConditionNewRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return slidePage(key: state.pageKey, child: const ConditionEditPage());
  }
}

@TypedGoRoute<MineConditionEditRoute>(path: '/mine/condition/:id/edit')
class MineConditionEditRoute extends GoRouteData with $MineConditionEditRoute {
  const MineConditionEditRoute({required this.id});

  final String id;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return slidePage(
      key: state.pageKey,
      child: ConditionEditPage(conditionId: id),
    );
  }
}

@TypedGoRoute<MineMedicineNewRoute>(path: '/mine/medicine/new')
class MineMedicineNewRoute extends GoRouteData with $MineMedicineNewRoute {
  const MineMedicineNewRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return slidePage(
      key: state.pageKey,
      child: const CurrentMedicineEditPage(),
    );
  }
}

@TypedGoRoute<MineMedicineEditRoute>(path: '/mine/medicine/:id/edit')
class MineMedicineEditRoute extends GoRouteData with $MineMedicineEditRoute {
  const MineMedicineEditRoute({required this.id});

  final String id;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return slidePage(
      key: state.pageKey,
      child: CurrentMedicineEditPage(medicineId: id),
    );
  }
}
