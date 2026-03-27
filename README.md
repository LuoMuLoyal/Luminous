# Luminous

Luminous 是一个面向移动端的智慧用药助手，当前主工程为 Flutter App，并包含一套可独立部署的 App 后端（Express + JWT + MongoDB + MySQL）。

## 功能概览

- 药品搜索与药品详情
- 拍照识别药品并回查药品库
- AI 解读与 AI 安全辅助
- 今日提醒与本地打卡
- 识别相册与结果回看
- 多主题与深浅色外观

## 技术栈

- App: Flutter (Dart)
- App Backend: Node.js + TypeScript + Express
- 鉴权: JWT (Access Token + Refresh Token)
- 数据库: MongoDB (用户) + MySQL (药品库)
- AI: 豆包 / 火山方舟

## 项目结构

```text
Luminous/
  lib/                Flutter 主代码
  test/               Flutter 测试
  backend/            App 后端服务（可独立部署）
  BackendMd/          后端接口与实现映射文档
  Study/              代码学习与架构梳理文档
  android/ios/...     各平台工程
```

更多目录说明见 [lib/README.md](lib/README.md)。

## 快速开始

### 1) 运行 Flutter App

```bash
flutter pub get
flutter run
```

常用检查：

```bash
flutter analyze
flutter test
```

### 2) 运行 App Backend

```bash
cd backend
npm install
npm run dev
```

默认健康检查：

- `GET http://127.0.0.1:8787/health`

## 关键配置

### Flutter 请求地址

- 文件: `lib/constants/constants.dart`
- 配置项: `GlobalConstants.BASE_URL`

开发常见取值：

- Android 模拟器: `http://10.0.2.2:8787`
- 真机: `http://<局域网IP>:8787`

### App Backend 环境变量

- 文件: `backend/.env`（需自行创建）
- 读取逻辑: `backend/src/config/env.ts`

至少需要配置：

- `MYSQL_HOST` / `MYSQL_PORT` / `MYSQL_USER` / `MYSQL_PASSWORD` / `MYSQL_DATABASE`
- `MONGODB_URI`
- `JWT_SECRET` / `JWT_REFRESH_SECRET`
- `DOUBAO_API_KEY`

完整部署配置见 [lib/docs/deployment-config.md](lib/docs/deployment-config.md)。

## API 文档

- App Backend API 总览: [lib/docs/backend-api.md](lib/docs/backend-api.md)
- 后端学习索引: [BackendMd/README.md](BackendMd/README.md)

## 文档导航

- 后端部署与运行: [backend/README.md](backend/README.md)
- 学习型后端文档: [BackendMd/README.md](BackendMd/README.md)
- 代码学习手册: [Study/README.md](Study/README.md)
- 项目内文档目录: [lib/docs/README.md](lib/docs/README.md)

## 当前状态说明

- App 后端当前已实现认证与药品相关核心接口。
- Flutter 常量中仍保留部分历史接口路径，若联调请以 [lib/docs/backend-api.md](lib/docs/backend-api.md) 为准。

## 许可证

当前仓库未声明开源许可证，默认按私有项目处理。
