import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/network/client/client_providers.dart';
import 'package:luminous/core/providers/auth_guarded.dart';

/// All six selectable clinic summary fields, in display order.
const kClinicSummaryAllFields =
    <ReportsControllerPreviewClinicSummaryV1RequestSelectedFieldsEnum>[
      ReportsControllerPreviewClinicSummaryV1RequestSelectedFieldsEnum
          .eventOverview,
      ReportsControllerPreviewClinicSummaryV1RequestSelectedFieldsEnum
          .symptomChanges,
      ReportsControllerPreviewClinicSummaryV1RequestSelectedFieldsEnum
          .medicationSlots,
      ReportsControllerPreviewClinicSummaryV1RequestSelectedFieldsEnum.water,
      ReportsControllerPreviewClinicSummaryV1RequestSelectedFieldsEnum.sleep,
      ReportsControllerPreviewClinicSummaryV1RequestSelectedFieldsEnum.notes,
    ];

/// Default field selection: every field except the free-text notes.
///
/// Notes stay off by default (privacy): the user must opt in to include the
/// free-text notes in the preview / PDF / share.
const kClinicSummaryDefaultFields =
    <ReportsControllerPreviewClinicSummaryV1RequestSelectedFieldsEnum>[
      ReportsControllerPreviewClinicSummaryV1RequestSelectedFieldsEnum
          .eventOverview,
      ReportsControllerPreviewClinicSummaryV1RequestSelectedFieldsEnum
          .symptomChanges,
      ReportsControllerPreviewClinicSummaryV1RequestSelectedFieldsEnum
          .medicationSlots,
      ReportsControllerPreviewClinicSummaryV1RequestSelectedFieldsEnum.water,
      ReportsControllerPreviewClinicSummaryV1RequestSelectedFieldsEnum.sleep,
    ];

/// Fetches the authenticated user's de-identified clinic summary preview.
///
/// Calls `POST /api/v1/user/reports/clinic-summary/preview` with the given
/// [selectedFields]; the server applies the selection so deselected sections
/// are omitted from the response (and from the PDF / share, which consume the
/// same filtered view).
final clinicSummaryPreviewProvider = FutureProvider.autoDispose
    .family<
      ClinicSummaryResponseDto,
      List<ReportsControllerPreviewClinicSummaryV1RequestSelectedFieldsEnum>
    >((ref, selectedFields) async {
      return authGuarded(
        ref: ref,
        fetch: () => _fetchPreview(ref, selectedFields),
        signedOutFallback: () => pendingAuthSessionResolution(),
      );
    });

Future<ClinicSummaryResponseDto> _fetchPreview(
  Ref ref,
  List<ReportsControllerPreviewClinicSummaryV1RequestSelectedFieldsEnum>
  selectedFields,
) async {
  final api = ref.watch(lucentClientProvider).reports;
  final response = await api.reportsControllerPreviewClinicSummaryV1(
    reportsControllerPreviewClinicSummaryV1Request:
        ReportsControllerPreviewClinicSummaryV1Request(
          selectedFields: selectedFields,
        ),
  );
  return response.data!;
}

/// Fetches a shared clinic summary by its public token.
///
/// Calls `GET /api/v1/user/reports/clinic-summary/shared/{token}` — no
/// authentication required. Used by the public deep-link share page.
final clinicSummarySharedProvider = FutureProvider.autoDispose
    .family<ClinicSummaryResponseDto, String>((ref, token) async {
      final api = ref.watch(lucentClientProvider).reports;
      final response = await api.reportsControllerGetSharedClinicSummaryV1(
        token: token,
        extra: const {'skipAuthorization': true},
      );
      return response.data!;
    });

/// The current user's clinic summary shares, newest first.
///
/// Calls `GET /api/v1/user/reports/clinic-summary/shares`. Revoked shares
/// stay listed so the owner can see what was revoked.
final clinicSummaryShareListProvider =
    AsyncNotifierProvider<
      ClinicSummaryShareList,
      List<ClinicSummaryShareListItemDto>
    >(ClinicSummaryShareList.new);

class ClinicSummaryShareList
    extends AsyncNotifier<List<ClinicSummaryShareListItemDto>> {
  @override
  Future<List<ClinicSummaryShareListItemDto>> build() {
    return authGuarded(
      ref: ref,
      fetch: () async {
        final api = ref.watch(lucentClientProvider).reports;
        final response = await api.reportsControllerListClinicSummarySharesV1();
        return response.data?.items ?? const [];
      },
      signedOutFallback: () => pendingAuthSessionResolution(),
    );
  }

  /// Revokes [shareId] (`DELETE /user/reports/clinic-summary/shares/{shareId}`)
  /// and refreshes the list so the revoked state is reflected immediately.
  Future<void> revoke(String shareId) async {
    final api = ref.read(lucentClientProvider).reports;
    await api.reportsControllerRevokeClinicSummaryShareV1(shareId: shareId);
    ref.invalidateSelf();
  }
}
