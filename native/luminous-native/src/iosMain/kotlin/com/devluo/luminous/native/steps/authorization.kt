package com.devluo.luminous.native.steps

import com.devluo.luminous.native.core.Failure
import com.devluo.luminous.native.core.FailureCode
import com.devluo.luminous.native.core.NativeResult
import kotlinx.cinterop.ExperimentalForeignApi
import kotlinx.coroutines.suspendCancellableCoroutine
import platform.HealthKit.HKObjectType
import platform.HealthKit.HKQuantityTypeIdentifierStepCount
import platform.HealthKit.HKSampleType
import kotlin.coroutines.resume

internal object HealthKitAuthorization {
    suspend fun request(): NativeResult<Boolean> =
        suspendCancellableCoroutine { continuation ->
            val stepType = HKObjectType.quantityTypeForIdentifier(
                HKQuantityTypeIdentifierStepCount,
            )
            if (stepType == null) {
                continuation.resume(
                    NativeResult.Error(
                        Failure(FailureCode.notSupported, "Step count type is unavailable"),
                    ),
                )
                return@suspendCancellableCoroutine
            }

            val shareTypes: Set<HKSampleType> = emptySet()
            val readTypes: Set<HKObjectType> = setOf(stepType)
            healthStore.requestAuthorizationToShareTypes(shareTypes, readTypes) { success, error ->
                when {
                    error != null -> continuation.resume(
                        NativeResult.Error(
                            Failure(FailureCode.queryFailed, error.localizedDescription),
                        ),
                    )
                    !success -> continuation.resume(
                        NativeResult.Error(
                            Failure(
                                FailureCode.permissionDenied,
                                "HealthKit authorization was not completed",
                            ),
                        ),
                    )
                    else -> continuation.resume(NativeResult.Success(true))
                }
            }
        }
}
