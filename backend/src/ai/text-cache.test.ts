import assert from 'node:assert/strict';
import test from 'node:test';

import {
  AI_TEXT_CACHE_TTL_SECONDS,
  buildMedicineAiDetailCacheKey,
  buildMedicineAiSafetyCacheKey,
  loadAiTextWithCache,
} from './text-cache';

test('detail cache key prefers drugCode over approvalNo', () => {
  const key = buildMedicineAiDetailCacheKey({
    drugCode: 'D123',
    approvalNo: 'H123',
    productName: '阿莫西林',
  });
  assert.equal(key, 'ai:detail:v1:D123');
});

test('safety cache key sorts pair identities', () => {
  const key = buildMedicineAiSafetyCacheKey({
    mode: 'pair',
    medicines: [
      { drugCode: '', approvalNo: 'B-002', productName: '乙药' },
      { drugCode: 'A-001', approvalNo: '', productName: '甲药' },
    ],
  });
  assert.equal(key, 'ai:safety:v1:pair:A-001:B-002');
});

test('loadAiTextWithCache returns generated payload and writes ttl on cache miss', async () => {
  let writes: Array<{ key: string; payload: unknown; ttlSeconds: number }> = [];
  let generateCalls = 0;

  const result = await loadAiTextWithCache({
    key: 'ai:detail:v1:D123',
    refresh: false,
    now: () => new Date('2026-04-14T10:00:00.000Z'),
    generate: async () => {
      generateCalls += 1;
      return 'fresh text';
    },
    cacheAccess: {
      read: async () => null,
      write: async (key, payload, ttlSeconds) => {
        writes = [...writes, { key, payload, ttlSeconds }];
      },
    },
  });

  assert.equal(generateCalls, 1);
  assert.equal(result.source, 'generated');
  assert.equal(result.text, 'fresh text');
  assert.equal(result.cachedAt, '2026-04-14T10:00:00.000Z');
  assert.equal(result.expiresAt, '2026-04-21T10:00:00.000Z');
  assert.equal(writes.length, 1);
  assert.equal(writes[0].ttlSeconds, AI_TEXT_CACHE_TTL_SECONDS);
});

test('loadAiTextWithCache returns cached payload without generating', async () => {
  let generateCalls = 0;

  const result = await loadAiTextWithCache({
    key: 'ai:detail:v1:D123',
    refresh: false,
    generate: async () => {
      generateCalls += 1;
      return 'fresh text';
    },
    cacheAccess: {
      read: async () => ({
        text: 'cached text',
        cachedAt: '2026-04-14T08:00:00.000Z',
        expiresAt: '2026-04-21T08:00:00.000Z',
      }),
      write: async () => {
        throw new Error('write should not be called');
      },
    },
  });

  assert.equal(generateCalls, 0);
  assert.equal(result.source, 'cache');
  assert.equal(result.text, 'cached text');
});

test('loadAiTextWithCache bypasses cache and overwrites when refresh=true', async () => {
  let writes = 0;
  let generateCalls = 0;

  const result = await loadAiTextWithCache({
    key: 'ai:safety:v1:single:D123',
    refresh: true,
    now: () => new Date('2026-04-14T12:00:00.000Z'),
    generate: async () => {
      generateCalls += 1;
      return 'refreshed text';
    },
    cacheAccess: {
      read: async () => ({
        text: 'cached text',
        cachedAt: '2026-04-14T08:00:00.000Z',
        expiresAt: '2026-04-21T08:00:00.000Z',
      }),
      write: async () => {
        writes += 1;
      },
    },
  });

  assert.equal(generateCalls, 1);
  assert.equal(writes, 1);
  assert.equal(result.source, 'generated');
  assert.equal(result.text, 'refreshed text');
});
