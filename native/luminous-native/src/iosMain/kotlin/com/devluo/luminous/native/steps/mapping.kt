package com.devluo.luminous.native.steps

import kotlinx.cinterop.ExperimentalForeignApi
import platform.HealthKit.HKStatistics
import platform.HealthKit.HKUnit
import platform.HealthKit.countUnit

@OptIn(ExperimentalForeignApi::class)
internal fun HKStatistics.toStepSample(): StepSample? {
    val quantity = sumQuantity() ?: return null
    val count = quantity.doubleValueForUnit(HKUnit.countUnit()).toLong()
    if (count <= 0L) return null

    return StepSample(
        count = count,
        startMs = startDate.toEpochMs(),
        endMs = endDate.toEpochMs(),
        source = STEP_SOURCE_APPLE_HEALTH,
    )
}
