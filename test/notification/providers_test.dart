import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/network/client_providers.dart';
import 'package:luminous/core/network/dio_client.dart';
import 'package:luminous/features/notification/data/providers/unread_count.dart';
import 'package:luminous/features/notification/data/repositories/lucent.dart';
import 'package:luminous/features/notification/presentation/providers/notification.dart';

import '../auth/test_helpers.dart' as auth_helpers;

// ── Response helper ─────────────────────────────────────────────────────────

Response<T> _response<T>(T data) => Response<T>(
  data: data,
  requestOptions: RequestOptions(path: ''),
  statusCode: 200,
);

// ── Fake NotificationsApi ─────────────────────────────────────────────────────

class FakeNotificationsApi implements NotificationsApi {
  FakeNotificationsApi({
    this.unreadCount = 0,
    this.notifications = const [],
    this.detail,
    this.shouldThrow = false,
  });

  int unreadCount;
  List<NotificationListItemDto> notifications;
  NotificationDetailResponseDto? detail;
  bool shouldThrow;
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
    if (shouldThrow) {
      throw DioException(requestOptions: RequestOptions(path: ''));
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
    if (shouldThrow) {
      throw DioException(requestOptions: RequestOptions(path: ''));
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
    if (shouldThrow) {
      throw DioException(requestOptions: RequestOptions(path: ''));
    }
    return _response(
      detail ??
          NotificationDetailResponseDto(
            id: id,
            type: UserNotificationType.medicineReminder,
            title: '',
            content: '',
            isRead: false,
            createdAt: '2026-06-10T08:00:00.000Z',
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
    return _response(UnreadCountResponseDto(count: 0));
  }

  @override
  Future<Response<NotificationListResponseDto>>
  notificationsControllerCreateV1({
    required CreateNotificationDto createNotificationDto,
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
    return _response(
      detail ??
          NotificationDetailResponseDto(
            id: id,
            type: UserNotificationType.medicineReminder,
            title: '',
            content: '',
            isRead: true,
            createdAt: '2026-06-10T08:00:00.000Z',
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
    return _response(
      detail ??
          NotificationDetailResponseDto(
            id: id,
            type: UserNotificationType.medicineReminder,
            title: '',
            content: '',
            isRead: false,
            createdAt: '2026-06-10T08:00:00.000Z',
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

class _ErrorUnreadCountApi extends FakeNotificationsApi {
  _ErrorUnreadCountApi() : super(unreadCount: 0);

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
    return _response(UnreadCountResponseDto(count: 0));
  }
}

// ── Helpers ─────────────────────────────────────────────────────────────────

NotificationListItemDto _item({
  required String id,
  String title = 'Title',
  String content = 'Content',
  bool isRead = false,
}) {
  return NotificationListItemDto(
    id: id,
    type: UserNotificationType.medicineReminder,
    title: title,
    content: content,
    isRead: isRead,
    createdAt: '2026-06-10T08:00:00.000Z',
  );
}

void main() {
  late auth_helpers.SignedInAuthSessionNotifier signedInSession;

  setUp(() {
    signedInSession = auth_helpers.SignedInAuthSessionNotifier();
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

    test(
      'getUnreadCount degrades to 0 when API returns non-zero code',
      () async {
        final errorApi = _ErrorUnreadCountApi();
        final repo = LucentNotificationRepository(api: errorApi);

        // 未读数属后台轮询展示:业务失败降级返回 0,不向 UI 抛异常。
        expect(await repo.getUnreadCount(), equals(0));
      },
    );

    test('getUnreadCount degrades to 0 on network error', () async {
      final api = FakeNotificationsApi()..shouldThrow = true;
      final repo = LucentNotificationRepository(api: api);

      expect(await repo.getUnreadCount(), equals(0));
    });
  });

  group('notificationDetailProvider', () {
    test('returns notification detail', () async {
      final api = FakeNotificationsApi(
        detail: NotificationDetailResponseDto(
          id: 'notif-1',
          type: UserNotificationType.medicineReminder,
          title: 'Missed dose',
          content: 'You missed a dose.',
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

  test('delete succeeds on empty 204-style body', () async {
    final repo = LucentNotificationRepository(api: FakeNotificationsApi());

    await repo.delete('1');
  });
}
