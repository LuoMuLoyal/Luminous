# AGENTS.md — Luminous

> Luminous 项目 AI Agent 操作规范

## 项目概览

- **类型**：Flutter 个人健康管理应用
- **状态管理**：Riverpod（禁止 GetX）
- **路由**：GoRouter（禁止 Navigator.push）
- **后端**：Lucent（NestJS + Prisma + PostgreSQL）

## ✅ 可以做

| 场景                      | 说明                                                   |
| ------------------------- | ------------------------------------------------------ |
| 新增业务代码              | 统一放在 `lib/features/`、`lib/shared/` 或 `lib/core/` |
| 使用自动生成的 API 客户端 | 代码在 `lib/api/generated/`，不要手写网络请求          |
| 使用 Riverpod 管理状态    | `flutter_riverpod`                                     |
| 使用 GoRouter 导航        | `context.pushNamed()` 或 GoRoute 注册                  |

## ❌ 禁止事项

| 类别          | 禁止内容                                                                     |
| ------------- | ---------------------------------------------------------------------------- |
| 旧目录加代码  | `lib/pages/`、`lib/stores/`、`lib/viewmodels/`、`lib/components/` 是遗留目录 |
| 引入 GetX     | 已从 pubspec.yaml 移除，使用 Riverpod                                        |
| 绕过 GoRouter | 禁止 `Navigator.push(MaterialPageRoute(...))`                                |
| 提交到 Git    | `DrugDataBase/`、`build/`、`outputs/`、`Roadshow/`、`.env.*`、IDE 配置       |

## 常用命令

```bash
# 提交前必须跑
flutter analyze
flutter test

# 依赖安装
flutter pub get

# API 客户端重新生成
cd ../Lucent && pnpm export:openapi
cd ../Luminous && openapi-generator-cli generate -g dart-dio -i ../Lucent/docs/openapi.json -o lib/api/generated --additional-properties=pubName=luminous_api,pubAuthor=Lumos
cd lib/api/generated && dart pub get && dart run build_runner build --delete-conflicting-outputs
```

## 后端对接规范

- API 契约：`../Lucent/docs/api-contract.md`、`auth-api-mock.md`
- 响应格式：`{ code, message, data }`
- 认证：`Authorization: Bearer <accessToken>`，token 由 `lib/core/network/TokenManager` 管理

## 提交规范

格式：`type(scope): subject`

常用 type：`feat`、`fix`、`docs`、`refactor`、`test`、`chore`

## 提交前检查清单

- [ ] `flutter analyze` — No issues
- [ ] `flutter test` — 全量通过
- [ ] 未引入 GetX 依赖
- [ ] 新代码在 `lib/features/`、`lib/shared/` 或 `lib/core/`
- [ ] 未提交禁提交的文件

## AI 协作原则

1. **先想再做**：不确定就问，不猜测
2. **简洁优先**：只写解决问题所需的最小代码
3. **精准修改**：不改未损坏的东西
4. **目标驱动**：把任务转成可验证的目标
