package com.devluo.luminous.native.steps

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class NormalizationTest {

    @Test
    fun splitsSamplesAtLocalDayBoundaries() {
        val request = StepRequest(JAN_1, JAN_3)
        val sample = StepSample(
            count = 48,
            startMs = JAN_1_12_00,
            endMs = JAN_2_12_00,
            source = STEP_SOURCE_APPLE_HEALTH,
        )

        val result = normalizeSteps(listOf(sample), request, ::startOfUtcDay)

        assertEquals(2, result.size)
        assertEquals(StepSample(24, JAN_1_12_00, JAN_2, STEP_SOURCE_APPLE_HEALTH), result[0])
        assertEquals(StepSample(24, JAN_2, JAN_2_12_00, STEP_SOURCE_APPLE_HEALTH), result[1])
    }

    @Test
    fun mergesSamplesWithinTheSameDayAndSource() {
        val request = StepRequest(JAN_1, JAN_2)
        val morning = StepSample(10, JAN_1_12_00, JAN_1_13_00, STEP_SOURCE_ANDROID_SENSOR)
        val afternoon = StepSample(15, JAN_1_13_00, JAN_1_14_00, STEP_SOURCE_ANDROID_SENSOR)

        val result = normalizeSteps(listOf(afternoon, morning), request, ::startOfUtcDay)

        assertEquals(1, result.size)
        assertEquals(25L, result.single().count)
        assertEquals(JAN_1_12_00, result.single().startMs)
        assertEquals(JAN_1_14_00, result.single().endMs)
    }

    @Test
    fun clipsSampleCountToRequestBounds() {
        val request = StepRequest(JAN_1_06_00, JAN_2)
        val sample = StepSample(100, JAN_1, JAN_2, STEP_SOURCE_APPLE_HEALTH)

        val result = normalizeSteps(listOf(sample), request, ::startOfUtcDay)

        assertEquals(1, result.size)
        assertEquals(75L, result.single().count)
        assertEquals(JAN_1_06_00, result.single().startMs)
        assertEquals(JAN_2, result.single().endMs)
    }

    @Test
    fun dropsNonPositiveAndOutOfRangeSamples() {
        val request = StepRequest(JAN_1, JAN_2)
        val samples = listOf(
            StepSample(-5, JAN_1_12_00, JAN_1_13_00, STEP_SOURCE_APPLE_HEALTH),
            StepSample(0, JAN_1_12_00, JAN_1_13_00, STEP_SOURCE_APPLE_HEALTH),
            StepSample(10, JAN_3, JAN_3 + DAY_MS, STEP_SOURCE_APPLE_HEALTH),
        )

        assertTrue(normalizeSteps(samples, request, ::startOfUtcDay).isEmpty())
    }

    @Test
    fun handlesTwentyFiveHourDayAtDayStart() {
        val dayStart = 24L * 60L * 60L * 1000L
        val nextDayStart = 49L * 60L * 60L * 1000L
        val sample = StepSample(49, 0L, nextDayStart, STEP_SOURCE_APPLE_HEALTH)
        val request = StepRequest(0L, nextDayStart)

        val result = normalizeSteps(listOf(sample), request) { epochMs ->
            when {
                epochMs < dayStart -> 0L
                epochMs < nextDayStart -> dayStart
                else -> nextDayStart
            }
        }

        assertEquals(2, result.size)
        assertEquals(24L, result[0].count)
        assertEquals(25L, result[1].count)
    }

    @Test
    fun usesCurrentTotalAfterRestart() {
        assertEquals(0L, stepsAfterBaseline(120, null))
        assertEquals(40L, stepsAfterBaseline(120, 80))
        assertEquals(40L, stepsAfterBaseline(40, 120))
        assertEquals(0L, stepsAfterBaseline(-1, 120))
    }

    private fun startOfUtcDay(epochMs: Long): Long {
        val remainder = epochMs % DAY_MS
        val normalized = if (remainder < 0L) remainder + DAY_MS else remainder
        return epochMs - normalized
    }

    private companion object {
        const val DAY_MS = 24L * 60L * 60L * 1000L
        const val JAN_1 = 1_767_225_600_000L
        const val JAN_1_06_00 = 1_767_247_200_000L
        const val JAN_1_12_00 = 1_767_268_800_000L
        const val JAN_1_13_00 = 1_767_272_400_000L
        const val JAN_1_14_00 = 1_767_276_000_000L
        const val JAN_2 = 1_767_312_000_000L
        const val JAN_2_12_00 = 1_767_355_200_000L
        const val JAN_3 = 1_767_398_400_000L
    }
}
