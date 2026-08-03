import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/network/client_providers.dart';
import 'package:luminous/core/network/dio_client.dart';
import 'package:luminous/features/report/presentation/providers/clinic_summary.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_helpers.dart';

class _MockReportsApi extends Mock implements ReportsApi {}

class _FakeLucentClient extends LucentClient {
  _FakeLucentClient({required this.reportsApi}) : super(LucentApi(dio: Dio()));

  final ReportsApi reportsApi;

  @override
  ReportsApi get reports => reportsApi;
}

ClinicSummaryDto _dto({List<String>? findings}) {
  return ClinicSummaryDto(
    generatedAt: '2026-07-01T10:30:00',
    dataRange: 'last_7_days',
    profile: ClinicSummaryProfileDto(
      nickname: 'Lumi',
      age: 30,
      sexAtBirth: 'male',
      bloodType: 'A',
    ),
    allergies: const ['青霉素'],
    conditions: const ['高血压'],
    currentMedicines: const ['阿莫西林'],
    findings: findings,
    disclaimer: '本摘要仅供参考',
  );
}

void main() {
  late _MockReportsApi reportsApi;
  late _FakeLucentClient client;

  setUp(() {
    reportsApi = _MockReportsApi();
    client = _FakeLucentClient(reportsApi: reportsApi);
  });

  ProviderContainer makeContainer() {
    final c = ProviderContainer(
      overrides: [
        authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
        lucentClientProvider.overrideWithValue(client),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  group('clinicSummaryPreviewProvider', () {
    test('returns the clinic summary for authenticated users', () async {
      when(
        () => reportsApi.reportsControllerPreviewClinicSummaryV1(),
      ).thenAnswer(
        (_) async => Response<ClinicSummaryDto>(
          data: _dto(),
          requestOptions: RequestOptions(path: '/preview'),
          statusCode: 200,
        ),
      );

      final c = makeContainer();
      final dto = await c.read(clinicSummaryPreviewProvider.future);

      expect(dto.profile.nickname, 'Lumi');
      expect(dto.allergies, ['青霉素']);
      expect(dto.disclaimer, '本摘要仅供参考');
      verify(
        () => reportsApi.reportsControllerPreviewClinicSummaryV1(),
      ).called(1);
    });

    test('propagates API errors', () async {
      when(
        () => reportsApi.reportsControllerPreviewClinicSummaryV1(),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/preview'),
          type: DioExceptionType.connectionError,
        ),
      );

      final c = makeContainer();
      // Keep the autoDispose provider alive while the error propagates.
      final sub = c.listen<AsyncValue<ClinicSummaryDto>>(
        clinicSummaryPreviewProvider,
        (_, __) {},
      );
      addTearDown(sub.close);

      await expectLater(
        c.read(clinicSummaryPreviewProvider.future),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('clinicSummarySharedProvider', () {
    test('fetches a shared summary by token', () async {
      when(
        () => reportsApi.reportsControllerGetSharedClinicSummaryV1(
          token: 'abc123',
        ),
      ).thenAnswer(
        (_) async => Response<ClinicSummaryDto>(
          data: _dto(findings: const ['发现一条']),
          requestOptions: RequestOptions(path: '/shared'),
          statusCode: 200,
        ),
      );

      final c = ProviderContainer(
        overrides: [lucentClientProvider.overrideWithValue(client)],
      );
      addTearDown(c.dispose);

      final dto = await c.read(clinicSummarySharedProvider('abc123').future);

      expect(dto.dataRange, 'last_7_days');
      expect(dto.findings, ['发现一条']);
      verify(
        () => reportsApi.reportsControllerGetSharedClinicSummaryV1(
          token: 'abc123',
        ),
      ).called(1);
    });

    test('is per-token cached', () async {
      when(
        () => reportsApi.reportsControllerGetSharedClinicSummaryV1(
          token: any(named: 'token'),
        ),
      ).thenAnswer(
        (_) async => Response<ClinicSummaryDto>(
          data: _dto(),
          requestOptions: RequestOptions(path: '/shared'),
          statusCode: 200,
        ),
      );

      final c = ProviderContainer(
        overrides: [lucentClientProvider.overrideWithValue(client)],
      );
      addTearDown(c.dispose);

      await c.read(clinicSummarySharedProvider('a').future);
      await c.read(clinicSummarySharedProvider('b').future);

      verify(
        () => reportsApi.reportsControllerGetSharedClinicSummaryV1(token: 'a'),
      ).called(1);
      verify(
        () => reportsApi.reportsControllerGetSharedClinicSummaryV1(token: 'b'),
      ).called(1);
    });
  });
}
