package com.devluo.luminous.native.steps

import kotlinx.cinterop.ExperimentalForeignApi
import platform.Foundation.NSDate
import platform.Foundation.NSCalendar
import platform.Foundation.dateWithTimeIntervalSince1970
import platform.Foundation.timeIntervalSince1970

@OptIn(ExperimentalForeignApi::class)
internal fun Long.toNSDate(): NSDate =
    NSDate.dateWithTimeIntervalSince1970(this / 1000.0)

@OptIn(ExperimentalForeignApi::class)
internal fun NSDate.toEpochMs(): Long =
    (timeIntervalSince1970 * 1000.0).toLong()

@OptIn(ExperimentalForeignApi::class)
internal fun startOfLocalDay(epochMs: Long): Long {
    val date = epochMs.toNSDate()
    val start = NSCalendar.currentCalendar.startOfDayForDate(date)
    return start.toEpochMs()
}
