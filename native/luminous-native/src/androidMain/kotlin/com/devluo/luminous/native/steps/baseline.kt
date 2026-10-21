package com.devluo.luminous.native.steps

import android.content.Context

internal data class StepBaseline(
    val total: Long,
    val recordedAtMs: Long,
)

internal class StepBaselineStore(context: Context) {
    private val prefs =
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    fun read(): StepBaseline? {
        if (!prefs.contains(KEY_TOTAL) || !prefs.contains(KEY_RECORDED_AT)) return null
        val total = prefs.getLong(KEY_TOTAL, -1L)
        val recordedAtMs = prefs.getLong(KEY_RECORDED_AT, 0L)
        if (total < 0L || recordedAtMs <= 0L) return null
        return StepBaseline(total, recordedAtMs)
    }

    fun write(total: Long, recordedAtMs: Long) {
        prefs.edit()
            .putLong(KEY_TOTAL, total)
            .putLong(KEY_RECORDED_AT, recordedAtMs)
            .commit()
    }

    private companion object {
        const val PREFS_NAME = "luminous_native_steps"
        const val KEY_TOTAL = "baseline_total"
        const val KEY_RECORDED_AT = "baseline_recorded_at"
    }
}
