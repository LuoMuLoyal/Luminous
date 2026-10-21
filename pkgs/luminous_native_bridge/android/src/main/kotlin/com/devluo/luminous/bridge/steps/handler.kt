package com.devluo.luminous.bridge.steps

import android.content.Context
import com.devluo.luminous.native.core.NativeResult
import com.devluo.luminous.native.steps.AndroidStepSource

internal class StepHandler(context: Context) : StepHostApi {
    private val source = AndroidStepSource(context)

    override suspend fun capability(): StepCapability =
        source.capability().toDto()

    override suspend fun read(request: StepReadRequest): List<NativeStep> =
        when (val result = source.read(request.toDomain())) {
            is NativeResult.Success -> result.value.map { it.toDto() }
            is NativeResult.Error -> throw result.failure.toFlutterError()
        }
}
