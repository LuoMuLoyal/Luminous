import mongoose, { Document, Schema } from 'mongoose';

export interface IMyMedicine extends Document {
  userId: string;
  identityKey: string;
  drugCode: string;
  approvalNo: string;
  productName: string;
  dosageForm: string;
  specification: string;
  manufacturer: string;
  source: string;
  createdAt: number;
  updatedAt: number;
}

const MyMedicineSchema = new Schema<IMyMedicine>({
  userId: { type: String, required: true, index: true },
  identityKey: { type: String, required: true },
  drugCode: { type: String, default: '' },
  approvalNo: { type: String, default: '' },
  productName: { type: String, required: true },
  dosageForm: { type: String, default: '' },
  specification: { type: String, default: '' },
  manufacturer: { type: String, default: '' },
  source: { type: String, default: 'search' },
  createdAt: { type: Number, default: () => Date.now() },
  updatedAt: { type: Number, default: () => Date.now() },
});

MyMedicineSchema.index({ userId: 1, identityKey: 1 }, { unique: true });

export const MyMedicine = mongoose.model<IMyMedicine>(
  'MyMedicine',
  MyMedicineSchema,
);