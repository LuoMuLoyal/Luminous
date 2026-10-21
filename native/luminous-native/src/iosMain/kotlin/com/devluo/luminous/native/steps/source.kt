package com.devluo.luminous.native.steps

import com.devluo.luminous.native.core.Capability
import com.devluo.luminous.native.core.Failure
import com.devluo.luminous.native.core.FailureCode
import com.devluo.luminous.native.core.NativeResult
import com.devluo.luminous.native.core.UnavailableReason
import kotlin.experimental.ExperimentalObjCName
import kotlin.native.ObjCName

@OptIn(ExperimentalObjCName::class)
@ObjCName(name = "LuminousStepSource", swiftName = "LuminousStepSource")
class IosStepSource : StepSource {
    override fun capability(): Capability {
        if (!isHealthDataAvailable()) {
            return Capability.unavailable(UnavailableReason.healthDataUnavailable)
        }
        return Capability.Available
    }

    override suspend fun read(request: StepRequest): NativeResult<List<StepSample>> {
        if (request.endMs <= request.startMs) {
            return NativeResult.Error(
                Failure(FailureCode.invalidRequest, "endMs must be greater than startMs"),
            )
        }
        if (!isHealthDataAvailable()) {
            return NativeResult.Error(
                Failure(FailureCode.unavailable, "Health data is not available on this device"),
            )
        }

        return try {
            val samples = HealthKitStatistics.readSteps(request)
            NativeResult.Success(
                normalizeSteps(samples, request, ::startOfLocalDay),
            )
        } catch (error: Throwable) {
            NativeResult.Error(
                Failure(FailureCode.queryFailed, error.message),
            )
        }
    }

    suspend fun requestAuthorization(): NativeResult<Boolean> =
        HealthKitAuthorization.request()
}
