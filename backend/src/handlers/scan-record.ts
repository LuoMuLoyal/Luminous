import { expectRecord, readPage, readTrimmedString } from '../http/body';
import { toApiFailure } from '../http/errors';
import { ApiEnvelope, fail, success } from '../http/response';
import { ScanRecord } from '../models/scan-record';
import {
  ScanRecordCreatePayload,
  ScanRecordItemRecord,
  ScanRecordListPayload,
} from '../types';

type ScanRecordDocLike = {
  _id: unknown;
  thumbBase64?: string;
  drugCode?: string;
  approvalNo?: string;
  productName?: string;
  takenAt?: number;
};

function toScanRecordItem(doc: ScanRecordDocLike): ScanRecordItemRecord {
  return {
    id: String(doc._id ?? '').trim(),
    thumbBase64: String(doc.thumbBase64 ?? '').trim(),
    drugCode: String(doc.drugCode ?? '').trim(),
    approvalNo: String(doc.approvalNo ?? '').trim(),
    productName: String(doc.productName ?? '').trim(),
    takenAt: Number(doc.takenAt ?? 0),
  };
}

export async function handleScanRecordCreate(
  body: unknown,
): Promise<ApiEnvelope<ScanRecordCreatePayload>> {
  try {
    const data = expectRecord(body);
    const userId = readTrimmedString(data, 'userId');
    const thumbBase64 = readTrimmedString(data, 'thumbBase64');

    if (!userId) {
      return fail('userId 不能为空');
    }
    if (!thumbBase64) {
      return fail('thumbBase64 不能为空');
    }

    const drugCode = readTrimmedString(data, 'drugCode');
    const approvalNo = readTrimmedString(data, 'approvalNo');
    const productName = readTrimmedString(data, 'productName');
    const rawTakenAt = Number(data.takenAt);
    const takenAt = Number.isFinite(rawTakenAt) && rawTakenAt > 0
      ? Math.trunc(rawTakenAt)
      : Date.now();

    const created = await ScanRecord.create({
      userId,
      thumbBase64,
      drugCode,
      approvalNo,
      productName,
      takenAt,
      createdAt: Date.now(),
    });

    return success({ id: created._id.toString() });
  } catch (error) {
    console.error('scan-record-create failed:', error);
    return toApiFailure(error, '创建识别记录失败，请稍后重试');
  }
}

export async function handleScanRecordList(
  body: unknown,
): Promise<ApiEnvelope<ScanRecordListPayload>> {
  try {
    const data = expectRecord(body);
    const userId = readTrimmedString(data, 'userId');
    if (!userId) {
      return fail('userId 不能为空');
    }

    const page = readPage(data, 'page', 1, 1, Number.MAX_SAFE_INTEGER);
    const pageSize = readPage(data, 'pageSize', 20, 1, 50);
    const skip = (page - 1) * pageSize;

    const [total, rows] = await Promise.all([
      ScanRecord.countDocuments({ userId }),
      ScanRecord.find({ userId })
        .sort({ takenAt: -1, createdAt: -1 })
        .skip(skip)
        .limit(pageSize)
        .lean(),
    ]);

    return success({
      items: rows.map(item => toScanRecordItem(item)),
      total,
      page,
      pageSize,
    });
  } catch (error) {
    console.error('scan-record-list failed:', error);
    return toApiFailure(error, '查询识别记录失败，请稍后重试');
  }
}