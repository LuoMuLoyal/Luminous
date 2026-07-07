import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/features/record/domain/entities/type_mapping.dart';
import 'package:luminous/features/record/presentation/pages/create.dart';
import 'package:luminous/features/record/presentation/pages/detail.dart';
import 'package:luminous/features/record/presentation/pages/edit.dart';
import 'package:luminous/features/record/presentation/utils/date_time_formatters.dart';

import 'helpers.dart';

final recordRoutes = [
  GoRoute(
    path: AppRoutes.recordCreate,
    pageBuilder: (context, state) => slidePage(
      key: state.pageKey,
      child: RecordCreatePage(
        initialKind: dailyRecordKindFromName(state.uri.queryParameters['kind']),
        initialDate: parseRecordDate(state.uri.queryParameters['date']),
        initialTime: state.uri.queryParameters['time'],
      ),
    ),
  ),
  GoRoute(
    path: '/record/:id',
    pageBuilder: (context, state) => slidePage(
      key: state.pageKey,
      child: RecordDetailPage(recordId: state.pathParameters['id']!),
    ),
  ),
  GoRoute(
    path: '/record/:id/edit',
    pageBuilder: (context, state) => slidePage(
      key: state.pageKey,
      child: RecordEditPage(recordId: state.pathParameters['id']!),
    ),
  ),
];
