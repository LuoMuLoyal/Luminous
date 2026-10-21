package com.devluo.luminous.native.steps

private const val DAY_MS = 24L * 60L * 60L * 1000L

fun normalizeSteps(
    samples: List<StepSample>,
    request: StepRequest,
    startOfDay: (Long) -> Long,
): List<StepSample> {
    if (request.endMs <= request.startMs) return emptyList()
    val clipped = samples.mapNotNull { clipToRequest(it, request) }
    val split = clipped.flatMap { splitAtDayBoundaries(it, startOfDay) }
    return mergeByDayAndSource(split, startOfDay)
}

private fun clipToRequest(sample: StepSample, request: StepRequest): StepSample? {
    if (sample.count <= 0L || sample.endMs <= sample.startMs) return null

    val start = maxOf(sample.startMs, request.startMs)
    val end = minOf(sample.endMs, request.endMs)
    if (end <= start) return null

    val total = sample.endMs - sample.startMs
    val kept = end - start
    if (kept == total) return sample.copy(startMs = start, endMs = end)

    val count = (sample.count * kept + total / 2L) / total
    if (count <= 0L) return null
    return sample.copy(count = count, startMs = start, endMs = end)
}

private fun splitAtDayBoundaries(
    sample: StepSample,
    startOfDay: (Long) -> Long,
): List<StepSample> {
    val duration = sample.endMs - sample.startMs
    if (duration <= 0L) return emptyList()

    val result = mutableListOf<StepSample>()
    var cursor = sample.startMs
    var remaining = sample.count

    while (cursor < sample.endMs) {
        val firstProbe = startOfDay(cursor + DAY_MS)
        val nextDay = if (firstProbe > cursor) {
            firstProbe
        } else {
            startOfDay(cursor + 2L * DAY_MS)
        }
        val next = if (nextDay > cursor) nextDay else cursor + DAY_MS
        val end = minOf(next, sample.endMs)
        val part = if (end == sample.endMs) {
            remaining
        } else {
            sample.count * (end - cursor) / duration
        }

        if (part > 0L) {
            result += StepSample(part, cursor, end, sample.source)
            remaining -= part
        }
        cursor = end
    }

    if (remaining > 0L && result.isNotEmpty()) {
        val last = result.removeAt(result.lastIndex)
        result += last.copy(count = last.count + remaining)
    }
    return result
}

private data class MergedSample(
    var count: Long,
    var startMs: Long,
    var endMs: Long,
)

private fun mergeByDayAndSource(
    samples: List<StepSample>,
    startOfDay: (Long) -> Long,
): List<StepSample> {
    val merged = LinkedHashMap<Pair<String, Long>, MergedSample>()

    for (sample in samples) {
        val key = sample.source to startOfDay(sample.startMs)
        val existing = merged[key]
        if (existing == null) {
            merged[key] = MergedSample(sample.count, sample.startMs, sample.endMs)
        } else {
            existing.count += sample.count
            existing.startMs = minOf(existing.startMs, sample.startMs)
            existing.endMs = maxOf(existing.endMs, sample.endMs)
        }
    }

    return merged.map { (key, value) ->
        StepSample(value.count, value.startMs, value.endMs, key.first)
    }.sortedBy { it.startMs }
}
