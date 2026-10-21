package com.devluo.luminous.native.steps

import kotlinx.cinterop.ExperimentalForeignApi
import kotlinx.coroutines.suspendCancellableCoroutine
import platform.Foundation.NSDateComponents
import platform.Foundation.NSCalendar
import platform.HealthKit.HKObjectType
import platform.HealthKit.HKQuantityTypeIdentifierStepCount
import platform.HealthKit.HKQuery
import platform.HealthKit.HKQueryOptionNone
import platform.HealthKit.HKStatistics
import platform.HealthKit.HKStatisticsCollectionQuery
import platform.HealthKit.HKStatisticsOptionCumulativeSum
import platform.HealthKit.predicateForSamplesWithStartDate
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException

internal object HealthKitStatistics {
    suspend fun readSteps(request: StepRequest): List<StepSample> =
        suspendCancellableCoroutine { continuation ->
            val stepType = HKObjectType.quantityTypeForIdentifier(
                HKQuantityTypeIdentifierStepCount,
            )
            if (stepType == null) {
                continuation.resumeWithException(
                    IllegalStateException("Step count type is unavailable"),
                )
                return@suspendCancellableCoroutine
            }

            val startDate = request.startMs.toNSDate()
            val endDate = request.endMs.toNSDate()
            val calendar = NSCalendar.currentCalendar
            val anchorDate = calendar.startOfDayForDate(startDate)
            val interval = NSDateComponents()
            interval.day = 1L

            val query = HKStatisticsCollectionQuery(
                stepType,
                HKQuery.predicateForSamplesWithStartDate(
                    startDate,
                    endDate,
                    HKQueryOptionNone,
                ),
                HKStatisticsOptionCumulativeSum,
                anchorDate,
                interval,
            )

            query.initialResultsHandler = handler@{ _, collection, error ->
                if (error != null) {
                    continuation.resumeWithException(
                        IllegalStateException(error.localizedDescription),
                    )
                    return@handler
                }

                val samples = collection
                    ?.statistics()
                    .orEmpty()
                    .filterIsInstance<HKStatistics>()
                    .mapNotNull { it.toStepSample() }
                continuation.resume(samples)
            }

            try {
                healthStore.executeQuery(query)
            } catch (error: Throwable) {
                continuation.resumeWithException(error)
            }
            continuation.invokeOnCancellation { healthStore.stopQuery(query) }
        }
}
