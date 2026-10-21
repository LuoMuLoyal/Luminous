package com.devluo.luminous.native.steps

fun stepsAfterBaseline(currentTotal: Long, previousTotal: Long?): Long {
    if (currentTotal <= 0L || previousTotal == null || previousTotal < 0L) return 0L
    return if (currentTotal >= previousTotal) {
        currentTotal - previousTotal
    } else {
        currentTotal
    }
}
