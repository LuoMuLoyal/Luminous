package com.devluo.luminous.native.core

import kotlin.test.Test
import kotlin.test.assertEquals

class PingTest {

    @Test
    fun pingReturnsPong() {
        assertEquals("pong", LuminousNativeApi.ping())
    }
}
