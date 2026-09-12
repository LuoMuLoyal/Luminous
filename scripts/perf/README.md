# scripts/perf — 性能测量工具

手动测量工具,不接入 CI(pre-commit/daily 都不会跑),因为它需要一份人工录制的
trace 文件。

## `analyze_trace.dart` — 帧耗时 / 卡顿归因

DevTools「Performance → Export」导出的快照里,唯一载荷是 `performance.traceBinary`
—— 一串 **Perfetto protobuf** 字节(不是 Chrome JSON trace 格式)。仓库与 pub 缓存里
都没有对应 schema,所以这个脚本自己解码并报告"帧时间到底花在哪"。

```powershell
# 录制:flutter run --profile → DevTools → Performance → 录完 Export
dart run scripts/perf/analyze_trace.dart dart_devtools_<stamp>.json
dart run scripts/perf/analyze_trace.dart <snapshot.json> --top 15 --bucket 250
dart run scripts/perf/analyze_trace.dart <snapshot.json> --json   # 可 diff 的摘要
```

**改动前后复测**:用**完全相同**的操作脚本各录一次,比较 `--json` 的摘要。

> trace 文件是几十 MB 的临时产物,不要提交 —— `.gitignore` 已忽略
> `dart_devtools_*.json` / `*_trace.json`。

## 怎么读输出

| 指标 | 含义 |
|---|---|
| `UI frame`(`Frame`,Dart 类目) | UI isolate 上的 build + layout + paint —— **Dart 代码能影响的只有这一项** |
| `Raster`(`GPURasterizer::Draw`,Embedder 类目) | GPU 侧工作量。60Hz 预算 16.67ms;**当 raster p50 贴近预算时,任何额外 raster 开销都会掉帧**,与 Dart 侧多快无关 |
| `saveLayer` 列 | raster 开销的常见元凶:每个 `ShaderMask`(shimmer)与 `Opacity`/`ColorFiltered` 层每帧都要一次 `saveLayer` |
| `blocking work` | 图像解码、GC(`Scavenge`/`ConcurrentMark`)、平台通道等同步阻塞点 |

经验值:UI p50 在 1–3ms 属正常;若 raster p50 已 ≥15ms,先查 `saveLayer` 列与
`blocking work`,再考虑动 Dart 侧。

## 解码的 schema(按字段号)

| message | 用到的字段 |
|---|---|
| `Trace` | `1` = repeated `TracePacket`(`0x0A <len>` 分帧) |
| `TracePacket` | `8` = timestamp(纳秒)、`10` = trusted_packet_sequence_id、`11` = `TrackEvent`、`12` = `InternedData`、`60` = `TrackDescriptor` |
| `TrackEvent` | `1` = timestamp_delta_us、`4` = debug_annotations、`9` = type(1 begin / 2 end / 3 instant)、`11` = track_uuid、`16` = timestamp_absolute_us、`22` = categories、`23` = name |
| `DebugAnnotation` | `1` = name_iid、`10` = name、`2/3/4` = 数值、`6/9` = 字符串 |

两个易踩的坑(都已在实现里处理):

1. `TracePacket.timestamp` 是**纳秒**(BOOTTIME),而 `timestamp_delta_us` 是**微秒**,
   混用会得到荒唐的时长。
2. `TYPE_SLICE_END` 事件**没有名字**,按名字过滤会把所有 dur 丢掉 —— 配对时必须遍历
   全部事件。

数值精度受限于自写解码器,请以**相对关系**与事件名(直接来自 trace)为准。

## 已用这份数据得出的结论

见 `docs/explanation/motion-hierarchy.md` §6.1(骨架 shimmer 每帧 ~22 次 `saveLayer`;
1024×1024 图标按 64px 解码导致登录页 ~42ms 阻塞;瓶颈在 raster 而非 Dart)。
