import { tryGetRedisClient } from '../db/redis';
import { MedicineAiTextPayload, MedicineRefInput } from '../types';

const AI_TEXT_CACHE_VERSION = 'v1';
export const AI_TEXT_CACHE_TTL_SECONDS = 7 * 24 * 60 * 60;

type CacheIdentity = Pick<MedicineRefInput, 'drugCode' | 'approvalNo' | 'productName'>;

interface StoredAiTextPayload {
  text: string;
  cachedAt: string;
  expiresAt: string;
}

interface CacheAccess {
  read: (key: string) => Promise<StoredAiTextPayload | null>;
  write: (
    key: string,
    payload: StoredAiTextPayload,
    ttlSeconds: number,
  ) => Promise<void>;
}

interface LoadAiTextWithCacheOptions {
  key: string | null;
  refresh: boolean;
  generate: () => Promise<string>;
  now?: () => Date;
  cacheAccess?: CacheAccess;
}

export function buildMedicineAiDetailCacheKey(
  identitySource: CacheIdentity,
): string | null {
  const identity = resolveIdentity(identitySource);
  if (!identity) {
    return null;
  }
  return `ai:detail:${AI_TEXT_CACHE_VERSION}:${identity}`;
}

export function buildMedicineAiSafetyCacheKey(input: {
  mode: string;
  medicines: CacheIdentity[];
}): string | null {
  const mode = input.mode.trim().toLowerCase();
  if (mode !== 'single' && mode !== 'pair') {
    return null;
  }
  const identities = input.medicines
    .map((item) => resolveIdentity(item, { allowProductNameFallback: true }))
    .filter((item): item is string => item !== null);
  if (
    (mode === 'single' && identities.length !== 1) ||
    (mode === 'pair' && identities.length !== 2)
  ) {
    return null;
  }
  const normalized = mode === 'pair' ? [...identities].sort() : identities;
  return `ai:safety:${AI_TEXT_CACHE_VERSION}:${mode}:${normalized.join(':')}`;
}

export async function loadAiTextWithCache(
  options: LoadAiTextWithCacheOptions,
): Promise<MedicineAiTextPayload> {
  const cacheAccess = options.cacheAccess ?? _defaultCacheAccess;
  if (options.key && !options.refresh) {
    const cached = await cacheAccess.read(options.key);
    if (cached) {
      return {
        text: cached.text,
        source: 'cache',
        cachedAt: cached.cachedAt,
        expiresAt: cached.expiresAt,
      };
    }
  }

  const generatedText = await options.generate();
  const now = (options.now ?? (() => new Date()))();
  const cachedAt = now.toISOString();
  const expiresAt = new Date(
    now.getTime() + AI_TEXT_CACHE_TTL_SECONDS * 1000,
  ).toISOString();

  if (options.key) {
    await cacheAccess.write(
      options.key,
      {
        text: generatedText,
        cachedAt,
        expiresAt,
      },
      AI_TEXT_CACHE_TTL_SECONDS,
    );
  }

  return {
    text: generatedText,
    source: 'generated',
    cachedAt,
    expiresAt,
  };
}

export function resolveIdentity(
  source: CacheIdentity,
  options: { allowProductNameFallback?: boolean } = {},
): string | null {
  const drugCode = String(source.drugCode ?? '').trim();
  if (drugCode) {
    return drugCode;
  }

  const approvalNo = String(source.approvalNo ?? '').trim();
  if (approvalNo) {
    return approvalNo;
  }

  if (options.allowProductNameFallback) {
    const productName = String(source.productName ?? '').trim();
    if (productName) {
      return productName;
    }
  }

  return null;
}

const _defaultCacheAccess: CacheAccess = {
  read: _readCachedAiText,
  write: _writeCachedAiText,
};

async function _readCachedAiText(
  key: string,
): Promise<StoredAiTextPayload | null> {
  const redis = tryGetRedisClient();
  if (!redis) {
    return null;
  }

  try {
    const raw = await redis.get(key);
    if (!raw) {
      return null;
    }
    const parsed = JSON.parse(raw) as Partial<StoredAiTextPayload>;
    const text = String(parsed.text ?? '').trim();
    const cachedAt = String(parsed.cachedAt ?? '').trim();
    const expiresAt = String(parsed.expiresAt ?? '').trim();
    if (!text || !cachedAt || !expiresAt) {
      return null;
    }
    return { text, cachedAt, expiresAt };
  } catch (error) {
    console.error('read ai cache failed:', error);
    return null;
  }
}

async function _writeCachedAiText(
  key: string,
  payload: StoredAiTextPayload,
  ttlSeconds: number,
): Promise<void> {
  const redis = tryGetRedisClient();
  if (!redis) {
    return;
  }

  try {
    await redis.set(key, JSON.stringify(payload), {
      expiration: { type: 'EX', value: ttlSeconds },
    });
  } catch (error) {
    console.error('write ai cache failed:', error);
  }
}
