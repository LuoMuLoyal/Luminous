import { AppError } from './errors';

export type JsonRecord = Record<string, unknown>;

export function expectRecord(body: unknown): JsonRecord {
  if (!body || typeof body !== 'object' || Array.isArray(body)) {
    throw new AppError('请求参数格式错误');
  }
  return body as JsonRecord;
}

export function readTrimmedString(
  body: JsonRecord,
  key: string,
  fallback = '',
): string {
  const value = body[key];
  return typeof value === 'string' ? value.trim() : fallback;
}

export function readBoolean(
  body: JsonRecord,
  key: string,
  fallback = false,
): boolean {
  const value = body[key];
  if (typeof value === 'boolean') {
    return value;
  }
  if (typeof value === 'number') {
    return value !== 0;
  }
  if (typeof value === 'string') {
    const normalized = value.trim().toLowerCase();
    if (normalized === 'true' || normalized === '1') {
      return true;
    }
    if (normalized === 'false' || normalized === '0') {
      return false;
    }
  }
  return fallback;
}

export function readPage(
  body: JsonRecord,
  key: string,
  fallback: number,
  min: number,
  max: number,
): number {
  const raw = Number(body[key]);
  if (!Number.isFinite(raw)) {
    return fallback;
  }
  return Math.min(max, Math.max(min, Math.trunc(raw)));
}
