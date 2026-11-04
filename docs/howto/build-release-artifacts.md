---
status: active
owner: frontend
updated: 2026-11-04
---

# How-To: 构建发布包（Android / iOS / Web / HarmonyOS）

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

## HarmonyOS

鸿蒙壳（`ohos/`）内嵌 Flutter Web 产物，**HAP 只能在装了 DevEco Studio 的本机打**：
托管 runner 没有 hvigor / ohpm / OpenHarmony SDK，CI（`deploy-harmonyos.yml`）只负责产
Web 制品，不跑 `assembleHap`。本机一条命令走完 Web 构建 → rawfile 平铺 → hvigor 打包：

```bash
python scripts/ohos/build_hap.py                 # debug
python scripts/ohos/build_hap.py --release       # release
python scripts/ohos/build_hap.py --skip-web      # 复用现有 build/web，只重打包
```

脚本内部的顺序有讲究，不要拆开手工跑：

1. **重建两个 gitignore 的 Web 构建期产物**：`dart compile js web/drift_worker.dart` →
   `web/drift_worker.js`；`python scripts/web/fetch_sqlite3_wasm.py` 按 `pubspec.yaml`
   的 `sqlite3` pin 下载 `web/sqlite3.wasm` 并校验 sha256。两者**必须在
   `flutter build web` 之前**生成，否则 Flutter 拷进 `build/web` 的是上一轮的旧文件。
2. `flutter build web --release --base-href "/" --no-web-resources-cdn`：壳内是本地资源，
   不能带 Pages 的 `/<repo>/` 前缀，也不能运行时从 `www.gstatic.com` 拉 CanvasKit。
3. 校验 `useLocalCanvasKit:true`、`base href="/"`、两个构建期产物存在（与 CI 断言同口径）。
4. 裁剪 canvaskit：删掉 `skwasm*` / `wimp*` 与所有 `.js.symbols`（壳内钉死 canvaskit
   单渲染器，这些用不到），约省 20 MB。
5. 把 `build/web` **平铺**进 `ohos/entry/src/main/resources/rawfile/`——不是
   `rawfile/web/`：`resource://` 协议不认 `<base href>`，放子目录会让 `flutter_bootstrap.js`
   / `main.dart.js` 全部 404（2026-10-23 模拟器实测）。
6. `hvigorw assembleHap`。产物默认在
   `ohos/entry/build/default/outputs/default/entry-default-unsigned.hap`。

`LUCENT_BASE_URL` 不设时回退到 `http://10.0.2.2:3000`（模拟器访问宿主机）。它只决定
**默认端点**：release 包不再因为缺少这个 define 在启动时抛 `StateError`，而是回退到平台
地址，并可在「设置 → 高级设置 → 开发者选项 → API 端点」里改到真实地址（选完即落盘、
立即重建 HTTP 客户端并登出旧会话）。出正式包仍建议显式设置，否则首屏会打
`127.0.0.1` / `10.0.2.2`。地址允许省略 scheme（`122.9.102.50:3000`），会归一化成
`http://122.9.102.50:3000`；无法解析成 http(s) 的值会被输入框拦下，不会写进偏好。
回退字体（CJK）由 `python scripts/ohos/fetch_fallback_fonts.py --all` 单独维护，
缺了构建不失败但中文会显示成方块。

### 签名

`ohos/build-profile.json5` 目前是 `signingConfigs: []`，所以 hvigor 只 WARN
`Will skip sign 'hos_hap'`，产出的 HAP **未签名**：真机 `hdc install` 会失败，
模拟器一般能装。签名材料（`.p12` / `.cer` / `.p7b` / `.csr`）已在 `ohos/.gitignore`
里，**一律不入库**；bundleName 是 `com.devluo.luminous`（`ohos/AppScope/app.json5`），
证书、Profile 必须和它对上。

**本地调试：DevEco 自动签名（最省事）**

1. 用 DevEco 打开 `ohos/`，`File` → `Project Structure` → `Signing Configs`。
2. 勾选 `Automatically generate signature`（需要登录华为账号）。连了真机时会顺带
   登记设备，生成调试证书与 Profile。
3. `Sync Now`：DevEco 把签名材料放在用户目录（`~/.ohos/config/openharmony/` 附近），
   并把 `signingConfigs` 写进 `ohos/build-profile.json5`。
4. 之后 `python scripts/ohos/build_hap.py --release --skip-web` 直接产出**已签名**
   HAP（`entry-default-signed.hap`），`python scripts/ohos/install_hap.py --launch` 可装可拉起。

自动签名绑定当前账号与设备；换机器/换设备要重新生成。`signingConfigs` 里的密码字段
可能被 DevEco 加密保存，提交前检查 diff，别把本机路径/口令带进仓库。

**正式发布：AppGallery Connect（AGC）证书 + Profile**

1. AGC → `用户与访问` → `证书管理`：生成密钥库（`.p12` + storePassword / keyPassword），
   用 DevEco 或 `hap-sign-tool generate-keypair` 生成，创建 CSR 后上传，下载发布证书
   `.cer`。
2. AGC → `证书、Profile 与 AID 管理` → 新增 Profile：选应用（`com.devluo.luminous`）、
   选刚建的证书、按用途选设备——调试 Profile 需登记设备 UDID，发布 Profile 用于上架。
   下载 `.p7b`。
3. 配 `ohos/build-profile.json5`（路径指向本机文件，密钥材料不入库）：

   ```json5
   "signingConfigs": [
     {
       "name": "default",
       "type": "HarmonyOS",
       "material": {
         "certpath": "C:/keys/luminous.cer",
         "storePassword": "<p12 密码>",
         "keyAlias": "luminous",
         "keyPassword": "<alias 密码>",
         "profile": "C:/keys/luminous.p7b",
         "signAlg": "SHA256withECDSA",
         "storeFile": "C:/keys/luminous.p12"
       }
     }
   ]
   ```

4. 重跑 `python scripts/ohos/build_hap.py --release --skip-web`。

**命令行手动签（不进 DevEco）**：用 SDK 自带的 `hap-sign-tool.jar`（Java 用 DevEco
自带的 jbr 即可）：

```bash
java -jar "$DEVECO_HOME/sdk/default/openharmony/toolchains/lib/hap-sign-tool.jar" sign-app \
  -mode "localSign" \
  -keyAlias "luminous" \
  -signAlg "SHA256withECDSA" \
  -appCertFile "C:/keys/luminous.cer" \
  -profileFile "C:/keys/luminous.p7b" \
  -inFile "ohos/entry/build/default/outputs/default/entry-default-unsigned.hap" \
  -keystoreFile "C:/keys/luminous.p12" \
  -outFile "ohos/entry/build/default/outputs/default/entry-default-signed.hap" \
  -keyPwd "<alias 密码>" \
  -keystorePwd "<p12 密码>" \
  -compatibleVersion 26
```

`-compatibleVersion` 取 `ohos/build-profile.json5` 的 `compatibleSdkVersion` 主版本
（当前 `26.0.0` → `26`）。签完可先用 `verify-app` 自检，再
`python scripts/ohos/install_hap.py --hap <signed.hap> --launch` 安装。

### 排查

| 现象                                        | 首先怀疑                                                                                              |
| ------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| `hdc install` 报签名/Profile 校验失败       | HAP 未签名（看 hvigor 是否 `Will skip sign`），或 Profile 的 bundleName / 证书 / 设备 UDID 与包不匹配 |
| 启动白屏、`ERR_FILE_NOT_FOUND`              | Web 产物没平铺到 `rawfile` 根（是否手工放进了 `rawfile/web/`），或漏了 `--base-href "/"`             |
| 启动停在 splash（叶子 logo），日志只有 `console: Uncaught` | `runApp` 之前的平台插件调用抛错：`path_provider` 一类没有 web 实现的插件会抛 `MissingPluginException`。`hdc shell hilog -x` 过滤 tag `LuminousWeb` 看 `pageBegin` 之后的 console |
| 仍从 `www.gstatic.com` 拉资源、壳内白屏     | 漏了 `--no-web-resources-cdn`，`useLocalCanvasKit` 不为 `true`                                       |
| drift / 本地库在 Web 端不可用               | `drift_worker.js` 或 `sqlite3.wasm` 缺失、或与 `sqlite3` 包版本不匹配（重跑 `build_hap.py`）          |
| 中文显示成方块                              | 缺 `rawfile/fonts/` 回退字体：`python scripts/ohos/fetch_fallback_fonts.py --all`                    |
| 红屏 `ProviderException` + `FormatException: Scheme not starting with alphabetic character` | API 端点缺 scheme（如 `122.9.102.50:3000`）。新代码已归一化并拦非法输入；旧包需重建，或先在「高级设置 → 开发者选项」改成 `http://` 开头的地址 |
| 包体比预期大 20 MB 左右                     | 手工拷贝了未裁剪的 `build/web`（脚本会自动裁 canvaskit 的 skwasm/wimp 与 `.js.symbols`）             |

## Linux 桌面（各发行版 / 虚拟机）排查

| 现象                                                                          | 首先怀疑                                                                                                |
| ----------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| 终端无窗口，`lock failed, path = .../kv/preferences.lock`，`errno = 11`       | 另一个实例还持有 Hive 的 `flock`：`pkill -f luminous` 后重开。2026-11-03 前的构建把偏好库放在共享的 `$HOME/Documents`，两份安装必撞锁；现在落在应用私有的 application support 目录（`~/.local/share/luminous`） |
| 停在 `Using the Impeller rendering backend (OpenGLES)` 长时间无窗口            | 虚拟机里的软件 OpenGL（llvmpipe）。`glxinfo -B` 看 `OpenGL renderer`；虚拟机设置里开 3D 加速（显存 ≥256 MB）再试 |
| 启动即退、只有 `Gdk-Message: Unable to load ... from the cursor theme`         | 缺光标主题图标，属警告。`sudo apt install adwaita-icon-theme` 消除                                         |
| `ldd bundle/luminous` 报 `not found`                                          | 缺 GTK3 运行库：装 `libgtk-3-0t64`（24.04 前叫 `libgtk-3-0`）、`libsecret-1-0`、`libjsoncpp25`            |

偏好库与本地库都在 `getApplicationSupportDirectory()` 下：Linux 是
`~/.local/share/luminous`（`kv/preferences` 与 `luminous.db`）。不要改回 documents
目录——那是按用户共享的 `~/Documents`，不是按应用隔离的。

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
