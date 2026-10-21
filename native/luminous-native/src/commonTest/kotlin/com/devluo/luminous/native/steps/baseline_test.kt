package com.devluo.luminous.native.steps

import kotlin.test.Test
import kotlin.test.assertEquals

class BaselineTest {

    @Test
    fun returnsZeroWithoutBaseline() {
        assertEquals(0L, stepsAfterBaseline(120, null))
    }

    @Test
    fun returnsDeltaWhenCounterGrows() {
        assertEquals(40L, stepsAfterBaseline(120, 80))
    }

    @Test
    fun returnsCurrentTotalAfterRestart() {
        assertEquals(40L, stepsAfterBaseline(40, 120))
    }

    @Test
    fun ignoresInvalidCurrentTotal() {
        assertEquals(0L, stepsAfterBaseline(-1, 120))
    }
}
