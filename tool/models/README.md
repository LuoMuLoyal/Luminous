# tool/models — 端侧模型发布

把 `build-manifest.ps1` 生成的清单与模型文件一起上传到 release，app 才能下载并校验。

## 为什么清单要由脚本生成

清单里同时有 `downloadUrl` 和 `sha256`。**URL 与摘要必须来自同一次产出**：手抄一个哈希，
只要错一个字符，每次下载都会报完整性失败，而那个报错会把人引去怀疑网络。

## 用法

```powershell
# 1. 把 .gguf 放到同一目录
#    （从 HuggingFace 下载，选 Q4_K_M；4-bit 适合手机）
# 2. 写 models.json（从 models.json.example 复制，填 id / name / fileName / contextLength）
# 3. 生成清单
.\tool\models\build-manifest.ps1 `
    -ModelDir .\tool\models `
    -Tag v1 `
    -Repository <owner>/<repo>
```

脚本会算每个文件的 SHA-256 与字节数，写进 `manifest.json`。

## 上传

把 `.gguf` 文件和 `manifest.json` **上传到同一个 release tag**。tag 与仓库名必须与
`lib/core/ai/model_manifest_source.dart` 里的 `ModelRelease` 一致：

```dart
static const repository = '<owner>/<repo>';
static const tag = 'v1';
static const manifestAsset = 'manifest.json';
```

tag 固定而不是浮动：浮动 tag 会让未来一次上传在客户端零改动的情况下换掉 app 实际运行的
权重，那正是摘要校验要防的事。

## 模型选择

| 设备内存 | 建议 |
| --- | --- |
| 4 GB | 0.5–1B（Qwen3-0.6B、Gemma 3 1B） |
| 6 GB | 1–2B（Qwen3-1.7B） |
| 8 GB | 2–3B（Gemma 4 E2B、Qwen3 4B） |
| 12 GB+ | 4B（Phi-4-mini） |

量化统一用 Q4_K_M。`contextLength` 填模型训练时的窗口，不必等于 app 实际分配的——
`LocalAssistant` 会把它限制在 4096，因为 KV 内存随窗口线性增长。

## 上传后自检

`manifest.json` 里的 `sha256` 与 `sizeBytes` 必须与 host 上的文件一致。上传后跑一次：

```powershell
(Get-FileHash <本地文件> -Algorithm SHA256).Hash
```

不匹配时 app 侧的故障表现是 `LocalModelFailure.integrityMismatch`，文件会被删除。