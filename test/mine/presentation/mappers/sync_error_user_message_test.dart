import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/database/daos/pending_sync.dart';
import 'package:luminous/core/database/models/pending_sync_error_details.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/errors/network_error_l10n.dart';
import 'package:luminous/core/network/contract/error_code.dart';
import 'package:luminous/features/mine/presentation/mappers/sync_error_user_message.dart';
import 'package:luminous/l10n/app_localizations.dart';

PendingSyncEntry _entry({PendingSyncErrorDetails? details}) => PendingSyncEntry(
  id: 'pending-1',
  entityType: 'daily_record',
  entityId: 'record-1',
  operation: 'update',
  payload: '{}',
  createdAt: DateTime(2026, 8, 2, 12, 0),
  retryCount: 5,
  maxRetry: 5,
  lastError: 'raw exception',
  errorDetails: details,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('zh'));
  });

  test('network-layer error code maps via NetworkErrorL10n', () {
    final message = mapSyncErrorToUserMessage(
      _entry(
        details: const PendingSyncErrorDetails(
          networkErrorCode: NetworkErrorCode.connectionError,
          kind: LucentFailureKind.network,
        ),
      ),
      l10n,
    );
    expect(
      message,
      NetworkErrorL10n.map(NetworkErrorCode.connectionError, l10n),
    );
  });

  test('business validation failure maps to the data-invalid message by '
      'Problem Details code', () {
    final message = mapSyncErrorToUserMessage(
      _entry(
        details: const PendingSyncErrorDetails(
          code: 'VALIDATION_FAILED',
          statusCode: 400,
          kind: LucentFailureKind.business,
        ),
      ),
      l10n,
    );
    expect(message, l10n.mineSyncFailedErrorDataInvalid);
  });

  test('auth kind maps to the auth message', () {
    final message = mapSyncErrorToUserMessage(
      _entry(
        details: const PendingSyncErrorDetails(
          kind: LucentFailureKind.authentication,
          statusCode: 401,
        ),
      ),
      l10n,
    );
    expect(message, l10n.mineSyncFailedErrorAuth);
  });

  test('server kind maps to the server message', () {
    final message = mapSyncErrorToUserMessage(
      _entry(
        details: const PendingSyncErrorDetails(
          kind: LucentFailureKind.server,
          statusCode: 500,
        ),
      ),
      l10n,
    );
    expect(message, l10n.mineSyncFailedErrorServer);
  });

  test('network kind without a specific code maps to the network message', () {
    final message = mapSyncErrorToUserMessage(
      _entry(
        details: const PendingSyncErrorDetails(
          kind: LucentFailureKind.network,
          networkErrorCode: null,
        ),
      ),
      l10n,
    );
    expect(message, l10n.mineSyncFailedErrorNetwork);
  });

  test('unknown kind and null details fall back to the unknown message', () {
    final unknownKind = mapSyncErrorToUserMessage(
      _entry(
        details: const PendingSyncErrorDetails(kind: LucentFailureKind.unknown),
      ),
      l10n,
    );
    expect(unknownKind, l10n.mineSyncFailedErrorUnknown);

    final nullDetails = mapSyncErrorToUserMessage(_entry(), l10n);
    expect(nullDetails, l10n.mineSyncFailedErrorUnknown);
  });
}
