import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucent_api/api/export.dart';
import 'package:luminous/core/network/network_providers.dart';

/// Fetches the authenticated user's de-identified clinic summary preview.
///
/// Calls `POST /api/v1/user/reports/clinic-summary/preview` which returns
/// a [ClinicSummaryDto] with masked profile fields.
final clinicSummaryPreviewProvider =
    FutureProvider.autoDispose<ClinicSummaryDto>((ref) async {
      final api = ref.watch(lucentClientProvider).reports;
      return api.reportsControllerPreviewClinicSummaryV1();
    });

/// Fetches a shared clinic summary by its public token.
///
/// Calls `GET /api/v1/user/reports/clinic-summary/shared/{token}` — no
/// authentication required. Used by the public deep-link share page.
final clinicSummarySharedProvider = FutureProvider.autoDispose
    .family<ClinicSummaryDto, String>((ref, token) async {
      final api = ref.watch(lucentClientProvider).reports;
      return api.reportsControllerGetSharedClinicSummaryV1(token: token);
    });
