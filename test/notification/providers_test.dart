import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/client/client_providers.dart';
import 'package:luminous/core/network/client/dio_client.dart';
import 'package:luminous/core/network/contract/error_code.dart';
import 'package:luminous/features/notification/data/providers/unread_count.dart';
import 'package:luminous/features/notification/data/repositories/lucent.dart';
import 'package:luminous/features/notification/presentation/providers/notification.dart';

import '../auth/test_helpers.dart' as auth_helpers;
import '../helpers/task_either.dart';

// ── Response helper ─────────────────────────────────────────────────────────

Response<T> _response<T>(T data) => Response<T>(
  data: data,
  requestOptions: RequestOptions(path: ''),
  statusCode: 200,
);

/// A 404 RFC 9457 Problem Details body served with
/// `application/problem+json` (server business failure).
DioException _problemDetails404({
  String code = 'NOTIFICATION_UNREAD_COUNT_ERR',
}) {
  return DioException(
    requestOptions: RequestOptions(path: '/api/v1/notifications/unread-count'),
    type: DioExceptionType.badResponse,
    response: Response(
      requestOptions: RequestOptions(
        path: '/api/v1/notifications/unread-count',
      ),
      statusCode: 404,
      headers: Headers.fromMap({
        Headers.contentTypeHeader: ['application/problem+json'],
      }),
      data: {
        'type': 'https://api.lumos.example/problems/$code',
        'title': 'Not found',
        'detail': '通知资源不存在',
        'code': code,
      },
    ),
  );
}

/// A 500 error body served as `text/html` — not Problem Details (protocol
/// invariant violation) — so `.run()` propagates `FormatException`.
DioException _nonProblemHtml500() {
  return DioException(
    requestOptions: RequestOptions(path: '/api/v1/notifications'),
    type: DioExceptionType.badResponse,
    response: Response(
      requestOptions: RequestOptions(path: '/api/v1/notifications'),
      statusCode: 500,
      headers: Headers.fromMap({
        Headers.contentTypeHeader: ['text/html'],
      }),
      data: '<html><body>Internal Server Error</body></html>',
    ),
  );
}

// ── Fake NotificationsApi ─────────────────────────────────────────────────────

class FakeNotificationsApi implements NotificationsApi {
  FakeNotificationsApi({
    this.unreadCount = 0,
    this.notifications = const [],
    this.detail,
    this.shouldThrow = false,
    this.error,
    this.nullFindAllBody = false,
    this.nullUnreadCountBody = false,
  });

  int unreadCount;
  List<NotificationListResponseDtoItemsInner> notifications;
  NotificationDetailResponseDto? detail;
  bool shouldThrow;
  DioException? error;
  bool nullFindAllBody;
  bool nullUnreadCountBody;
  int findAllCallCount = 0;

  @override
  Future<Response<UnreadCountResponseDto>>
  notificationsControllerGetUnreadCountV1({
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    if (error != null) throw error!;
    if (shouldThrow) {
      throw DioException(requestOptions: RequestOptions(path: ''));
    }
    if (nullUnreadCountBody) {
      return Response<UnreadCountResponseDto>(
        data: null,
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
      );
    }
    return _response(UnreadCountResponseDto(count: unreadCount));
  }

  @override
  Future<Response<NotificationListResponseDto>>
  notificationsControllerFindAllV1({
    required num page,
    required num pageSize,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    findAllCallCount++;
    if (error != null) throw error!;
    if (shouldThrow) {
      throw DioException(requestOptions: RequestOptions(path: ''));
    }
    if (nullFindAllBody) {
      return Response<NotificationListResponseDto>(
        data: null,
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
      );
    }
    return _response(
      NotificationListResponseDto(
        items: notifications,
        total: notifications.length,
      ),
    );
  }

  @override
  Future<Response<NotificationDetailResponseDto>>
  notificationsControllerFindOneV1({
    required String id,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    if (error != null) throw error!;
    if (shouldThrow) {
      throw DioException(requestOptions: RequestOptions(path: ''));
    }
    return _response(
      detail ??
          NotificationDetailResponseDto(
            id: id,
            type: NotificationDetailResponseDtoTypeEnum.medicineReminder,
            title: '',
            content: '',
            action: null,
            actionPayload: null,
            isRead: false,
            createdAt: '2026-06-10T08:00:00.000Z',
            readAt: null,
          ),
    );
  }

  @override
  Future<Response<void>> notificationsControllerRemoveV1({
    required String id,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    if (error != null) throw error!;
    if (shouldThrow) {
      throw DioException(requestOptions: RequestOptions(path: ''));
    }
    // 运行时类型与生成客户端一致(Response<Object>),允许仓库读取响应体。
    return Response<Object>(
      data: null,
      requestOptions: RequestOptions(path: ''),
      statusCode: 200,
    );
  }

  @override
  Future<Response<UnreadCountResponseDto>>
  notificationsControllerMarkAllAsReadV1({
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    if (error != null) throw error!;
    if (shouldThrow) {
      throw DioException(requestOptions: RequestOptions(path: ''));
    }
    return _response(UnreadCountResponseDto(count: 0));
  }

  @override
  Future<Response<NotificationListResponseDto>>
  notificationsControllerCreateV1({
    required NotificationsControllerCreateV1Request
    notificationsControllerCreateV1Request,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _response(NotificationListResponseDto(items: [], total: 0));
  }

  @override
  Future<Response<NotificationDetailResponseDto>>
  notificationsControllerMarkAsReadV1({
    required String id,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    if (error != null) throw error!;
    if (shouldThrow) {
      throw DioException(requestOptions: RequestOptions(path: ''));
    }
    return _response(
      detail ??
          NotificationDetailResponseDto(
            id: id,
            type: NotificationDetailResponseDtoTypeEnum.medicineReminder,
            title: '',
            content: '',
            action: null,
            actionPayload: null,
            isRead: true,
            createdAt: '2026-06-10T08:00:00.000Z',
            readAt: null,
          ),
    );
  }

  @override
  Future<Response<NotificationDetailResponseDto>>
  notificationsControllerMarkAsUnreadV1({
    required String id,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    if (error != null) throw error!;
    if (shouldThrow) {
      throw DioException(requestOptions: RequestOptions(path: ''));
    }
    return _response(
      detail ??
          NotificationDetailResponseDto(
            id: id,
            type: NotificationDetailResponseDtoTypeEnum.medicineReminder,
            title: '',
            content: '',
            action: null,
            actionPayload: null,
            isRead: false,
            createdAt: '2026-06-10T08:00:00.000Z',
            readAt: null,
          ),
    );
  }
}

// ── Error-returning API for throws test ──────────────────────────────────────

/// A [LucentClient] subclass that returns a fake [NotificationsApi].
class _FakeLucentClient extends LucentClient {
  _FakeLucentClient({required this.notificationsApi})
    : super(LucentApi(dio: Dio()));

  final NotificationsApi notificationsApi;

  @override
  NotificationsApi get notifications => notificationsApi;
}

// ── Helpers ─────────────────────────────────────────────────────────────────

NotificationListResponseDtoItemsInner _item({
  required String id,
  String title = 'Title',
  String content = 'Content',
  bool isRead = false,
}) {
  return NotificationListResponseDtoItemsInner(
    id: id,
    type: NotificationListResponseDtoItemsInnerTypeEnum.medicineReminder,
    title: title,
    content: content,
    action: null,
    actionPayload: null,
    isRead: isRead,
    createdAt: '2026-06-10T08:00:00.000Z',
  );
}

void main() {
  late auth_helpers.SignedInAuthSessionNotifier signedInSession;

  setUp(() {
    signedInSession = auth_helpers.SignedInAuthSessionNotifier();
  });

  group('LucentNotificationRepository', () {
    test('getUnreadCount returns the count as Right', () async {
      final repo = LucentNotificationRepository(
        api: FakeNotificationsApi(unreadCount: 3),
      );

      final count = await expectTaskRight(repo.getUnreadCount());
      expect(count, equals(3));
    });

    test('getUnreadCount maps a network error to Left(network)', () async {
      final repo = LucentNotificationRepository(
        api: FakeNotificationsApi()..shouldThrow = true,
      );

      final failure = await expectTaskLeft(repo.getUnreadCount());
      expect(failure.kind, LucentFailureKind.network);
    });

    test(
      'getUnreadCount keeps 404 Problem Details code/status as Left',
      () async {
        final repo = LucentNotificationRepository(
          api: FakeNotificationsApi(error: _problemDetails404()),
        );

        final failure = await expectTaskLeft(repo.getUnreadCount());
        expect(failure.code, 'NOTIFICATION_UNREAD_COUNT_ERR');
        expect(failure.statusCode, 404);
        expect(failure.kind, LucentFailureKind.business);
      },
    );

    test(
      'getUnreadCount empty success body is Left(network/emptyResponse)',
      () async {
        final repo = LucentNotificationRepository(
          api: FakeNotificationsApi()..nullUnreadCountBody = true,
        );

        final failure = await expectTaskLeft(repo.getUnreadCount());
        expect(failure.kind, LucentFailureKind.network);
        expect(failure.networkErrorCode, NetworkErrorCode.emptyResponse);
      },
    );

    test('findAll maps a network error to Left(network)', () async {
      final repo = LucentNotificationRepository(
        api: FakeNotificationsApi()..shouldThrow = true,
      );

      final failure = await expectTaskLeft(repo.findAll(page: 1, pageSize: 20));
      expect(failure.kind, LucentFailureKind.network);
    });

    test('findAll empty success body is Left(network/emptyResponse)', () async {
      final repo = LucentNotificationRepository(
        api: FakeNotificationsApi()..nullFindAllBody = true,
      );

      final failure = await expectTaskLeft(repo.findAll(page: 1, pageSize: 20));
      expect(failure.kind, LucentFailureKind.network);
      expect(failure.networkErrorCode, NetworkErrorCode.emptyResponse);
    });

    test('findOne keeps 404 Problem Details code/status as Left', () async {
      final repo = LucentNotificationRepository(
        api: FakeNotificationsApi(error: _problemDetails404()),
      );

      final failure = await expectTaskLeft(repo.findOne('missing-id'));
      expect(failure.code, 'NOTIFICATION_UNREAD_COUNT_ERR');
      expect(failure.statusCode, 404);
      expect(failure.kind, LucentFailureKind.business);
    });

    test('findOne non-Problem Details error body propagates FormatException '
        'from run()', () async {
      final repo = LucentNotificationRepository(
        api: FakeNotificationsApi(error: _nonProblemHtml500()),
      );

      // 协议违反（500 + text/html 而非 problem+json）保持 mapper 抛出的
      // FormatException 从 .run() 传播，而不是映射成 Left。
      await expectLater(
        repo.findOne('id').run(),
        throwsA(isA<FormatException>()),
      );
    });

    test('markAllAsRead maps a network error to Left(network)', () async {
      final repo = LucentNotificationRepository(
        api: FakeNotificationsApi()..shouldThrow = true,
      );

      final failure = await expectTaskLeft(repo.markAllAsRead());
      expect(failure.kind, LucentFailureKind.network);
    });

    test('delete succeeds on empty 204-style body', () async {
      final repo = LucentNotificationRepository(api: FakeNotificationsApi());

      await expectTaskRight(repo.delete('1'));
    });

    test('delete maps a network error to Left(network)', () async {
      final repo = LucentNotificationRepository(
        api: FakeNotificationsApi()..shouldThrow = true,
      );

      final failure = await expectTaskLeft(repo.delete('1'));
      expect(failure.kind, LucentFailureKind.network);
    });
  });

  group('notificationUnreadCountProvider', () {
    test('returns unread count', () async {
      final api = FakeNotificationsApi(unreadCount: 3);
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(() => signedInSession),
          lucentClientProvider.overrideWithValue(
            _FakeLucentClient(notificationsApi: api),
          ),
        ],
      );
      addTearDown(container.dispose);

      final count = await container.read(
        notificationUnreadCountProvider.future,
      );
      expect(count, equals(3));
    });

    test('degrades to 0 when the repository returns a Left', () async {
      final api = FakeNotificationsApi()..shouldThrow = true;
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(() => signedInSession),
          lucentClientProvider.overrideWithValue(
            _FakeLucentClient(notificationsApi: api),
          ),
        ],
      );
      addTearDown(container.dispose);

      // 未读徽章属后台轮询类展示:repository Left 时降级为 0,不向 UI 抛错误。
      final count = await container.read(
        notificationUnreadCountProvider.future,
      );
      expect(count, equals(0));
    });

    test(
      'degrades to 0 when a protocol FormatException escapes run()',
      () async {
        final api = FakeNotificationsApi(error: _nonProblemHtml500());
        final container = ProviderContainer(
          overrides: [
            authSessionProvider.overrideWith(() => signedInSession),
            lucentClientProvider.overrideWithValue(
              _FakeLucentClient(notificationsApi: api),
            ),
          ],
        );
        addTearDown(container.dispose);

        // 协议异常（非 problem+json 错误体）逃逸 .run() 时同样降级为 0 并
        // 记录，provider 不停在错误态（today _unreadNotificationsFlag 同款）。
        final count = await container.read(
          notificationUnreadCountProvider.future,
        );
        expect(count, equals(0));
      },
    );
  });

  group('notificationDetailProvider', () {
    test('returns notification detail', () async {
      final api = FakeNotificationsApi(
        detail: NotificationDetailResponseDto(
          id: 'notif-1',
          type: NotificationDetailResponseDtoTypeEnum.medicineReminder,
          title: 'Missed dose',
          content: 'You missed a dose.',
          action: null,
          actionPayload: null,
          isRead: false,
          createdAt: '2026-06-10T08:00:00.000Z',
          readAt: null,
        ),
      );
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(() => signedInSession),
          lucentClientProvider.overrideWithValue(
            _FakeLucentClient(notificationsApi: api),
          ),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(
        notificationDetailProvider('notif-1').future,
      );
      expect(result, isNotNull);
      expect(result!.title, equals('Missed dose'));
    });
  });

  group('NotificationListController', () {
    test('loads initial page on build', () async {
      final api = FakeNotificationsApi(
        notifications: [_item(id: '1', title: 'First')],
      );
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(() => signedInSession),
          lucentClientProvider.overrideWithValue(
            _FakeLucentClient(notificationsApi: api),
          ),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(
        notificationListControllerProvider.future,
      );
      expect(result.items, hasLength(1));
      expect(result.items[0].title, equals('First'));
    });

    test('hasMore returns false when all items loaded', () async {
      final api = FakeNotificationsApi(notifications: [_item(id: '1')]);
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(() => signedInSession),
          lucentClientProvider.overrideWithValue(
            _FakeLucentClient(notificationsApi: api),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(notificationListControllerProvider.future);
      final controller = container.read(
        notificationListControllerProvider.notifier,
      );
      expect(controller.hasMore, isFalse);
    });

    test('loadMore does nothing when hasMore is false', () async {
      final api = FakeNotificationsApi(notifications: [_item(id: '1')]);
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(() => signedInSession),
          lucentClientProvider.overrideWithValue(
            _FakeLucentClient(notificationsApi: api),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(notificationListControllerProvider.future);
      final controller = container.read(
        notificationListControllerProvider.notifier,
      );
      await controller.loadMore();
      // findAllCallCount should remain 1 (only the build call)
      expect(api.findAllCallCount, equals(1));
    });

    test('markAllAsRead refreshes the list', () async {
      final api = FakeNotificationsApi(notifications: [_item(id: '1')]);
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(() => signedInSession),
          lucentClientProvider.overrideWithValue(
            _FakeLucentClient(notificationsApi: api),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(notificationListControllerProvider.future);
      final controller = container.read(
        notificationListControllerProvider.notifier,
      );
      await controller.markAllAsRead();
      final result = container
          .read(notificationListControllerProvider)
          .requireValue;
      expect(result.items, hasLength(1));
    });

    test('deleteNotification refreshes the list', () async {
      final api = FakeNotificationsApi(notifications: [_item(id: '1')]);
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(() => signedInSession),
          lucentClientProvider.overrideWithValue(
            _FakeLucentClient(notificationsApi: api),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(notificationListControllerProvider.future);
      final controller = container.read(
        notificationListControllerProvider.notifier,
      );
      await controller.deleteNotification('1');
      final result = container
          .read(notificationListControllerProvider)
          .requireValue;
      expect(result.items, hasLength(1));
    });
  });
}
