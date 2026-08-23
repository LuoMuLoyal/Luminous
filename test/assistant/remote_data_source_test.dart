import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart' as lucent;
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/error_code.dart';
import 'package:luminous/features/assistant/data/datasources/assistant.dart';

/// Adapter that returns a JSON response with configurable body.
class _JsonAdapter implements HttpClientAdapter {
  _JsonAdapter() : statusCode = 200, responseBody = null;

  Object? responseBody;
  int statusCode;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final body = jsonEncode(responseBody);

    return ResponseBody.fromString(
      body,
      statusCode,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }
}

void main() {
  group('AssistantRemoteDataSource — non-stream methods', () {
    late _JsonAdapter adapter;
    late Dio dio;
    late lucent.AssistantApi api;

    setUp(() {
      adapter = _JsonAdapter();
      dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
      dio.httpClientAdapter = adapter;
      api = lucent.AssistantApi(dio);
    });

    test('getCapabilities returns data', () async {
      adapter.responseBody = {
        'phase': 'beta',
        'assistantEnabled': true,
        'assistantMemoryEnabled': true,
        'assistantContext': {
          'healthProfile': true,
          'dailyRecords': true,
          'sleepRecords': false,
          'currentMedicines': true,
        },
        'chatModelConfigured': true,
        'interactiveChatReady': true,
        'langGraphReady': true,
        'streamingSupported': true,
        'streamingTransport': 'sse',
        'markdownRenderingRecommended': true,
        'ragEnabled': false,
        'tools': [],
        'updatedAt': '2026-07-11T08:00:00.000Z',
      };

      final ds = AssistantRemoteDataSource(api: api, dio: dio);
      final result = await ds.getCapabilities();

      expect(result.phase, 'beta');
      expect(result.assistantEnabled, isTrue);
      expect(result.assistantMemoryEnabled, isTrue);
    });

    test('getLatestConversation returns data', () async {
      adapter.responseBody = {
        'id': 'conv-1',
        'title': 'Test Conversation',
        'status': 'active',
        'messages': [],
        'lastMessageAt': '2026-07-11T09:00:00.000Z',
        'createdAt': '2026-07-11T08:00:00.000Z',
        'updatedAt': '2026-07-11T09:00:00.000Z',
      };

      final ds = AssistantRemoteDataSource(api: api, dio: dio);
      final result = await ds.getLatestConversation();

      expect(result, isNotNull);
      expect(result!.id, 'conv-1');
    });

    test('listRecentConversations returns list', () async {
      adapter.responseBody = [
        {
          'id': 'conv-1',
          'title': 'Conv 1',
          'status': 'active',
          'lastMessageAt': '2026-07-11T09:00:00.000Z',
          'createdAt': '2026-07-11T08:00:00.000Z',
          'updatedAt': '2026-07-11T09:00:00.000Z',
        },
        {
          'id': 'conv-2',
          'title': 'Conv 2',
          'status': 'active',
          'lastMessageAt': '2026-07-11T10:00:00.000Z',
          'createdAt': '2026-07-11T10:00:00.000Z',
          'updatedAt': '2026-07-11T11:00:00.000Z',
        },
      ];

      final ds = AssistantRemoteDataSource(api: api, dio: dio);
      final result = await ds.listRecentConversations();

      expect(result.length, 2);
      expect(result[0].id, 'conv-1');
      expect(result[1].id, 'conv-2');
    });

    test('openConversation passes conversationId', () async {
      adapter.responseBody = {
        'id': 'conv-1',
        'title': 'Test',
        'status': 'active',
        'messages': [],
        'lastMessageAt': '2026-07-11T09:00:00.000Z',
        'createdAt': '2026-07-11T08:00:00.000Z',
        'updatedAt': '2026-07-11T09:00:00.000Z',
      };

      final ds = AssistantRemoteDataSource(api: api, dio: dio);
      final result = await ds.openConversation('conv-1');

      expect(result.id, 'conv-1');
    });

    test('clearLatestConversation returns cleared flag', () async {
      adapter.responseBody = {
        'cleared': true,
        'archivedConversationId': 'conv-archived-1',
      };

      final ds = AssistantRemoteDataSource(api: api, dio: dio);
      final result = await ds.clearLatestConversation();

      expect(result, isTrue);
    });

    test('renameConversation returns the updated conversation', () async {
      adapter.responseBody = {
        'id': 'conv-1',
        'title': '新标题',
        'status': 'active',
        'messages': [
          {
            'role': 'user',
            'content': 'hello',
            'usedTools': <String>[],
            'createdAt': '2026-07-01T10:00:00Z',
          },
        ],
        'lastMessageAt': '2026-07-01T10:00:00Z',
        'createdAt': '2026-07-01T09:00:00Z',
        'updatedAt': '2026-07-01T10:00:00Z',
      };

      final ds = AssistantRemoteDataSource(api: api, dio: dio);
      final result = await ds.renameConversation(
        conversationId: 'conv-1',
        title: '新标题',
      );

      expect(result.id, 'conv-1');
      expect(result.title, '新标题');
    });

    test('deleteConversation resolves without payload requirements', () async {
      adapter.responseBody = {
        'id': 'conv-1',
        'title': '旧标题',
        'status': 'deleted',
        'messages': <Object?>[],
        'lastMessageAt': null,
        'createdAt': '2026-07-01T09:00:00Z',
        'updatedAt': '2026-07-01T10:00:00Z',
      };

      final ds = AssistantRemoteDataSource(api: api, dio: dio);
      await expectLater(ds.deleteConversation('conv-1'), completes);
    });

    test(
      'empty success body is a LucentFailure.network(emptyResponse)',
      () async {
        adapter.responseBody = null;

        final ds = AssistantRemoteDataSource(api: api, dio: dio);
        await expectLater(
          ds.getCapabilities(),
          throwsA(
            isA<LucentFailure>()
                .having(
                  (failure) => failure.networkErrorCode,
                  'networkErrorCode',
                  NetworkErrorCode.emptyResponse,
                )
                .having(
                  (failure) => failure.kind,
                  'kind',
                  LucentFailureKind.network,
                ),
          ),
        );
      },
    );
  });
}
