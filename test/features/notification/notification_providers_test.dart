import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import '../../auth/auth_test_helpers.dart' as auth_helpers;
import 'package:luminous/core/network/lucent_network_providers.dart';
import 'package:luminous/features/auth/presentation/providers/session/auth_session_provider.dart';
import 'package:luminous/features/notification/presentation/providers/notification_providers.dart';

// ── Fake NotificationsApi ───────────────────────────────────────────────────

class FakeNotificationsApi implements NotificationsApi {
  FakeNotificationsApi({
    this.unreadCount = 0,
    this.notifications = const [],
    this.detail,
    this.shouldThrow = false,
  });

  int unreadCount;
  List<NotificationListItemDto> notifications;
  NotificationDetailDto? detail;
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
    return Response<UnreadCountResponseDto>(
      data: UnreadCountResponseDto(code: 0, message: '', count: unreadCount),
      requestOptions: RequestOptions(
        path: '/api/v1/user/notifications/unread-count',
      ),
    );
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
    return Response<NotificationListResponseDto>(
      data: NotificationListResponseDto(
        code: 0,
        message: '',
        items: notifications,
        total: notifications.length,
      ),
      requestOptions: RequestOptions(path: '/api/v1/user/notifications'),
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
    return Response<NotificationDetailResponseDto>(
      data: NotificationDetailResponseDto(code: 0, message: '', data: detail),
      requestOptions: RequestOptions(path: '/api/v1/user/notifications/$id'),
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
    return Response<void>(
      data: null,
      requestOptions: RequestOptions(path: '/api/v1/user/notifications/$id'),
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
    return Response<UnreadCountResponseDto>(
      data: UnreadCountResponseDto(code: 0, message: '', count: 0),
      requestOptions: RequestOptions(
        path: '/api/v1/user/notifications/mark-all-read',
      ),
    );
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
    return Response<NotificationListResponseDto>(
      data: null,
      requestOptions: RequestOptions(path: '/api/v1/user/notifications'),
    );
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
    return Response<NotificationDetailResponseDto>(
      data: null,
      requestOptions: RequestOptions(
        path: '/api/v1/user/notifications/$id/read',
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
    return Response<NotificationDetailResponseDto>(
      data: null,
      requestOptions: RequestOptions(
        path: '/api/v1/user/notifications/$id/unread',
      ),
    );
  }
}

// ── Error-returning API for throws test ──────────────────────────────────────

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
    return Response<UnreadCountResponseDto>(
      data: UnreadCountResponseDto(
        code: 500001,
        message: 'Server error',
        count: 0,
      ),
      requestOptions: RequestOptions(path: ''),
    );
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
    type: UserNotificationType.systemAnnouncement,
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
          lucentNotificationsApiProvider.overrideWithValue(api),
        ],
      );
      addTearDown(container.dispose);

      final count = await container.read(
        notificationUnreadCountProvider.future,
      );
      expect(count, equals(3));
    });

    test('throws StateError when API returns non-zero code', () async {
      final errorApi = _ErrorUnreadCountApi();
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(() => signedInSession),
          lucentNotificationsApiProvider.overrideWithValue(errorApi),
        ],
      );
      addTearDown(container.dispose);

      expect(
        container.read(notificationUnreadCountProvider.future),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('notificationListPageProvider', () {
    test('returns paginated notification list', () async {
      final api = FakeNotificationsApi(
        notifications: [
          _item(id: '1', title: 'First'),
          _item(id: '2', title: 'Second'),
        ],
      );
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(() => signedInSession),
          lucentNotificationsApiProvider.overrideWithValue(api),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(notificationListPageProvider.future);
      expect(result.items, hasLength(2));
      expect(result.items[0].title, equals('First'));
    });
  });

  group('notificationDetailProvider', () {
    test('returns notification detail', () async {
      final api = FakeNotificationsApi(
        detail: NotificationDetailDto(
          id: 'notif-1',
          type: UserNotificationType.systemAnnouncement,
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
          lucentNotificationsApiProvider.overrideWithValue(api),
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
          lucentNotificationsApiProvider.overrideWithValue(api),
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
          lucentNotificationsApiProvider.overrideWithValue(api),
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
          lucentNotificationsApiProvider.overrideWithValue(api),
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
          lucentNotificationsApiProvider.overrideWithValue(api),
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
          lucentNotificationsApiProvider.overrideWithValue(api),
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
