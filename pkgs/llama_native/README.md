# pkgs/llama_native — 端侧 LLM 推理（Rust 核心）

基于 llama.cpp 的端侧推理包，核心用 Rust（`llama-cpp-2`），Flutter 侧通过
`flutter_rust_bridge` 调用。**Dart 侧与 Rust 侧代码已写完，但桥接代码尚未生成、
Rust crate 尚未编译过**，因此包还不能真正推理。

## 为什么核心是 Rust

三个理由，都不是"Rust 更时髦"：

1. **绑定从源码生成**。`llama-cpp-2` 从 vendor 的 llama.cpp 源码生成 bindings，
   上游改名/改结构体时是**编译错误**而非运行时段错误。手写 C FFI 需要自己维护一个
   shim 来吸收这种漂移，那份 shim 就是 bug 的温床。
2. **所有权管住原生句柄**。模型与 context 的生命周期由类型系统保证，不需要 Dart 侧
   手工配对 `malloc`/`free`、维护 pending 调用表。
3. **`flutter_rust_bridge` 生成类型安全绑定**，Dart 侧看到的是
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
  bridge/                   唯一命名生成符号的文件（生成物改名只影响这里）
  repositories/             RustLlamaEngine：实现端口，错误映射与生命周期
rust/
  src/api.rs                桥接面：Dart 可调的全部函数
  src/engine.rs             llama.cpp 会话（唯一持有模型与 context 的地方）
  src/options.rs            跨桥的值类型
  src/error.rs              失败词汇（避免用 anyhow 把错误化成一个字符串）
```

**app 不 import `data/`**。测试里换成 fake engine 不需要原生库；换后端只是加一个
`data/xxx/`。

## 三个关键决策

**1. 错误是闭合枚举，不是 `anyhow`。** llama-cpp-2 的示例普遍用 `anyhow`，但那会把
失败类型擦成字符串，跨桥后 Dart 只能靠文本匹配去决定「是给用户一个下载按钮，还是
一个更小的 context」。`LlamaError` 的每个 variant 对应一种用户可以采取的行动。

**2. 桥接面刻意很小。** 每个跨桥类型都要两边重新生成，签名变化会静默让另一端失效。
`rust/src/api.rs` 只有五个函数（load / info / formatChatPrompt / generate /
release），生成物因此可读。

**3. 会话句柄是不透明的。** `LlamaModel` / context 不暴露给 Dart：一个 context 的
KV cache 不能被两个并发生成共享。`Mutex` 串行化是那个保证，不是性能妥协。

## 已规避的坑

- **`/build/` 只锚定仓库根**：子包测试产生的 `pkgs/*/build/` 会漏进提交，已改为 `**/build/`。
- **`StreamController.addError()` 返回 `void`、`close()` 返回 `Future`**：前者不能包
  `unawaited`（`use_of_void_result`），后者必须包（`discarded_futures`）。
- **取消语义**：生成被停止时保留已产出的文本，因为用户已经看到了它。

## 未完成

桥接代码生成、Rust 编译、原生库打包（Android ABI / iOS framework / 桌面 DLL）、
模型管理、app 接线、GBNF 生成器、设备可用性探测。全部记在 `docs/TODO.md` 的
「端侧 LLM」小节，按依赖顺序排列。

## 生成命令

```bash
cd pkgs/llama_native
dart run flutter_rust_bridge_codegen generate    # rust/src/api.rs → lib/src/data/ffi/
cd rust && cargo build                          # 需要 cmake + MSVC（见 TODO）
```