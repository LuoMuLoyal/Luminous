import mongoose, { Document, Schema } from 'mongoose';

export interface IScanRecord extends Document {
  userId: string;
  thumbBase64: string;
  drugCode: string;
  approvalNo: string;
  productName: string;
  takenAt: number;
  createdAt: number;
}

const ScanRecordSchema = new Schema<IScanRecord>({
  userId: { type: String, required: true, index: true },
  thumbBase64: { type: String, required: true },
  drugCode: { type: String, default: '' },
  approvalNo: { type: String, default: '' },
  productName: { type: String, default: '' },
  takenAt: { type: Number, default: () => Date.now() },
  createdAt: { type: Number, default: () => Date.now() },
});

ScanRecordSchema.index({ userId: 1, takenAt: -1 });

export const ScanRecord = mongoose.model<IScanRecord>(
  'ScanRecord',
  ScanRecordSchema,
);