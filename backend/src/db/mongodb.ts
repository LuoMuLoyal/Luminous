import mongoose from 'mongoose';
import { env } from '../config/env';

export async function connectMongoDB() {
  try {
    await mongoose.connect(env.mongoUri);
    console.log('MongoDB connected successfully');
  } catch (error) {
    console.error('MongoDB connection error:', error);
    process.exit(1);
  }
}
