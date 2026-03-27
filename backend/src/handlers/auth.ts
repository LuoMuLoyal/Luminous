import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { env } from '../config/env';
import { AppError } from '../http/errors';
import { success } from '../http/response';
import { User } from '../models/user';

function generateTokens(user: { _id: unknown; username: string }) {
  const accessToken = jwt.sign({ id: user._id, username: user.username }, env.jwtSecret, {
    expiresIn: '1d',
  });
  const refreshToken = jwt.sign({ id: user._id, username: user.username }, env.jwtRefreshSecret, {
    expiresIn: '14d',
  });
  return { accessToken, refreshToken };
}

export async function handleRegister(body: any) {
  const { username, password } = body;
  if (!username || !password) {
    throw new AppError('缺少用户名或密码', '400');
  }

  const existing = await User.findOne({ username });
  if (existing) {
    throw new AppError('用户名已存在', '400');
  }

  const salt = await bcrypt.genSalt(10);
  const passwordHash = await bcrypt.hash(password, salt);

  const user = new User({
    username,
    passwordHash,
  });

  await user.save();

  const tokens = generateTokens(user);

  return success({
    ...tokens,
    user: { id: user._id, username: user.username }
  });
}

export async function handleLogin(body: any) {
  const { username, password } = body;
  if (!username || !password) {
    throw new AppError('缺少用户名或密码', '400');
  }

  const user = await User.findOne({ username });
  if (!user) {
    throw new AppError('用户不存在', '404');
  }

  const valid = await bcrypt.compare(password, user.passwordHash);
  if (!valid) {
    throw new AppError('密码错误', '401');
  }

  const tokens = generateTokens(user);

  return success({
    ...tokens,
    user: { id: user._id, username: user.username }
  });
}

export async function handleRefreshToken(body: any) {
  const { refreshToken } = body;
  if (!refreshToken) {
    throw new AppError('缺少 Refresh Token', '400');
  }

  try {
    const decoded = jwt.verify(refreshToken, env.jwtRefreshSecret) as any;
    // Issue a new pair of tokens (sliding expiration)
    const tokens = generateTokens({ _id: decoded.id, username: decoded.username });
    
    return success({
      ...tokens,
    });
  } catch (error) {
    throw new AppError('Refresh Token 无效或已过期', '401');
  }
}
