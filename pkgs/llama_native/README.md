# pkgs/llama_native — 端侧 LLM 推理

基于 llama.cpp 的 Flutter 端侧推理包。**当前只有 Dart 侧完整实现，原生库尚未构建**，
因此还不能真正跑起来。

## 为什么是独立包而不是 `lib/core/`

原生构建（Android ABI、iOS framework、桌面 DLL）与 Flutter 应用代码是两种生命周期。
放进 `lib/` 会让 app 的 `flutter test`、`flutter analyze` 与原生工具链耦合；作为 path
依赖的包，app 只依赖 `LlamaEngine` 端口，原生构建可以独立推进。

## 分层（Clean，单向依赖）

```text
domain/                     纯 Dart：无 FFI、无 isolate、无 I/O
  entities/                 GenerationOptions / EngineOptions / ModelInfo /
                            ChatMessage / GenerationResult
  failures/                 LlamaFailure：稳定 kind，而非字符串匹配
  ports/llama_engine.dart   ← app 唯一依赖的接口
  services/                 CollectGeneration（流→结果）、fallbackChatPrompt
data/                       llama.cpp 的实现
  ffi/                      头文件的机械映射，无逻辑
  isolate/                  worker_protocol（跨 isolate 词汇）+ worker（唯一持有原生句柄）
  worker/                   主 isolate 侧会话
  repositories/             LlamaCppEngine：domain ⇄ worker 翻译
```

**app 不 import `data/`**。这条是分层的目的：换后端（LiteRT-LM、MLC）只是加一个
`data/xxx/`，不动任何调用点；测试里换成 fake engine 也不需要原生库。

## 三个关键决策

**1. C shim 而非直接绑 `llama.h`。** llama.cpp 的 C API 在版本间改名、改结构体
（`llama_load_model_from_file` → `llama_model_load_from_file`，sampler 链整个换过）。
直接绑定的后果是升级时段错误而不是编译错误。`src-native/llama_shim.h` 是**我们控制
的**约 10 个函数，升级只改那一个 `.cpp`。

**2. 推理必须在 worker isolate。** `llama_decode` 每条 token 阻塞数百毫秒；在主
isolate 上会让 UI 在整个生成过程冻住。这是正确性要求，不是优化。

**3. 原生句柄只在 worker 里。** `Pointer` 不能跨 isolate 传递，且两个 isolate 共用一个
句柄是未定义行为。主 isolate 只看见命令和值。

## 已规避的坑

- **C 回调捕获不了 Dart 闭包**：token sink 走模块级变量，作用域严格限定在一次
  `generate` 调用内，`finally` 里清空——否则下一次生成会继承一个已无人监听的端口。
- **`StreamController.close()` 返回 Future，`addError()` 返回 void**：前者要
  `unawaited`，后者不能包（包了就是 `use_of_void_result`）。
- **dispose 顺序**：先发 `DisposeWorker` 等 ack，再置 `_closed`。反过来的话 `_send`
  会直接拒绝，原生句柄在进程退出时仍被持有。
- **`.gitignore` 的 `/build/` 只锚定根目录**：子包自己的 `build/` 会漏进提交，已改为
  `**/build/`。

## 未完成

原生构建、模型管理、app 接线都还没做，记在 `docs/TODO.md`。