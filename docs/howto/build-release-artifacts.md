---
status: active
owner: frontend
updated: 2026-10-06
---

# How-To: 构建发布包（Android / iOS / Web）

日常 `flutter run` 见 [README](../../README.md)；本文只覆盖**发布构建**——怎么出包、
每个包要注入什么、以及出问题先看哪里。

## 前置

- 生成物就绪（全新 clone、ARB 或合同变更后必跑）：

  ```bash
  dart run scripts/contract/bootstrap.dart
  ```

  `generated/lucent_api` 是独立 package，根 `build_runner` 不替它生成被 gitignore 的
  `*.g.dart`；缺这一步 `flutter build` 直接编译失败。

- 后端地址是**编译期**输入，release 构建强制要求：
  `LUCENT_BASE_URL` 缺失时 `lib/core/network/client/base_url.dart` 在
  `kReleaseMode` 下抛 `StateError`（`LucentBaseUrl.value`），而不是发出一个连不上
  后端的包。本地跑发布构建时用 `.env` 注入：

  ```bash
  flutter build apk --release --split-per-abi --dart-define-from-file=.env
  ```

  可选变量（`SENTRY_DSN` / `SUPPORT_EMAIL` / `JPUSH_APP_KEY` /
  `WECHAT_MOBILE_APP_ID` / `WECHAT_IOS_UNIVERSAL_LINK`）缺失只关闭对应能力，
  不阻断构建；清单与含义见 [README § Environment files](../../README.md) 与
  `.env.example`。

## Android

每个 ABI 一个自洽 APK（各自带 `libflutter.so` + `libapp.so`）：

```bash
flutter build apk --release --split-per-abi --dart-define-from-file=.env
```

产物（`build/app/outputs/flutter-apk/`）：

| 文件                          | 用途                                  |
| ----------------------------- | ------------------------------------- |
| `app-arm64-v8a-release.apk`   | 所有现代 64 位 ARM 手机（含国内真机） |
| `app-armeabi-v7a-release.apk` | 32 位 ARM 老设备                      |
| `app-x86_64-release.apk`      | x86_64 模拟器（真机不用）             |

### ABI 的三条硬约束

踩过一次「release 包能装能启动、`onCreate` 立刻崩」的坑，根因是引擎 ABI 与打包
剔除规则互相覆盖。以下三条不要违反：

1. **不要设 `abiFilters`。** fat APK 路径下 Flutter Gradle 插件会清空并写入自己的
   `PLATFORM_ABI_LIST`；`--split-per-abi` 路径下非空 `abiFilters` 与 ABI splits
   冲突（FlutterPlugin.kt 的 `configureAbis` 注释明确警告）。
2. **不要用变体级 `jniLibs` excludes 收 ABI。** `variant.packaging` 是**变体级、非
   产物级**：启用 splits 后它对每个 split 产物都生效，排除 `lib/x86_64/**` 会连
   x86_64 split 自己的引擎一起删掉。
3. **ABI 选择只交给 Flutter 工具。** fat 单包（默认）或 `--split-per-abi`（推荐）；
   要缩范围用 `--target-platform android-arm64`，不要回到 1 / 2 两条。

改完 ABI 相关配置后，**必须**验证每个 APK 自带引擎——这类包能装能启动、只在
`onCreate` 崩，肉眼看不出来：

```bash
python -c "
import glob, zipfile, os
for apk in sorted(glob.glob('build/app/outputs/flutter-apk/app-*-release.apk')):
    abi = os.path.basename(apk)[4:-len('-release.apk')]
    names = set(zipfile.ZipFile(apk).namelist())
    for lib in ('libflutter.so', 'libapp.so'):
        assert f'lib/{abi}/{lib}' in names, f'{apk} missing lib/{abi}/{lib}'
    print(f'OK: {apk} carries lib/{abi}/libflutter.so + libapp.so')
"
```

CI（`deploy-android.yml`）已内置同一条断言，缺引擎即失败。

### 签名

- `android/key.properties` 存在且四个字段齐全（`storeFile` / `storePassword` /
  `keyAlias` / `keyPassword`）时走 release 签名；否则**回落到 debug 签名**——
  可安装、不可上架。两个文件都被 gitignore（`android/.gitignore`）。
- 本地出可上架包：`cp android/key.properties.example android/key.properties` 填入真值，
  并把 keystore（`android/release-key.jks`）放到位。**不要把 keystore 或密码写进
  仓库**。
- CI 侧接入 release 签名是未完成项，见 [TODO](../TODO.md)。

## iOS

开发机是 Windows，本地编译不了 iOS：**CI 是唯一的编译验证面**。

```bash
# 仅在 macOS 上
flutter build ios --release --no-codesign \
  --obfuscate --split-debug-info=build/symbols-ios \
  --dart-define=LUCENT_BASE_URL="$LUCENT_BASE_URL"
```

`deploy-ios.yml` 在托管 `macos-latest` 上执行同一命令，把 `Runner.app` 打成未签名
IPA（`luminous-ios-unsigned-ipa`）。装真机需用 Sideloadly / AltStore 以**自己的
Apple ID** 重签；签名分发与 TestFlight 未接入（见 [TODO](../TODO.md)）。

微信相关：`ios/Flutter/Wechat.xcconfig` 被 gitignore，由 `WECHAT_MOBILE_APP_ID`
secret 在 CI 生成；缺 secret 时复制 `Wechat.example.xcconfig` 占位（只影响微信登录）。

## Web

```bash
dart compile js web/drift_worker.dart -o web/drift_worker.js -O4   # Web 端 drift worker
flutter build web --release --base-href "/<repo-name>/" --dart-define-from-file=.env
```

- `drift_worker.js` 由 `lib/core/database/connection_web.dart` 消费，发布前必须编译。
- **不要加 `--wasm`**：wasm 默认渲染器 skwasm 在移动浏览器有内容区高度 0 的布局 bug
  （页面主体空白、底部导航跑到顶部）。纯 dart2js + canvaskit 才是当前目标，
  `web/flutter_bootstrap.js` 显式钉了 `renderer: 'canvaskit'` 防回归。
- `deploy-web.yml` 发布到 GitHub Pages，自动触发绑定 `push` 到 `refactor` 分支
  （不是 `main`）。

## 验证

```bash
git diff --check                    # 无空白错误
flutter analyze                     # 无分析错误
flutter test                        # 单元 / Widget 测试
dart run scripts/workflows/daily.dart   # 仓库安全级检查
```

装真机复验时注意：只带 ABI 正确的包还不够，`LUCENT_BASE_URL` 必须真的可达——
线上主机端口按 IP 白名单放行，真机走蜂窝数据或换 Wi-Fi 都可能连不上。

## 排查

| 现象                                                                          | 首先怀疑                                                                               |
| ----------------------------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| 装得上，启动瞬间闪退，日志`Could not find 'libflutter.so' ... only found: []` | APK 没打进 Flutter 引擎：见上文「ABI 的三条硬约束」，并按断言脚本复验每个 split        |
| release 打开即崩 / 白屏                                                       | `LUCENT_BASE_URL` 未注入 → `LucentBaseUrl.value` 抛 `StateError`（release 专用路径）   |
| 真机连不上后端，模拟器正常                                                    | 模拟器走`10.0.2.2` 回退（`base_url.dart`），真机没有该回退；确认 define 地址与端口放行 |
| `flutter build` 编译期失败、缺 `part '*.g.dart'`                              | 未跑`dart run scripts/contract/bootstrap.dart`                                         |
| 推送在 release 下静默不工作                                                   | `JPUSH_APP_KEY` 未注入（Dart define 与 Gradle 属性缺一不可），缺省即静默禁用，非故障   |
| Web 页面主体空白、底栏跑到顶部                                                | 误加了`--wasm`；去掉，回到 dart2js + canvaskit                                         |

## 详细参考

- [README](../../README.md) — 环境变量、环境文件与 CI 全貌
- [`.github/workflows/README.md`](../../.github/workflows/README.md) — 四个工作流职责与产物
- [Project Governance](../explanation/project-governance.md) — 发布面与生成物前置步骤的治理口径
