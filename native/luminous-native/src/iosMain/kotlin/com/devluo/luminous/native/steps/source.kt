package com.devluo.luminous.native.steps

import com.devluo.luminous.native.core.Capability
import com.devluo.luminous.native.core.Failure
import com.devluo.luminous.native.core.FailureCode
import com.devluo.luminous.native.core.NativeResult
import com.devluo.luminous.native.core.UnavailableReason
import kotlin.experimental.ExperimentalObjCName
import kotlin.native.ObjCName

@OptIn(ExperimentalObjCName::class)
@ObjCName(name = "LuminousStepStatus", swiftName = "LuminousStepStatus")
class StepStatus(
    val available: Boolean,
    val reason: String?,
    val message: String?,
)

@OptIn(ExperimentalObjCName::class)
@ObjCName(name = "LuminousStepReadOutcome", swiftName = "LuminousStepReadOutcome")
class StepReadOutcome(
    val samples: List<StepSample>,
    val errorCode: String?,
    val errorMessage: String?,
)

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

    fun status(): StepStatus = when (val capability = capability()) {
        Capability.Available -> StepStatus(true, null, null)
        is Capability.Unavailable -> StepStatus(
            available = false,
            reason = capability.reason.name,
            message = capability.message,
        )
    }

    suspend fun readOutcome(request: StepRequest): StepReadOutcome =
        when (val result = read(request)) {
            is NativeResult.Success -> StepReadOutcome(result.value, null, null)
            is NativeResult.Error -> StepReadOutcome(
                samples = emptyList(),
                errorCode = result.failure.code.name,
                errorMessage = result.failure.message,
            )
        }

    suspend fun requestAuthorization(): NativeResult<Boolean> =
        HealthKitAuthorization.request()
}
