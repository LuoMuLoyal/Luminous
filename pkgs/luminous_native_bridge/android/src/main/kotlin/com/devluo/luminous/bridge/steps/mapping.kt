package com.devluo.luminous.bridge.steps

import com.devluo.luminous.native.core.Capability
import com.devluo.luminous.native.core.Failure
import com.devluo.luminous.native.steps.StepRequest
import com.devluo.luminous.native.steps.StepSample

internal fun StepReadRequest.toDomain(): StepRequest =
    StepRequest(startMs = startMs, endMs = endMs)

internal fun StepSample.toDto(): NativeStep =
    NativeStep(
        count = count,
        startMs = startMs,
        endMs = endMs,
        source = source,
    )

internal fun Capability.toDto(): StepCapability = when (this) {
    is Capability.Available -> StepCapability(available = true)
    is Capability.Unavailable -> StepCapability(
        available = false,
        reason = reason.name,
        message = message,
    )
}

internal fun Failure.toFlutterError(): FlutterError =
    FlutterError(code.name, message)
