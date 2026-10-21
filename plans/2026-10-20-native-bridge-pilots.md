# 原生桥接试点计划：步数 + 后台同步

Created: 2026-10-20

> 状态：未开工
> 范围：Luminous；Lucent 无改动
> 关系：把 [`2026-07-29-native-bridging-roadmap.md`](2026-07-29-native-bridging-roadmap.md) §3.3 的健康数据迁移收窄为**步数单项**，同时落地 P0 后台同步。两个试点分别验证「KMP 共享模块」与「纯平台模块」两种原生扩展形态。

## 一、目标

建立一套可继续追加原生模块的桥接骨架，并用两个试点验证：

- **步数**：iOS HealthKit + Android `SensorManager.TYPE_STEP_COUNTER`，不依赖 Google Play services / Health Connect / 厂商健康 SDK。
- **后台同步**：Android `WorkManager` + iOS `BGTaskScheduler` 调度，后台唤醒 Dart 重放 `pending_sync_items`。

完成后，新增生物识别、系统快捷方式、桌面组件、BLE 等模块时，只需按同一模板增加一个模块目录，不再重搭 KMP、Pigeon、插件注册和 Dart 装配。

## 二、非目标

- 不迁移 `sleep` / `heartRate` / 血压等其他健康指标。
- 不接入 Health Connect、华为 Health Service Kit、小米运动健康 SDK、OPPO/vivo 健康 SDK。
- 不在后台读取健康数据；后台同步只重放已有的 pending write 队列。
- 不做 Android Foreground Service、常驻计步、开机自启。
- 不改推送链路、不新增同步设置页、不替换现有 UI。
- 不引入 Compose Multiplatform。
- 不批量重命名未触达的 `health_data` 文件。
- 暂不拆多个 Gradle 子项目；先单 KMP module + 按 feature 分 package，等模块需要独立依赖或独立发布时再拆。

## 三、总体结构

```text
Flutter feature / data
  → lib/core/native/bridge.dart（应用侧唯一接缝）
    → pkgs/luminous_native_bridge（Pigeon + 平台注册）
      → KMP 共享模块（steps）或纯平台 API（background）
```

两种模块形态：

1. **KMP-backed module**：有跨端共享逻辑时使用，例如步数归一化、未来的生物识别策略、BLE 协议解析。
   - KMP `commonMain` 放领域模型与纯逻辑；`androidMain` / `iosMain` 放平台实现。
   - Flutter plugin 只做 Pigeon 注册、Context/Activity 注入、错误码转换。
2. **Platform-only module**：逻辑属于系统生命周期或原生 UI 时使用，例如后台调度、应用快捷方式、Widget、Live Activity、分享扩展。
   - 不强行塞进 KMP；Flutter plugin 直接封装平台 API。
   - 若以后出现可共享策略（如调度间隔、约束、错误模型），再抽到 KMP `core`。

新增模块固定改动点：Pigeon schema、plugin handler、Dart bridge、应用侧 adapter、测试。只有 KMP-backed module 才额外增加 KMP package。

## 四、目录结构

```text
Luminous/
├─ native/                                      # 独立 Gradle build，不并入 android/
│  ├─ settings.gradle.kts
│  ├─ build.gradle.kts
│  ├─ gradle.properties
│  ├─ gradle/libs.versions.toml
│  ├─ gradlew / gradlew.bat
│  ├─ gradle/wrapper/
│  ├─ README.md                                 # KMP 构建与新增模块模板
│  └─ luminous-native/
│     ├─ build.gradle.kts                       # androidTarget + iosArm64/iosSimulatorArm64
│     └─ src/
│        ├─ commonMain/kotlin/com/devluo/luminous/native/
│        │  ├─ core/                            # 所有模块共用，不放业务
│        │  │  ├─ capability.kt                 # Capability + 不可用原因
│        │  │  ├─ failure.kt                    # Failure
│        │  │  └─ result.kt                     # NativeResult
│        │  └─ steps/                           # 步数模块
│        │     ├─ source.kt                     # Source 契约
│        │     ├─ request.kt                    # StepRequest
│        │     ├─ sample.kt                     # StepSample
│        │     └─ normalization.kt              # 日切分、合并、边界裁剪
│        ├─ commonTest/kotlin/com/devluo/luminous/native/steps/
│        │  └─ normalization_test.kt
│        ├─ androidMain/kotlin/com/devluo/luminous/native/steps/
│        │  ├─ source.kt                        # AndroidSource
│        │  ├─ sensor.kt                        # TYPE_STEP_COUNTER
│        │  └─ baseline.kt                      # 累计值基线 + 重启处理
│        └─ iosMain/kotlin/com/devluo/luminous/native/steps/
│           ├─ source.kt                        # IosSource
│           └─ statistics.kt                    # HealthKit 按日统计
│
├─ pkgs/luminous_native_bridge/                 # 本地 Flutter plugin（通道层）
│  ├─ pubspec.yaml
│  ├─ README.md                                 # 如何新增一个 bridge module
│  ├─ pigeon/
│  │  ├─ steps.dart                             # StepHostApi
│  │  └─ background.dart                        # BackgroundHostApi
│  ├─ lib/
│  │  ├─ luminous_native_bridge.dart            # 统一入口：steps / background
│  │  └─ src/
│  │     ├─ generated/
│  │     │  ├─ steps.g.dart                     # 生成文件，不手改
│  │     │  └─ background.g.dart
│  │     ├─ steps/
│  │     │  └─ bridge.dart                      # StepBridge
│  │     └─ background/
│  │        └─ schedule.dart                    # BackgroundScheduler
│  ├─ android/
│  │  ├─ build.gradle.kts                       # 依赖 com.devluo.luminous:luminous-native
│  │  └─ src/main/kotlin/com/devluo/luminous/bridge/
│  │     ├─ registration.kt                     # LuminousNativeBridgePlugin
│  │     ├─ steps/
│  │     │  └─ handler.kt                       # StepHandler
│  │     └─ background/
│  │        ├─ schedule.kt                      # BackgroundScheduler
│  │        └─ worker.kt                        # BackgroundWorker
│  ├─ ios/
│  │  ├─ luminous_native_bridge.podspec         # vendored_frameworks
│  │  └─ Classes/
│  │     ├─ Registration.swift
│  │     ├─ Steps/
│  │     │  └─ Handler.swift                    # StepHandler
│  │     └─ Background/
│  │        ├─ Schedule.swift                   # BackgroundScheduler
│  │        └─ Runner.swift                     # BackgroundRunner
│  └─ test/
│     ├─ steps_test.dart
│     └─ background_test.dart
│
├─ scripts/native/
│  ├─ build_kmp_ios.ps1 / .sh
│  ├─ build_kmp_ios_xcframework.ps1 / .sh
│  └─ sync_xcframework.ps1 / .sh
│
├─ lib/core/native/
│  └─ bridge.dart                               # nativeBridgeProvider（测试可覆盖）
│
├─ lib/core/database/sync/
│  ├─ handlers.dart                             # 前后台共用的 handler 注册
│  ├─ background.dart                           # 前台调度 adapter
│  └─ background_entry.dart                     # @pragma('vm:entry-point')
│
└─ lib/features/health_data/
   ├─ data/datasources/steps.dart               # NativeStepSource
   ├─ data/models/step.dart                     # StepSample
   ├─ data/providers/health_sync.dart           # steps 走 native，其余走插件
   └─ presentation/providers/health_sync.dart   # capability 文案与状态
```

`androidMain` / `iosMain` 下出现同名 `source.kt` 是 KMP source set 的正常形态；平台由目录表达，不再写进文件名。不创建空占位目录，后续模块按同样结构落地。

## 五、命名约定

原则：**文件名表达职责，不表达位置；目录已经表达的结构不重复。**

- 新文件不使用目录名前缀：
  - ❌ `health/StepGateway.kt` → ✅ `steps/source.kt`
  - ❌ `datasources/health_steps.dart` → ✅ `datasources/steps.dart`
  - ❌ `background/BackgroundScheduler.kt` → ✅ `background/schedule.kt`（类名 `BackgroundScheduler` 已足够）
- 不使用纯类型词单独做文件名；若目录只是技术层，文件名保留业务词。
- KMP 类名由包提供上下文：`Source` / `StepRequest` / `StepSample` / `Capability` / `Failure` / `NativeResult`。
- 导出的 ObjC/Swift 名称用 `@ObjCName` 固定为 `LuminousStepSource` 等，避免与系统类型重名。
- Dart 类名跨 import 后没有包名上下文，保留业务词：`NativeStepSource` / `StepSample`。
- Pigeon 生成文件与 KMP 生成头文件不手改。
- 现有 `health_platform.dart` / `health_sync.dart` 等文件暂不改名，避免把试点扩大成重命名工程。

## 六、职责边界

- **KMP commonMain**：步数日切分、区间裁剪、样本合并、能力/错误模型；不得引用 Flutter、Drift、daily record。
- **KMP androidMain**：传感器读取、权限、基线持久化、重启识别；不得写 daily record。
- **KMP iosMain**：HealthKit 授权与统计查询；不得写 daily record。
- **Flutter plugin**：Pigeon 注册、Activity/Context 注入、生命周期、错误码转换、后台任务调度；不写业务规则。
- **Dart data 层**：`StepSample` → `HealthMetric`，复用现有 `HealthRecordMapper` 与 `HealthSyncRepository` 去重。
- **Dart presentation**：只消费 capability 与同步结果，不感知 KMP/Pigeon 类型。
- **Dart background entry**：最小启动容器，只初始化 DB、Dio、logger、sync handlers；不启动 UI、推送、通知、analytics。

## 七、步数模块

调用链：

```text
Dart NativeStepSource
  → pkgs/luminous_native_bridge（Pigeon）
    → Android: StepHandler → KMP androidMain → SensorManager.TYPE_STEP_COUNTER + 本地基线
    → iOS:     StepHandler → KMP XCFramework → HealthKit HKStatisticsCollectionQuery
```

Android 语义：

1. `sensor.kt` 读取当前累计值，并检查传感器是否存在。
2. `baseline.kt` 用 `SharedPreferences` 保存上次累计值与时间戳。
3. 本次累计值大于基线时，差值为 `[baselineTime, now]` 的步数；累计值变小视为重启，按 `[本次开机, now]` 处理，不产生负值。
4. 返回一个跨度为 `[上次同步, now]` 的 `StepSample`，由 Dart 侧沿用现有去重逻辑写入 daily record。
5. 页面文案明确「Android 仅统计自上次同步以来的步数」，不承诺历史每日拆分。

iOS 的 HealthKit 可以按日返回历史步数，因此两端结果的时间粒度不完全对称；这是第一期接受的差异。后续要靠常驻采样或 Health Connect 才能补齐 Android 历史日粒度，不在本期范围。

## 八、后台同步模块

范围只限 pending write 队列，不拉取健康数据。

调用链：

```text
Android WorkManager / iOS BGTaskScheduler
  → BackgroundWorker / BackgroundRunner
    → headless FlutterEngine → background_entry.dart
      → 最小 ProviderContainer → SyncWorker.flush()
```

平台实现：

- **Android**：`BackgroundScheduler` 以唯一 work name 入队 `PeriodicWorkRequest`，网络约束；最小周期 15 分钟。`BackgroundWorker` 启动 headless `FlutterEngine`，执行 Dart callback，按 flush 结果返回 `Result.success()` / `Result.retry()`；不启 Foreground Service，不发常驻通知。
- **iOS**：注册 `BGProcessingTask`；`Info.plist` 增加 `BGTaskSchedulerPermittedIdentifiers` 与 `UIBackgroundModes: processing`。`BackgroundRunner` 启动 headless engine，执行 callback，调用 `setTaskCompleted`；每次结束后重新排下一次，并处理 expiration。用户强制退出后系统不会唤醒，属于平台限制。
- **Dart**：`background_entry.dart` 顶层函数标注 `@pragma('vm:entry-point')`，构建最小 `ProviderContainer`，通过 `handlers.dart` 注册与前台相同的 sync handlers，再执行 flush。不要直接读 `syncWorkerProvider`，它会启动前台 connectivity 监听。

调度 API：

- `isSupported()`
- `schedule({minimumIntervalMinutes, requiresNetwork})`
- `cancel()`

生命周期：

- 登录/会话恢复后调度；登出时取消。
- 后台入口检查当前会话；无会话直接结束，不执行 flush。
- 首期不新增设置开关，默认跟随登录状态；要暴露用户开关另开任务。

`SyncWorker.flush()` 需要返回结果摘要（成功数、仍待处理、可重试失败、永久失败），让原生 worker 区分 `retry` 与 `success`；当前实现吞掉所有异常并返回 `void`，需要一并调整。

## 九、实施步骤

### 1. 构建骨架

- 新建 `native/` 独立 Gradle build，`luminous-native` 先只含 `ping()`。
- 新建 `pkgs/luminous_native_bridge`，Android/iOS 各实现 `ping()`，Dart 可调用。
- `android/settings.gradle.kts` 用 composite build 引入 `../native`，不在 Flutter Android 构建里直接 apply KMP 插件。
- 验收：`flutter build apk --debug`、`flutter build ios --no-codesign` 通过，两端 `ping()` 一致。

### 2. KMP 步数实现

- `steps/source.kt` 定义 `capability()` 与 `readSteps(request)`。
- Android：`sensor.kt` 检查并读取 `TYPE_STEP_COUNTER`；`baseline.kt` 处理开机累计值与重启；无传感器返回 `Capability.unavailable(noStepSensor)`。
- iOS：`statistics.kt` 用 `HKStatisticsCollectionQuery` 按日返回步数。
- `normalization.kt` 负责边界裁剪、同日合并、空结果过滤；不要在这里做 daily record 业务。
- 验收：`commonTest` 覆盖日切分/合并/负值与重启场景；两端单平台调试可返回步数。

### 3. Pigeon 桥接

- `pigeon/steps.dart` 定义 `StepHostApi`：`capability`、`read`。
- DTO 固定字段：`count`、`startMs`、`endMs`、`source`；Android 来源 `android_sensor`，iOS 来源 `apple_health`。
- Android `StepHandler` 注入 Context 调用 KMP；iOS `StepHandler` 调用 XCFramework。
- 验收：Dart 单测注入 fake `StepHostApi`，不启真机。

### 4. Dart 接线

- 新增 `NativeStepSource`，在 `data/providers/health_sync.dart` 中把 `steps` 路由到 native，其他指标继续走 `health` 插件。
- 新增 `StepSample` → `HealthMetric(steps)` 的映射；复用现有指纹去重，不新增写入路径。
- 同步页在 Android 无传感器时展示不可用原因，不把「无数据」显示成「0 步」。
- 验收：现有 `test/health_data` 全部通过；切换 flag 后步数同步行为与旧插件一致或更准确。

### 5. 后台同步接线

- 使用 `workmanager` 包调度；Dart 侧注册 callback dispatcher，插件在唤醒时启动 headless engine 并调用入口。
- `handlers.dart` 抽出前后台共用的 sync handler 注册；`background_entry.dart` 构建最小容器并 flush。
- `SyncWorker.flush()` 返回结果摘要；前台调用点忽略摘要，后台 worker 用它决定 retry。
- 登录/恢复会话后调度，登出取消；无会话时后台入口直接退出。
- 验收：Android 用 WorkManager 调试入口触发一次；iOS 用 Xcode LLDB `_simulateLaunchForTaskWithIdentifier` 触发一次；队列能清空，失败项按现有 retry 规则保留。

### 6. 真机验证与回退

- iOS 真机：HealthKit 授权、拒绝、撤销权限、历史步数按日读取；后台任务在充电/空闲时可触发。
- Android 真机：有/无 `TYPE_STEP_COUNTER`、`ACTIVITY_RECOGNITION` 授权、重启后基线、连续两次同步不重复；后台任务在杀进程后由 WorkManager 重新调度。
- 保留 provider flag 回退到旧插件；观察期无回归后再考虑扩大迁移范围。
- `health` 插件本期不删除；步数迁移成功不代表其他指标可以下线。

## 十、构建与配置

- **Android**：`android/settings.gradle.kts` 使用 `includeBuild("../native")` 与 dependency substitution；`pkgs/luminous_native_bridge/android/build.gradle.kts` 依赖 `com.devluo.luminous:luminous-native`。不在 Flutter app 模块直接 apply `org.jetbrains.kotlin.multiplatform`。
- **Android 权限**：新增 `android.permission.ACTIVITY_RECOGNITION`；运行时权限用现有 `permission_handler` 或 plugin 内 Activity 请求。后台同步使用 WorkManager，不需要新增权限。
- **iOS**：KMP 输出 static `LuminousNative.xcframework`，由 plugin podspec `vendored_frameworks` 引用；`ios/Podfile` 已是 `use_frameworks! :linkage => :static`。
- **XCFramework 构建**：`scripts/native/build_kmp_ios_xcframework.*` 调用 Gradle `assembleLuminousNativeXCFramework`，`sync_xcframework.*` 复制到 `pkgs/luminous_native_bridge/ios/Frameworks/`；该目录加入 `.gitignore`。
- **版本对齐**：KMP 的 Kotlin 版本与 `android/settings.gradle.kts` 中 KGP（当前 2.4.0）保持一致，版本写在 `native/gradle/libs.versions.toml`。
- **依赖**：`pubspec.yaml` 增加 `luminous_native_bridge: { path: pkgs/luminous_native_bridge }`；`health` 依赖本期保留。
- **CI**：Android 在 `flutter build` 前构建 KMP；iOS 在 `pod install` 前构建 XCFramework；缓存 Gradle 与 XCFramework 输出。

## 十一、验证清单

- `flutter analyze`
- `flutter test test/health_data`
- `flutter test test/core/database`（后台同步编排）
- `flutter build apk --debug`
- `flutter build ios --no-codesign`
- iOS 真机：HealthKit 授权/拒绝/撤销、历史步数、后台任务模拟触发
- Android 真机：有/无计步传感器、权限拒绝、重启后基线、连续同步去重、WorkManager 触发
- 回归：`sleep` / `heartRate` 等仍走旧插件，行为不变；前台同步仍由 connectivity 监听触发

## 十二、风险与回退

- **Android 历史粒度缺失**：`TYPE_STEP_COUNTER` 只有开机累计值，第一期只能给出「上次同步以来」的步数；产品文案必须如实说明。
- **传感器差异**：部分设备没有计步传感器，或传感器在未注册监听时不累计；以 `capability` 明确返回原因。
- **开机/零点边界**：重启导致累计值归零，跨天同步无法精确拆分；`baseline.kt` 只保证不产生负值，不承诺日粒度准确。
- **权限**：Android 11+ 需要 `ACTIVITY_RECOGNITION` 运行时授权；拒绝后不能静默回退成 0 步。
- **iOS 读权限**：HealthKit 不保证回传明确的拒绝状态；`authorized` 只能 best-effort，「无数据」不能等同于「未授权」。
- **后台调度不保证准时**：Android Doze、iOS BGTaskScheduler 都由系统决定；文案不能承诺固定间隔。
- **iOS 强制退出**：用户上滑杀掉 app 后系统不会唤醒后台任务；这是平台行为，不作为缺陷修。
- **后台容器成本**：headless engine 启动、DB 初始化、auth 读取都可能超时；iOS 任务到期要能中断，避免被系统惩罚。
- **构建成本**：Kotlin/Native 首次编译和 CI 时间增加；先只编 `iosArm64` + `iosSimulatorArm64`。
- **工具链冲突**：AGP 9 built-in Kotlin 与 KMP 插件版本必须对齐；若 composite build 解析失败，回退为独立产出 AAR/XCFramework 再由 plugin 引用。
- **回退开关**：provider flag 保留 `health` 插件路径；后台同步可单独 `cancel()`，不影响步数。

## 十三、完成定义

- 步数：iOS HealthKit 与 Android 系统计步器均能通过新链路读取，真机验证通过。
- 后台同步：Android WorkManager 与 iOS BGTaskScheduler 均能唤醒并清空 pending write 队列；失败项按现有 retry 规则保留。
- `steps` 走 native，其他健康指标仍走 `health` 插件，现有测试不回归。
- 新增/修改文件符合第五节命名约定；新增模块模板写入 `native/README.md` 与 plugin `README.md`。
- `lib/features/health_data/README.md`、迁移日志已更新。
- 本计划文件删除；后续原生模块另开计划。
