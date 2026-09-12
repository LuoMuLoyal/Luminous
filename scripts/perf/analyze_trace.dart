import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

/// Frame-time / jank analyser for DevTools performance snapshots.
///
/// ## Why this exists
///
/// DevTools "Export" writes a *snapshot* JSON whose only payload is
/// `performance.traceBinary` — a byte array in **Perfetto protobuf** form, not
/// the Chrome JSON trace format. Nothing in the repo (or in the pub cache) can
/// read it, so this script decodes it and reports where frame time actually
/// goes. It is a measurement tool, not a check: it never fails the build and is
/// not wired into `scripts/workflows/daily.dart`.
///
/// ## Usage
///
/// ```powershell
/// # Record: flutter run --profile  → DevTools → Performance → record → Export
/// dart run scripts/perf/analyze_trace.dart dart_devtools_<stamp>.json
/// dart run scripts/perf/analyze_trace.dart <snapshot.json> --top 15 --bucket 250
/// dart run scripts/perf/analyze_trace.dart <snapshot.json> --json   # diffable
/// ```
///
/// Reproduce the *same* interaction script before and after a change, then
/// compare the `--json` summaries.
///
/// ## Decoded schema (Perfetto, by field number)
///
/// | message | fields used here |
/// |---|---|
/// | `Trace` | `1` = repeated `TracePacket` (0x0A `<len>` framing) |
/// | `TracePacket` | `8` = timestamp (ns), `10` = trusted_packet_sequence_id, `11` = `TrackEvent`, `12` = `InternedData`, `60` = `TrackDescriptor` |
/// | `TrackEvent` | `1` = timestamp_delta_us, `4` = debug_annotations, `9` = type (1 begin / 2 end / 3 instant), `11` = track_uuid, `22` = categories, `23` = name, `16` = timestamp_absolute_us, `47` = flow_ids |
/// | `DebugAnnotation` | `1` = name_iid, `10` = name, `2/3/4` = numeric value, `6/9` = string value |
///
/// Slice durations are reconstructed by pairing `TYPE_SLICE_BEGIN` /
/// `TYPE_SLICE_END` per (sequence, track) — **end events carry no name**, so the
/// pairing must walk all events, not just the named ones.
///
/// ## Reading the output
///
/// * `UI` (`Frame`, Dart category) = build + layout + paint on the UI isolate.
///   This is what Flutter/Dart code can influence.
/// * `Raster` (`GPURasterizer::Draw`, Embedder category) = GPU-side work. On a
///   60 Hz device the budget is 16.67 ms; when raster's p50 sits near it, *any*
///   extra raster cost (an extra `saveLayer`, a texture upload) drops frames no
///   matter how cheap the Dart side is.
/// * `saveLayer` per bucket is the usual raster culprit: every `ShaderMask`
///   (shimmer) and `Opacity`/`ColorFiltered` layer costs one per frame.
///
/// Absolute numbers are approximate (hand-rolled decoder); trust the relative
/// picture and the event names, which come straight from the trace.
Future<void> main(List<String> args) async {
  final options = _Options.parse(args);
  if (options == null) {
    stdout.writeln(_usage);
    exit(64);
  }

  final file = File(options.path);
  if (!file.existsSync()) {
    stderr.writeln('Snapshot not found: ${options.path}');
    exit(66);
  }

  final raw = file.readAsBytesSync();
  final meta = _SnapshotMeta.fromRaw(raw);
  final bytes = _extractTraceBinary(raw);
  final decoded = _decode(bytes);
  if (decoded.events.isEmpty) {
    stderr.writeln(
      'Decoded ${bytes.length} trace bytes but found no track events. The '
      'snapshot may come from an unsupported DevTools version, or the recording '
      'was empty.',
    );
    exit(70);
  }
  final analysis = _Analysis(decoded, options.bucketMs);

  if (options.json) {
    stdout.writeln(
      const JsonEncoder.withIndent(
        '  ',
      ).convert(analysis.toJson(meta: meta, top: options.top)),
    );
    return;
  }

  _printReport(analysis, meta: meta, options: options);
}

const String _usage = '''
Analyse a DevTools performance snapshot (profile build recommended).

Usage:
  dart run scripts/perf/analyze_trace.dart <snapshot.json> [options]

Options:
  --top <n>      rows in the "top" tables (default 25)
  --bucket <ms>  timeline bucket size in ms (default 500)
  --json         print only a machine-readable summary (for before/after diffs)
  --help         show this message

Record a comparable trace:
  flutter run --profile   →  DevTools → Performance → record the exact same
  interaction script       →  Export → save the JSON → run this script.
''';

// ---------------------------------------------------------------- options

class _Options {
  const _Options({
    required this.path,
    required this.top,
    required this.bucketMs,
    required this.json,
  });

  final String path;
  final int top;
  final int bucketMs;
  final bool json;

  static _Options? parse(List<String> args) {
    if (args.isEmpty || args.contains('--help') || args.contains('-h')) {
      return null;
    }
    var top = 25;
    var bucketMs = 500;
    var json = false;
    String? path;
    for (var i = 0; i < args.length; i++) {
      final arg = args[i];
      switch (arg) {
        case '--json':
          json = true;
        case '--top':
          if (i + 1 >= args.length) return null;
          top = int.tryParse(args[++i]) ?? top;
        case '--bucket':
          if (i + 1 >= args.length) return null;
          bucketMs = int.tryParse(args[++i]) ?? bucketMs;
        default:
          if (arg.startsWith('--')) return null;
          path ??= arg;
      }
    }
    if (path == null || top <= 0 || bucketMs <= 0) return null;
    return _Options(path: path, top: top, bucketMs: bucketMs, json: json);
  }
}

// ------------------------------------------------------------ snapshot IO

class _SnapshotMeta {
  const _SnapshotMeta({
    required this.profileBuild,
    required this.operatingSystem,
    required this.flutterVersion,
    required this.devToolsVersion,
  });

  final bool profileBuild;
  final String operatingSystem;
  final String flutterVersion;
  final String devToolsVersion;

  /// Reads the small header block without json-decoding the multi-megabyte
  /// `traceBinary` array.
  static _SnapshotMeta fromRaw(Uint8List raw) {
    final head = utf8.decode(
      raw.sublist(0, math.min(raw.length, 1200)),
      allowMalformed: true,
    );
    String pick(String key, String fallback) {
      final match = RegExp('"$key"\\s*:\\s*"?([^",}]+)"?').firstMatch(head);
      return match == null ? fallback : match.group(1)!.trim();
    }

    return _SnapshotMeta(
      profileBuild: pick('isProfileBuild', '?') == 'true',
      operatingSystem: pick('operatingSystem', '?'),
      flutterVersion: pick('flutterVersion', '?'),
      devToolsVersion: pick('devToolsVersion', '?'),
    );
  }
}

/// Pulls `performance.traceBinary` (a JSON array of byte values) out of the
/// snapshot without allocating one boxed object per byte.
Uint8List _extractTraceBinary(Uint8List raw) {
  final marker = ascii.encode('"traceBinary":[');
  var start = -1;
  for (var i = 0; i < raw.length - marker.length; i++) {
    if (raw[i] != marker[0]) continue;
    var matched = true;
    for (var j = 1; j < marker.length; j++) {
      if (raw[i + j] != marker[j]) {
        matched = false;
        break;
      }
    }
    if (matched) {
      start = i + marker.length;
      break;
    }
  }
  if (start < 0) {
    stderr.writeln(
      'No "traceBinary" array found — is this a DevTools performance snapshot?',
    );
    exit(65);
  }

  final out = BytesBuilder(copy: true);
  var value = 0;
  var inNumber = false;
  for (var i = start; i < raw.length; i++) {
    final byte = raw[i];
    if (byte == 0x5D) break; // ']'
    if (byte >= 0x30 && byte <= 0x39) {
      value = value * 10 + (byte - 0x30);
      inNumber = true;
    } else if (inNumber) {
      out.addByte(value & 0xFF);
      value = 0;
      inNumber = false;
    }
  }
  if (inNumber) out.addByte(value & 0xFF);
  return out.takeBytes();
}

// -------------------------------------------------------------- protobuf

class _Field {
  const _Field(this.number, this.wire, this.value, this.bytes, this.start);

  final int number;
  final int wire;
  final int value;
  final Uint8List? bytes;
  final int start;
}

class _Reader {
  _Reader(this.data, this.pos, this.end);

  final Uint8List data;
  int pos;
  final int end;

  /// Returns `(value, offsetAfter)`.
  (int, int)? varint() {
    var result = 0;
    var shift = 0;
    while (pos < end) {
      final byte = data[pos++];
      result |= (byte & 0x7F) << shift;
      if ((byte & 0x80) == 0) return (result, pos);
      shift += 7;
      if (shift > 63) return (result, pos);
    }
    return null;
  }

  _Field? next() {
    if (pos >= end) return null;
    final tag = varint();
    if (tag == null) return null;
    final number = tag.$1 >> 3;
    final wire = tag.$1 & 7;
    if (number == 0) return null;
    switch (wire) {
      case 0:
        final value = varint();
        return value == null ? null : _Field(number, wire, value.$1, null, pos);
      case 1:
        final value = _fixed(8);
        return value == null ? null : _Field(number, wire, value, null, pos);
      case 2:
        final length = varint();
        if (length == null) return null;
        final start = pos;
        if (start + length.$1 > end) return null;
        pos = start + length.$1;
        return _Field(
          number,
          wire,
          0,
          Uint8List.sublistView(data, start, start + length.$1),
          start,
        );
      case 5:
        final value = _fixed(4);
        return value == null ? null : _Field(number, wire, value, null, pos);
      default:
        return null;
    }
  }

  int? _fixed(int size) {
    if (pos + size > end) return null;
    var result = 0;
    for (var i = 0; i < size; i++) {
      result |= data[pos + i] << (8 * i);
    }
    pos += size;
    return result;
  }
}

List<_Field> _fields(Uint8List data, int start, int end) {
  final out = <_Field>[];
  final reader = _Reader(data, start, end);
  while (true) {
    final field = reader.next();
    if (field == null) break;
    out.add(field);
  }
  return out;
}

List<_Field> _subFields(Uint8List data, _Field field) => field.bytes == null
    ? const <_Field>[]
    : _fields(data, field.start, field.start + field.bytes!.length);

String? _text(Uint8List? bytes) {
  if (bytes == null) return null;
  try {
    return utf8.decode(bytes);
  } catch (_) {
    return null;
  }
}

// ----------------------------------------------------------------- model

class _Event {
  _Event({
    required this.sequence,
    required this.name,
    required this.category,
    required this.timestamp,
    required this.type,
    required this.track,
  });

  final int sequence;
  final String? name;
  final String? category;

  /// Boot-time nanoseconds.
  final int timestamp;

  /// 1 = slice begin, 2 = slice end, 3 = instant.
  final int type;
  final int track;
  int? duration;
  Map<String, String> arguments = const {};
}

class _Decoded {
  const _Decoded(this.events, this.named, this.firstTimestamp);

  final List<_Event> events;
  final List<_Event> named;
  final int firstTimestamp;
}

_Decoded _decode(Uint8List data) {
  // Trace { repeated TracePacket packet = 1 } — 0x0A <len> <payload>.
  final packets = <List<_Field>>[];
  var offset = 0;
  while (offset < data.length && data[offset] == 0x0A) {
    final reader = _Reader(data, offset + 1, data.length);
    final length = reader.varint();
    if (length == null) break;
    final start = length.$2;
    packets.add(_fields(data, start, start + length.$1));
    offset = start + length.$1;
  }

  final events = <_Event>[];
  final lastTimestamp = <int, int>{};
  for (final packet in packets) {
    var packetTimestamp = 0;
    var sequence = 0;
    for (final field in packet) {
      if (field.number == 10 && field.wire == 0) sequence = field.value;
      if (field.number == 8 && field.wire == 0) packetTimestamp = field.value;
    }
    for (final field in packet) {
      if (field.number != 11 || field.bytes == null) continue;
      int? deltaMicros;
      int? absoluteMicros;
      int? track;
      var type = 0;
      String? name;
      String? category;
      final arguments = <String, String>{};
      for (final sub in _subFields(data, field)) {
        switch (sub.number) {
          case 1:
            deltaMicros = sub.value;
          case 4:
            final argument = _argument(data, sub);
            if (argument != null) arguments[argument.$1] = argument.$2;
          case 9:
            type = sub.value;
          case 11:
            track = sub.value;
          case 16:
            absoluteMicros = sub.value;
          case 22:
            category = _text(sub.bytes);
          case 23:
            name = _text(sub.bytes);
        }
      }
      // TracePacket.timestamp is nanoseconds; timestamp_delta_us is micros.
      final int timestamp;
      if (absoluteMicros != null) {
        timestamp = absoluteMicros * 1000;
      } else if (deltaMicros != null) {
        timestamp =
            (lastTimestamp[sequence] ?? packetTimestamp) + deltaMicros * 1000;
      } else {
        timestamp = packetTimestamp;
      }
      final event = _Event(
        sequence: sequence,
        name: name,
        category: category,
        timestamp: timestamp,
        type: type,
        track: track ?? -1,
      );
      event.arguments = arguments;
      events.add(event);
      lastTimestamp[sequence] = timestamp;
    }
  }

  // Pair slice begin/end per track. End events are nameless, so walk *all*
  // events — filtering by name here silently drops every duration.
  final stacks = <String, List<_Event>>{};
  for (final event in events) {
    final key = '${event.sequence}/${event.track}';
    final stack = stacks.putIfAbsent(key, () => <_Event>[]);
    if (event.type == 1) {
      stack.add(event);
    } else if (event.type == 2 && stack.isNotEmpty) {
      final begin = stack.removeLast();
      begin.duration = event.timestamp - begin.timestamp;
    }
  }

  final named = events
      .where((event) => event.name != null && (event.duration ?? -1) >= 0)
      .toList();
  final firstTimestamp = events.isEmpty
      ? 0
      : events.map((e) => e.timestamp).reduce(math.min);
  return _Decoded(events, named, firstTimestamp);
}

(String, String)? _argument(Uint8List data, _Field field) {
  int? nameIid;
  String? inlineName;
  String? value;
  for (final sub in _subFields(data, field)) {
    switch (sub.number) {
      case 1:
        nameIid = sub.value;
      case 10:
        inlineName = _text(sub.bytes);
      case 2:
      case 3:
      case 4:
      case 8:
        value = sub.value.toString();
      case 6:
      case 9:
        value = _text(sub.bytes);
    }
  }
  final name = inlineName ?? (nameIid == null ? null : 'iid:$nameIid');
  if (name == null || value == null) return null;
  return (name, value);
}

// -------------------------------------------------------------- analysis

class _Stats {
  _Stats(this.name, List<int> durations)
    : count = durations.length,
      total = durations.fold(0, (a, b) => a + b),
      sorted = [...durations]..sort();

  final String name;
  final int count;
  final int total;
  final List<int> sorted;

  int get max => sorted.isEmpty ? 0 : sorted.last;

  int median() => sorted.isEmpty ? 0 : sorted[sorted.length ~/ 2];

  int percentile(double q) => sorted.isEmpty
      ? 0
      : sorted[math.min(sorted.length - 1, (sorted.length * q).floor())];

  int over(int budget) => sorted.where((d) => d > budget).length;

  Map<String, Object> toJson(int budget) => <String, Object>{
    'count': count,
    'p50_ms': _ms(median()),
    'p90_ms': _ms(percentile(0.9)),
    'p99_ms': _ms(percentile(0.99)),
    'max_ms': _ms(max),
    'total_ms': _ms(total),
    'over_budget': over(budget),
  };
}

double _ms(num nanoseconds) =>
    double.parse((nanoseconds / 1e6).toStringAsFixed(2));

const int _frameBudgetNs = 16670000; // 60 Hz

class _FramePair {
  const _FramePair(this.start, this.ui, this.raster);

  final int start;
  final int ui;
  final int raster;
}

class _Analysis {
  _Analysis(this._decoded, this.bucketMs)
    : ui = _Stats('UI frame', _durationsOf(_decoded, 'Frame')),
      raster = _Stats('Raster', _durationsOf(_decoded, 'GPURasterizer::Draw')),
      pipeline = _Stats('PipelineItem', _durationsOf(_decoded, 'PipelineItem'));

  final _Decoded _decoded;
  final int bucketMs;
  final _Stats ui;
  final _Stats raster;
  final _Stats pipeline;

  static List<int> _durationsOf(_Decoded decoded, String name) => decoded.named
      .where((event) => event.name == name)
      .map((event) => event.duration!)
      .toList();

  List<_Event> _series(String name) =>
      _decoded.named.where((event) => event.name == name).toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

  double get spanMs => _ms(
    _decoded.events.map((e) => e.timestamp).reduce(math.max) -
        _decoded.firstTimestamp,
  );

  int offsetMs(int timestamp) =>
      ((timestamp - _decoded.firstTimestamp) / 1e6).round();

  /// UI and raster frames paired by order (both fire once per frame).
  List<_FramePair> frames() {
    final uiFrames = _series('Frame');
    final rasterFrames = _series('GPURasterizer::Draw');
    final count = math.min(uiFrames.length, rasterFrames.length);
    return [
      for (var i = 0; i < count; i++)
        _FramePair(
          uiFrames[i].timestamp,
          uiFrames[i].duration!,
          rasterFrames[i].duration!,
        ),
    ];
  }

  double? framePeriodMs() {
    final starts = _series('Frame').map((e) => e.timestamp).toList();
    final deltas = <int>[];
    for (var i = 1; i < starts.length; i++) {
      final delta = starts[i] - starts[i - 1];
      if (delta > 0 && delta < 200 * 1000 * 1000) deltas.add(delta);
    }
    if (deltas.isEmpty) return null;
    deltas.sort();
    return _ms(deltas[deltas.length ~/ 2]);
  }

  /// Longest events fully contained in [frame] (±0.5 ms tolerance).
  List<_Event> hotspots(_FramePair frame, {int minimumNs = 3000000}) {
    final end = frame.start + frame.ui;
    final out = <_Event>[];
    for (final event in _decoded.named) {
      final duration = event.duration;
      if (duration == null || duration < minimumNs) continue;
      if (event.timestamp >= frame.start - 500000 &&
          event.timestamp + duration <= end + 500000) {
        out.add(event);
      }
    }
    out.sort((a, b) => b.duration!.compareTo(a.duration!));
    return out;
  }

  _Stats statsFor(String name) => _Stats(name, _durationsOf(_decoded, name));

  /// Aggregate totals per event name, descending by total time.
  List<_Stats> byTotal({int minimumCount = 1}) {
    final grouped = <String, List<int>>{};
    for (final event in _decoded.named) {
      grouped.putIfAbsent(event.name!, () => <int>[]).add(event.duration!);
    }
    final stats =
        grouped.entries
            .where((entry) => entry.value.length >= minimumCount)
            .map((entry) => _Stats(entry.key, entry.value))
            .toList()
          ..sort((a, b) => b.total.compareTo(a.total));
    return stats;
  }

  /// Notable blocking work: image decodes, GC pauses, platform channels.
  List<_Event> stalls() {
    const interesting = <String, int>{
      'ImageCache.putIfAbsent': 5000000,
      'listener': 5000000,
      'ConcurrentMark': 5000000,
      'Scavenge': 3000000,
      'PlatformChannel ScheduleResult': 8000000,
      'PlatformChannel ScheduleTask': 8000000,
    };
    final out =
        _decoded.named
            .where(
              (event) =>
                  (interesting[event.name] ?? 1 << 62) < (event.duration ?? 0),
            )
            .toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return out;
  }

  /// Per-bucket frame counts plus the raster-cost attribution counts.
  List<_Bucket> buckets() {
    final frameMap = <int, List<_FramePair>>{};
    final width = bucketMs * 1000000;
    for (final frame in frames()) {
      final index = (frame.start - _decoded.firstTimestamp) ~/ width;
      frameMap.putIfAbsent(index, () => <_FramePair>[]).add(frame);
    }
    final counters = <String, Map<int, int>>{
      for (final name in _countedNames) name: _countPerBucket(name, width),
    };
    return [
      for (final index in frameMap.keys.toList()..sort())
        _Bucket(
          startMs: index * bucketMs,
          frames: frameMap[index]!,
          counts: {
            for (final name in _countedNames) name: counters[name]![index] ?? 0,
          },
        ),
    ];
  }

  static const List<String> _countedNames = <String>[
    'Canvas::saveLayer',
    'RenderPassGLES::EncodeCommandsInReactor',
    'BlitPassGLES::EncodeCommandsInReactor',
    'CreateGlyphAtlas',
  ];

  Map<int, int> _countPerBucket(String name, int width) {
    final out = <int, int>{};
    for (final event in _decoded.named) {
      if (event.name != name) continue;
      final index = (event.timestamp - _decoded.firstTimestamp) ~/ width;
      out[index] = (out[index] ?? 0) + 1;
    }
    return out;
  }

  Map<String, Object> toJson({required _SnapshotMeta meta, required int top}) {
    final buckets = this.buckets();
    final saveLayer = <String, Object>{};
    for (final name in _countedNames) {
      saveLayer[name] = <String, Object>{
        'total': buckets.fold<int>(
          0,
          (sum, bucket) => sum + bucket.counts[name]!,
        ),
        'per_frame_startup': buckets.isEmpty
            ? 0.0
            : _perFrame(buckets.first, name),
      };
    }
    return <String, Object>{
      'meta': <String, Object>{
        'profile_build': meta.profileBuild,
        'operating_system': meta.operatingSystem,
        'flutter_version': meta.flutterVersion,
        'devtools_version': meta.devToolsVersion,
      },
      'span_ms': spanMs,
      'events': _decoded.events.length,
      'frame_period_ms': framePeriodMs() ?? 0,
      'ui': ui.toJson(_frameBudgetNs),
      'raster': raster.toJson(_frameBudgetNs),
      'pipeline': pipeline.toJson(_frameBudgetNs),
      'counters': saveLayer,
      'top_by_total': [
        for (final stats in byTotal().take(top))
          <String, Object>{
            'name': stats.name,
            'total_ms': _ms(stats.total),
            'count': stats.count,
            'max_ms': _ms(stats.max),
          },
      ],
    };
  }

  static double _perFrame(_Bucket bucket, String name) => bucket.frames.isEmpty
      ? 0
      : double.parse(
          (bucket.counts[name]! / bucket.frames.length).toStringAsFixed(2),
        );
}

class _Bucket {
  const _Bucket({
    required this.startMs,
    required this.frames,
    required this.counts,
  });

  final int startMs;
  final List<_FramePair> frames;
  final Map<String, int> counts;

  int get worstUi => frames.map((f) => f.ui).fold(0, (a, b) => math.max(a, b));

  int get worstRaster =>
      frames.map((f) => f.raster).fold(0, (a, b) => math.max(a, b));

  int get medianRaster {
    if (frames.isEmpty) return 0;
    final sorted = frames.map((f) => f.raster).toList()..sort();
    return sorted[sorted.length ~/ 2];
  }
}

// ---------------------------------------------------------------- report

void _printReport(
  _Analysis analysis, {
  required _SnapshotMeta meta,
  required _Options options,
}) {
  final build = meta.profileBuild ? 'profile' : 'release/other';
  stdout
    ..writeln('Snapshot : ${options.path}')
    ..writeln(
      'Build    : $build · ${meta.operatingSystem} · Flutter '
      '${meta.flutterVersion} · DevTools ${meta.devToolsVersion}',
    )
    ..writeln(
      'Decoded  : ${analysis._decoded.events.length} events, '
      '${analysis._decoded.named.length} measured slices, '
      '${analysis.spanMs} ms span',
    );
  if (!meta.profileBuild) {
    stdout.writeln(
      'WARNING  : this is not a profile build — debug builds inflate '
      'first-build cost several times over.',
    );
  }

  stdout.writeln('\n=== frame health (budget 16.67 ms @ 60 Hz) ===');
  final period = analysis.framePeriodMs();
  stdout.writeln(
    'frame period : ${period?.toStringAsFixed(2) ?? '?'} ms'
    '${period == null ? '' : ' (≈${(1000 / period).toStringAsFixed(1)} fps)'}',
  );
  for (final stats in [analysis.ui, analysis.raster, analysis.pipeline]) {
    stdout.writeln(
      '${stats.name.padRight(13)}: n=${stats.count.toString().padLeft(4)}  '
      'p50=${_ms(stats.median()).toStringAsFixed(2).padLeft(7)}ms  '
      'p90=${_ms(stats.percentile(0.9)).toStringAsFixed(2).padLeft(7)}ms  '
      'p99=${_ms(stats.percentile(0.99)).toStringAsFixed(2).padLeft(7)}ms  '
      'max=${_ms(stats.max).toStringAsFixed(1).padLeft(8)}ms  '
      'over budget=${stats.over(_frameBudgetNs)}',
    );
  }

  final frames = analysis.frames();
  final worst = [...frames]
    ..sort(
      (a, b) => math.max(b.ui, b.raster).compareTo(math.max(a.ui, a.raster)),
    );
  stdout.writeln('\n=== worst frames (UI / raster, paired) ===');
  for (final frame in worst.take(12)) {
    stdout.writeln(
      '  t=+${analysis.offsetMs(frame.start).toString().padLeft(6)}ms  '
      'ui=${_ms(frame.ui).toStringAsFixed(2).padLeft(7)}ms  '
      'raster=${_ms(frame.raster).toStringAsFixed(2).padLeft(7)}ms',
    );
    for (final event in analysis.hotspots(frame).take(4)) {
      stdout.writeln(
        '        ${_ms(event.duration!).toStringAsFixed(2).padLeft(7)}ms  '
        '${event.name}  [${event.category ?? '-'}]',
      );
    }
  }

  stdout.writeln('\n=== top ${options.top} by total time ===');
  for (final stats in analysis.byTotal().take(options.top)) {
    stdout.writeln(
      '  total=${_ms(stats.total).toStringAsFixed(1).padLeft(9)}ms  '
      'count=${stats.count.toString().padLeft(6)}  '
      'max=${_ms(stats.max).toStringAsFixed(2).padLeft(9)}ms  ${stats.name}',
    );
  }

  final stalls = analysis.stalls();
  if (stalls.isNotEmpty) {
    stdout.writeln('\n=== blocking work (image decode / GC / channels) ===');
    for (final event in stalls) {
      stdout.writeln(
        '  t=+${analysis.offsetMs(event.timestamp).toString().padLeft(6)}ms  '
        '${_ms(event.duration!).toStringAsFixed(1).padLeft(7)}ms  '
        '${event.name}',
      );
    }
  }

  stdout.writeln(
    '\n=== timeline (${options.bucketMs} ms buckets: raster p50 / worst, '
    'worst UI, saveLayer count) ===',
  );
  final buckets = analysis.buckets();
  stdout.writeln(
    '  bucket    frames  raster p50  raster max   ui max   saveLayer  '
    'passes  blits',
  );
  for (final bucket in buckets) {
    stdout.writeln(
      '  ${bucket.startMs.toString().padLeft(6)}ms  '
      '${bucket.frames.length.toString().padLeft(5)}  '
      '${_ms(bucket.medianRaster).toStringAsFixed(1).padLeft(9)}ms  '
      '${_ms(bucket.worstRaster).toStringAsFixed(1).padLeft(9)}ms  '
      '${_ms(bucket.worstUi).toStringAsFixed(1).padLeft(7)}ms  '
      '${bucket.counts['Canvas::saveLayer'].toString().padLeft(9)}  '
      '${bucket.counts['RenderPassGLES::EncodeCommandsInReactor'].toString().padLeft(6)}  '
      '${bucket.counts['BlitPassGLES::EncodeCommandsInReactor'].toString().padLeft(5)}',
    );
  }
  stdout.writeln(
    '\nHint: raster p50 near the 16.67 ms budget means the device is already '
    'saturated — look at the saveLayer column (ShaderMask / Opacity layers) '
    'and at the blocking-work list.',
  );
}
