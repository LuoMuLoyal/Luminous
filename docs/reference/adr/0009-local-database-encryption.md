# ADR-0009: 本地数据库静态加密 — 引入时机与目标路线

- **Status**: proposed
- **Date**: 2026-09-08
- **Deciders**: LuoMuLoyal

## Context

[ADR-0006](0006-local-persistence-drift.md)(本地持久化与离线策略 — Drift)§5 决定当前阶段不引入 SQLCipher,依据是应用沙箱 + 设备级加密(iOS Keychain / Android Keystore + 文件系统加密)已提供基础保护,并约定"后续如引入敏感第三方数据重新评估"。2026-08-22 迁移清点计划进一步设门:只有产品数据范围扩大或威胁模型改变才启动独立安全计划,且需先做威胁模型与平台可行性评估;平台级加密必须建独立 ADR 与子计划,不藏在机械迁移中。

本 ADR 是那次"重新评估"的正式记录,回答:Luminous 是否应在当前(2026-09)引入本地数据库静态加密。

评估时核实的相关事实:

- 本地 `luminous.db`(`lib/core/database/connection_io.dart`,明文 SQLite)已有 8 张缓存表:daily_records、medicine_dose_logs、current_medicines、health_context(基础信息 / 过敏史 / 疾病 / 紧急联系人)、today_suggestions、reviews、review_dashboards、pending_sync 队列——均为 PIPL 意义上的个人健康数据。
- 数据形态仍是"云端为源、本地为 cache-first 镜像"(ADR-0006 架构不变),未见敏感第三方数据被引入,威胁模型未发生实质变化。
- 平台矩阵:Android / iOS 为当前首发与验证表面;Web 走 drift WASM(数据在 OPFS / IndexedDB);现有 Flutter 桌面代码保留但停止产品扩展(ADR-0008),仍作为 `-d windows` e2e 的验证宿主。
- 产品文案 FAQ(`assets/faq/faq_zh.md`)声明"健康数据使用加密传输和加密存储",与本地明文库存在口径风险。
- 技术生态已换代:`sqlcipher_flutter_libs` 已标记 0.7.0+eol(不再做任何事);drift ≥ 2.32 + `sqlite3` 3.x 通过 native build hook 编译 SQLite3MultipleCiphers 是官方当前路线,支持 `PRAGMA key / rekey` 并可兼容既有 SQLCipher 加密库。
- 依赖基线仍为 `drift ^2.20` + `sqlite3_flutter_libs ^0.5`(旧 sqlite3 2.x 世界),引入加密需连带一次 drift / sqlite3 升级(native 构建体系改造)。
- 数据生命周期尚有缺口:logout 只清 session 未清本地缓存(`lib/core/auth/session_provider.dart`);Android 未配置 backup 排除规则(默认 allowBackup=true 时明文库可能随云备份外流)。这些问题与静态加密正交,且更紧迫。

## Decision(proposed — 待确认)

1. **本阶段仍不立即实施加密**:ADR-0006 §5 在当前迭代期的决策继续生效,不把平台级加密插入正在多线变更(Review 重组、record mini-trend、Flutter 3.47 升级阻塞)的存储底座。但本 ADR 取代其"无限期推迟"的语义——它是一次有日期的再评估,并把落地条件固化为可执行窗口。
2. **落地窗口 = 下一次依赖升级与 schema/sync churn 收敛之后、1.0 广泛分发之前**:加密随 drift 2.3x / sqlite3 3.x 升级一并实施,避免对 native 构建体系做两次独立改造。
3. **技术路线 = SQLite3MultipleCiphers hook(官方当前路线),不采用已 EOL 的 `sqlcipher_flutter_libs`,也不走 sqflite_sqlcipher / encrypted_drift 旧路**。
4. **迁移 = 设备端一次性加密既有明文库**(`VACUUM INTO` 临时文件 + `PRAGMA rekey`,drift 官方模式);失败时保留明文副本可回滚;schema MigrationStrategy 逐版本可重入不变量保持不变。
5. **密钥 = 存 Keystore / Keychain 保护的 `flutter_secure_storage`(优先硬件背书、不可导出的非对称/密钥包装),不落盘明文密钥**;实施计划须先解决"首解前不访问 DB"的解锁时序。
6. **平台覆盖 = 原生平台全库加密;Web(WASM)单独声明**——WASM 无法走 sqlite3mc 时,明确定义 Web 为保证面较低的平台,同步收敛 FAQ"加密存储"口径,不虚假宣称全平台静态加密。
7. **前置低成本项独立先行(不等加密)**:Android backup 规则排除 `luminous.db`;logout / 切号清理或按账号隔离本地缓存。静态加密不替代这些数据生命周期修复。

## Options Considered

| Option | Advantages | Disadvantages |
|---|---|---|
| 维持现状(仅沙箱 + 设备 FBE / Keychain) | 零成本;当前风险可控 | 文件提取即得可读 SQLite;云备份可能带出明文库;与 FAQ"加密存储"口径不符;健康数据的审计 / 合规期望悬空 |
| 立即(2026-09)实施加密 | 尽早获得 at-rest 保证 | 撞上存储底座与依赖多线变更;drift / sqlite3 升级未到窗口;平台覆盖、密钥、迁移策略未定就动手风险高 |
| **暂缓至依赖升级窗口 + 独立安全子计划(proposed)** | 单一平台改造窗口;策略先立、实施有序;1.0 分发前完成 | 当前迭代期本地数据保持明文 |
| sqlcipher_flutter_libs / sqflite_sqlcipher 旧路 | 与既有 sqlite3 2.x 世界更接近 | 上游已 EOL / 维护边缘;后续仍要迁到 sqlite3mc,重复成本 |

## Consequences

- ADR-0006 §5 在加密落地时被本 ADR 取代;本文档成为"何时、因何触发本地静态加密"的可追溯决策点。
- 实施前提清单:drift ≥ 2.32 升级(含 codegen / build_runner 连锁)、运行时 `PRAGMA cipher` 断言、DAO 单元测试(`NativeDatabase.memory`)加密 setup 化、加密迁移与回滚测试。
- 新测试面:首次启动加密迁移、密钥缺失 / 损坏、云备份恢复后密钥与库一致性、失败回滚。
- 开放项(进入实施计划前确认):密钥丢失 / 重置 UX、Web 加密不可行时的降级声明与文案、Android backup / restore 与密钥互操作、logout / 切号缓存隔离的归属。

## 待确认

1. 触发条件表述:以"1.0 广泛分发前"为硬截止,还是仅以"依赖升级窗口"为触发?
2. Web 覆盖与 FAQ 文案收敛的口径。
3. 是否把"logout / 切号缓存生命周期 + Android backup 排除"排为独立近期工作项(建议排)。
