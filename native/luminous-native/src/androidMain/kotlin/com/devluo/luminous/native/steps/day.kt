package com.devluo.luminous.native.steps

import java.time.Instant
import java.time.ZoneId

internal fun startOfLocalDay(epochMs: Long): Long {
    val zone = ZoneId.systemDefault()
    return Instant.ofEpochMilli(epochMs)
        .atZone(zone)
        .toLocalDate()
        .atStartOfDay(zone)
        .toInstant()
        .toEpochMilli()
}
