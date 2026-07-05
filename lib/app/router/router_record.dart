import 'package:go_router/go_router.dart';
import 'package:luminous/features/record/domain/entities/record_type_mapping.dart';
import 'package:luminous/features/record/presentation/pages/record_create.dart';
import 'package:luminous/features/record/presentation/pages/record_detail.dart';
import 'package:luminous/features/record/presentation/pages/record_edit.dart';
import 'package:luminous/features/record/presentation/utils/record_date_time_formatters.dart';

import 'router_helpers.dart';

final recordRoutes = [
  GoRoute(
    path: '/record/create',
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
