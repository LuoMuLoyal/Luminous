import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/network/network_providers.dart';
import 'package:luminous/core/providers/auth_guarded.dart';

/// Fetches the authenticated user's de-identified clinic summary preview.
///
/// Calls `POST /api/v1/user/reports/clinic-summary/preview` which returns
/// a [ClinicSummaryDto] with masked profile fields.
final clinicSummaryPreviewProvider =
    FutureProvider.autoDispose<ClinicSummaryDto>((ref) async {
      return authGuarded(
        ref: ref,
        fetch: () {
          final api = ref.watch(lucentClientProvider).reports;
          return api.reportsControllerPreviewClinicSummaryV1().then(
            (r) => r.data!,
          );
        },
        signedOutFallback: () => pendingAuthSessionResolution(),
      );
    });

/// Fetches a shared clinic summary by its public token.
///
/// Calls `GET /api/v1/user/reports/clinic-summary/shared/{token}` — no
/// authentication required. Used by the public deep-link share page.
final clinicSummarySharedProvider = FutureProvider.autoDispose
    .family<ClinicSummaryDto, String>((ref, token) async {
      final api = ref.watch(lucentClientProvider).reports;
      return api
          .reportsControllerGetSharedClinicSummaryV1(token: token)
          .then((r) => r.data!);
    });
