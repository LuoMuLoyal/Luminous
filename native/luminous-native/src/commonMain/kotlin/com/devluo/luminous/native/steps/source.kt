package com.devluo.luminous.native.steps

import com.devluo.luminous.native.core.Capability
import com.devluo.luminous.native.core.NativeResult

interface StepSource {
    fun capability(): Capability

    suspend fun read(request: StepRequest): NativeResult<List<StepSample>>
}
