# Luminous App Backend

Luminous App 后端服务，负责认证与药品相关接口。

## 技术栈

- Node.js + TypeScript
- Express
- JWT (AT/RT 双 token)
- MongoDB (用户)
- MySQL (药品库)
- OpenAI SDK (豆包/方舟兼容调用)

## 目录结构

```text
backend/
  src/
    ai/             AI 请求与 Prompt 组装
    config/         环境变量读取
    db/             MongoDB/MySQL 访问
    handlers/       业务处理逻辑
    http/           请求校验、统一响应、错误处理、JWT
    models/         Mongoose 模型
    routes/         路由注册
    app.ts          Express app 组装
    server.ts       启动入口
```

## 环境要求

- Node.js 18+
- 可访问的 MongoDB
- 可访问的 MySQL

## 快速开始

### 1) 安装依赖

```bash
npm install
```

### 2) 配置环境变量

创建 `backend/.env`，参考如下：

```env
PORT=8787
CORS_ORIGIN=*

MYSQL_HOST=127.0.0.1
MYSQL_PORT=3306
MYSQL_USER=root
MYSQL_PASSWORD=your_password
MYSQL_DATABASE=medicine_db
MYSQL_TABLE=国产本位码

MONGODB_URI=mongodb://127.0.0.1:27017/luminous

JWT_SECRET=replace_with_strong_secret
JWT_REFRESH_SECRET=replace_with_another_strong_secret

DOUBAO_API_KEY=your_doubao_api_key
DOUBAO_BASE_URL=https://ark.cn-beijing.volces.com/api/v3
DOUBAO_VISION_ENDPOINT_ID=ep-vision-xxx
DOUBAO_TEXT_ENDPOINT_ID=ep-text-xxx
```

说明：

- 视觉模型优先级：`DOUBAO_VISION_ENDPOINT_ID` > `DOUBAO_VISION_MODEL_ID`
- 文本模型优先级：`DOUBAO_TEXT_ENDPOINT_ID` > `DOUBAO_TEXT_MODEL_ID`

### 3) 开发运行

```bash
npm run dev
```

### 4) 生产构建与启动

```bash
npm run build
npm run start
```

## 接口概览

健康检查：

- `GET /health`

认证接口：

- `POST /api/auth/register`
- `POST /api/auth/login`
- `POST /api/auth/refresh`

药品接口：

- `POST /api/medicines/search`
- `POST /api/medicines/detail`
- `POST /api/medicines/ai-detail`
- `POST /api/medicines/ai-safety`
- `POST /api/medicines/scan`

完整参数与返回示例见 [../lib/docs/backend-api.md](../lib/docs/backend-api.md)。

## 统一返回结构

```json
{
  "code": "1",
  "msg": "",
  "result": {}
}
```

说明：

- `code == "1"` 为业务成功
- 业务失败通常也会返回 HTTP 200，但 `code != "1"`
- 中间件级错误（如未授权）可能返回 4xx/5xx

## 与 Flutter 的联调点

- Flutter 基础地址配置：`lib/constants/constants.dart`
- 网络层解析逻辑：`lib/utils/DioRequest.dart`

请确保 Flutter 的 `GlobalConstants.BASE_URL` 指向当前后端实例。

## 常见问题

### 1) 启动时报 MySQL 连接错误

检查 `.env` 中 `MYSQL_*` 是否正确，且数据库白名单已放通。

### 2) 启动时报 Mongo 连接错误

检查 `MONGODB_URI`，并确认 Mongo 服务可访问。

### 3) AI 接口返回失败

检查：

- `DOUBAO_API_KEY`
- 文本/视觉模型 ID 是否配置
- 目标环境是否可访问 `DOUBAO_BASE_URL`

## 相关文档

- 项目总览：[../README.md](../README.md)
- 后端学习文档：[../BackendMd/README.md](../BackendMd/README.md)
- 部署配置清单：[../lib/docs/deployment-config.md](../lib/docs/deployment-config.md)
