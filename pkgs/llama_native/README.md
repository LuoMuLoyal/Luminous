# pkgs/llama_native — 端侧 LLM 推理（Rust 核心）

基于 llama.cpp 的端侧推理包，核心用 Rust（`llama-cpp-2`），Flutter 侧通过
`flutter_rust_bridge` 调用。**Dart 与 Rust 两侧已编译通过、桥接代码已生成、22 个 Dart
测试 + 12 个 Rust 测试通过**，但还没有在真机上跑过模型。

## 为什么核心是 Rust

三个理由，都不是「Rust 更时髦」：

1. **绑定从源码生成**。`llama-cpp-2` 从 vendor 的 llama.cpp 源码生成 bindings，
   上游改名/改结构体时是**编译错误**而非运行时段错误。手写 C FFI 需要自己维护一个
   shim 来吸收这种漂移，那份 shim 就是 bug 的温床。
2. **所有权管住原生句柄**。模型与 context 的生命周期由类型系统保证，不需要 Dart 侧
   手工配对 `malloc`/`free`、维护 pending 调用表。
3. **`flutter_rust_bridge` 生成类型安全绑定**，Dart 看到的是
   `Future<ModelInfo>` / `Stream<String>` / 类型化错误，不是指针。

## 分层（Clean，`app → domain/ports ← data`）

```text
domain/                     纯 Dart：无原生代码、无 isolate、无 I/O
  entities/                 GenerationOptions / EngineOptions / ModelInfo /
                            ChatMessage / GenerationResult
  failures/                 LlamaFailure：稳定 kind，而非字符串匹配
  ports/llama_engine.dart   ← app 唯一依赖的接口
  services/                 CollectGeneration（流→结果）、fallbackChatPrompt
data/
  bridge/                   LlamaBridge（可注入接缝）+ 错误映射 +
                            RustBridgeBindings（唯一命名生成符号的文件）
  ffi/                      codegen 生成物，禁止手改
  repositories/             RustLlamaEngine：实现端口
rust/
  src/api.rs                桥接面：Dart 可调的全部函数
  src/engine.rs             llama.cpp 会话（唯一持有模型与 context 的地方）
  src/options.rs            跨桥的值类型
  src/error.rs              失败词汇
  src/frb_generated.rs      codegen 生成物，禁止手改
```

## 构建（Windows）

需要的东西与设置：

```powershell
$env:LIBCLANG_PATH = 'C:\Program Files\LLVM\bin'   # bindgen 必需，缺了直接 panic
$env:Path = "C:\Program Files\LLVM\bin;"
         + "D:\Microsoft Visual Studio\BuildTools\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin;"
         + "D:\Microsoft Visual Studio\BuildTools\Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja;"
         + $env:Path
cd rust; cargo build       # 首次要编译 llama.cpp 本体，数分钟
```

`cmake` 与 `ninja` 由 VS Build Tools 自带，不需要完整 VS。LLVM 需要单独装
（`winget install LLVM.LLVM`），因为 `bindgen` 依赖 `libclang.dll`。

## 重新生成桥接代码

```bash
cd pkgs/llama_native
flutter_rust_bridge_codegen generate
```

**生成后必须手动修 `rust/src/lib.rs`**：生成器把 `mod frb_generated;` 注入到文件最顶端，
即 `//!` 文档注释之前，Rust 会报 `E0753`。把它移到 `pub mod` 那一组里。这个位置每次都会
被覆盖，所以每次都要改。

## 已规避的坑

- **`llama-cpp-2` 0.1.161 的真实 API 与文档有出入**：没有 `AddBos` 枚举（用
  `tokenize(bytes, add_special, parse_special)`）；`token_to_piece` 返回 `Vec<u8>` 而非
  `&str`（一个 token 可能是半个 UTF-8）；没有 `with_sampler` 链式构造（要把 sampler 收进
  `Vec` 再 `chain_simple`）；`penalties` 的第一个参数是 `n_vocab`。
- **codegen 看不透类型别名**：`type LlamaResult<T> = Result<T, LlamaError>` 会被当成不透明
  句柄，生成的 Dart 无法读取值或错误。签名必须写全 `Result<T, LlamaError>`。
- **`StreamSink` 在生成之前不存在**，所以 `generate` 的回调版本能让 crate 先编译通过、
  单独验证 llama.cpp 集成，不必等 codegen。
- **错误标签必须与 `Display` 一致**：bridge 没有类型化错误通道，Dart 靠文本匹配恢复
  kind，所以 `Display` 直接用 `kind()` 拼前缀。这个不一致是测试抓到的。
- **`/build/` 只锚定仓库根**：子包测试产生的 `pkgs/*/build/` 会漏进提交，已改为 `**/build/`。
- **PowerShell 替换会吃掉反引号**：`Replace` 里的 `` `f `` 变义成换页符，把 pubspec 写坏
  过一次；改 yaml 用 `write` 工具整体重写。

## 未完成

模型清单（`lib/core/ai/local_model.dart` 的 `availableLocalModels` 是空的）、下载源、
真机验证、平台原生库打包、app 接线、GBNF 生成器、设备可用性探测。全部记在 `docs/TODO.md`
的「端侧 LLM」小节。