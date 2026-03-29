import { isValidObjectId } from 'mongoose';
import { expectRecord, readTrimmedString } from '../http/body';
import { toApiFailure } from '../http/errors';
import { ApiEnvelope, fail, success } from '../http/response';
import { MyMedicine } from '../models/my-medicine';
import {
  MyMedicineListPayload,
  MyMedicineRecordPayload,
} from '../types';

type MyMedicineDocLike = {
  _id: unknown;
  userId?: string;
  identityKey?: string;
  drugCode?: string;
  approvalNo?: string;
  productName?: string;
  dosageForm?: string;
  specification?: string;
  manufacturer?: string;
  source?: string;
  createdAt?: number;
};

function toRecord(doc: MyMedicineDocLike): MyMedicineRecordPayload {
  return {
    id: String(doc._id ?? '').trim(),
    userId: String(doc.userId ?? '').trim(),
    identityKey: String(doc.identityKey ?? '').trim(),
    drugCode: String(doc.drugCode ?? '').trim(),
    approvalNo: String(doc.approvalNo ?? '').trim(),
    productName: String(doc.productName ?? '').trim(),
    dosageForm: String(doc.dosageForm ?? '').trim(),
    specification: String(doc.specification ?? '').trim(),
    manufacturer: String(doc.manufacturer ?? '').trim(),
    source: String(doc.source ?? 'search').trim() || 'search',
    createdAt: Number(doc.createdAt ?? 0),
  };
}

export async function handleMyMedicineUpsert(
  body: unknown,
): Promise<ApiEnvelope<MyMedicineRecordPayload>> {
  try {
    const data = expectRecord(body);
    const userId = readTrimmedString(data, 'userId');
    const id = readTrimmedString(data, 'id');
    const identityKey = readTrimmedString(data, 'identityKey');
    const productName = readTrimmedString(data, 'productName');

    if (!userId) {
      return fail('userId 不能为空');
    }
    if (!identityKey) {
      return fail('identityKey 不能为空');
    }
    if (!productName) {
      return fail('productName 不能为空');
    }

    const drugCode = readTrimmedString(data, 'drugCode');
    const approvalNo = readTrimmedString(data, 'approvalNo');
    const dosageForm = readTrimmedString(data, 'dosageForm');
    const specification = readTrimmedString(data, 'specification');
    const manufacturer = readTrimmedString(data, 'manufacturer');
    const source = readTrimmedString(data, 'source', 'search') || 'search';
    const now = Date.now();

    if (id) {
      if (!isValidObjectId(id)) {
        return fail('id 格式错误');
      }

      const existing = await MyMedicine.findOne({ _id: id, userId }).lean();
      if (!existing) {
        return fail('记录不存在');
      }

      await MyMedicine.updateOne(
        { _id: id, userId },
        {
          $set: {
            identityKey,
            drugCode,
            approvalNo,
            productName,
            dosageForm,
            specification,
            manufacturer,
            source,
            updatedAt: now,
          },
        },
      );

      return success(
        toRecord({
          ...existing,
          identityKey,
          drugCode,
          approvalNo,
          productName,
          dosageForm,
          specification,
          manufacturer,
          source,
        }),
      );
    }

    const existing = await MyMedicine.findOne({ userId, identityKey }).lean();
    if (existing) {
      await MyMedicine.updateOne(
        { _id: existing._id, userId },
        {
          $set: {
            drugCode,
            approvalNo,
            productName,
            dosageForm,
            specification,
            manufacturer,
            source,
            updatedAt: now,
          },
        },
      );

      return success(
        toRecord({
          ...existing,
          drugCode,
          approvalNo,
          productName,
          dosageForm,
          specification,
          manufacturer,
          source,
        }),
      );
    }

    const created = await MyMedicine.create({
      userId,
      identityKey,
      drugCode,
      approvalNo,
      productName,
      dosageForm,
      specification,
      manufacturer,
      source,
      createdAt: now,
      updatedAt: now,
    });

    return success(toRecord(created.toObject()));
  } catch (error) {
    console.error('my-medicine-upsert failed:', error);
    return toApiFailure(error, '保存我的药品失败，请稍后重试');
  }
}

export async function handleMyMedicineDelete(
  body: unknown,
): Promise<ApiEnvelope<boolean>> {
  try {
    const data = expectRecord(body);
    const userId = readTrimmedString(data, 'userId');
    const id = readTrimmedString(data, 'id');
    const identityKey = readTrimmedString(data, 'identityKey');

    if (!userId) {
      return fail('userId 不能为空');
    }
    if (!id && !identityKey) {
      return fail('id 或 identityKey 至少传一个');
    }

    if (id) {
      if (!isValidObjectId(id)) {
        return fail('id 格式错误');
      }
      const result = await MyMedicine.deleteOne({ _id: id, userId });
      return success(result.deletedCount === 1);
    }

    const result = await MyMedicine.deleteOne({ userId, identityKey });
    return success(result.deletedCount === 1);
  } catch (error) {
    console.error('my-medicine-delete failed:', error);
    return toApiFailure(error, '删除我的药品失败，请稍后重试');
  }
}

export async function handleMyMedicineList(
  body: unknown,
): Promise<ApiEnvelope<MyMedicineListPayload>> {
  try {
    const data = expectRecord(body);
    const userId = readTrimmedString(data, 'userId');
    if (!userId) {
      return fail('userId 不能为空');
    }

    const rows = await MyMedicine.find({ userId })
      .sort({ createdAt: -1 })
      .lean();

    return success({
      items: rows.map(item => toRecord(item)),
    });
  } catch (error) {
    console.error('my-medicine-list failed:', error);
    return toApiFailure(error, '查询我的药品列表失败，请稍后重试');
  }
}