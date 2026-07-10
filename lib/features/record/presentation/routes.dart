import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router/helpers.dart';
import 'package:luminous/features/record/domain/entities/record.dart';

import 'package:luminous/features/record/presentation/pages/create.dart';
import 'package:luminous/features/record/presentation/pages/detail.dart';
import 'package:luminous/features/record/presentation/pages/edit.dart';
import 'package:luminous/features/record/presentation/utils/date_time_formatters.dart';

part 'routes.g.dart';

@TypedGoRoute<RecordCreateRoute>(path: '/record/create')
class RecordCreateRoute extends GoRouteData with $RecordCreateRoute {
  const RecordCreateRoute({this.kind, this.date, this.time});

  final DailyRecordKind? kind;

  final String? date;

  final String? time;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return slidePage(
      key: state.pageKey,
      child: RecordCreatePage(
        initialKind: kind,
        initialDate: parseRecordDate(date),
        initialTime: time,
      ),
    );
  }
}

@TypedGoRoute<RecordDetailRoute>(path: '/record/:id')
class RecordDetailRoute extends GoRouteData with $RecordDetailRoute {
  const RecordDetailRoute({required this.id});

  final String id;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return slidePage(
      key: state.pageKey,
      child: RecordDetailPage(recordId: id),
    );
  }
}

@TypedGoRoute<RecordEditRoute>(path: '/record/:id/edit')
class RecordEditRoute extends GoRouteData with $RecordEditRoute {
  const RecordEditRoute({required this.id});

  final String id;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return slidePage(
      key: state.pageKey,
      child: RecordEditPage(recordId: id),
    );
  }
}
