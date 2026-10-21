package com.devluo.luminous.native.steps

const val STEP_SOURCE_ANDROID_SENSOR = "android_sensor"
const val STEP_SOURCE_APPLE_HEALTH = "apple_health"

data class StepSample(
    val count: Long,
    val startMs: Long,
    val endMs: Long,
    val source: String,
)
