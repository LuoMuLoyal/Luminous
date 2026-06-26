import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/router/action_route_mapper.dart';

void main() {
  group('mapActionToRoute', () {
    test('returns null for null or empty action', () {
      expect(mapActionToRoute(null), isNull);
      expect(mapActionToRoute(''), isNull);
      expect(mapActionToRoute('   '), isNull);
    });

    test('maps named tab actions to root routes', () {
      expect(mapActionToRoute('today'), '/');
      expect(mapActionToRoute('report'), '/report');
      expect(mapActionToRoute('assistant'), '/assistant');
      expect(mapActionToRoute('medicine'), '/medicine');
      expect(mapActionToRoute('record'), '/record');
      expect(mapActionToRoute('mine'), '/mine');
      expect(mapActionToRoute('settings'), '/settings');
    });

    test('passes through absolute routes', () {
      expect(mapActionToRoute('/report/detail'), '/report/detail');
      expect(mapActionToRoute('/medicine/123'), '/medicine/123');
    });

    test('returns null for unrecognized tokens', () {
      expect(mapActionToRoute('unknown'), isNull);
      expect(mapActionToRoute('report-detail'), isNull);
    });
  });
}
