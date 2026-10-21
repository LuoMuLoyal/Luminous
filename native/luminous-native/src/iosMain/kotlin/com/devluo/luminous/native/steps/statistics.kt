package com.devluo.luminous.native.steps

import com.devluo.luminous.native.core.Failure
import com.devluo.luminous.native.core.FailureCode
import com.devluo.luminous.native.core.NativeResult
import kotlinx.cinterop.ExperimentalForeignApi
import kotlinx.coroutines.suspendCancellableCoroutine
import platform.Foundation.NSDate
import platform.Foundation.NSDateComponents
import platform.Foundation.NSCalendar
import platform.Foundation.dateWithTimeIntervalSince1970
import platform.Foundation.timeIntervalSince1970
import platform.HealthKit.HKHealthStore
import platform.HealthKit.HKObjectType
import platform.HealthKit.HKQuantityTypeIdentifierStepCount
import platform.HealthKit.HKQuery
import platform.HealthKit.HKQueryOptionNone
import platform.HealthKit.HKSampleType
import platform.HealthKit.HKStatistics
import platform.HealthKit.HKStatisticsCollectionQuery
import platform.HealthKit.HKStatisticsOptionCumulativeSum
import platform.HealthKit.HKUnit
import platform.HealthKit.countUnit
import platform.HealthKit.predicateForSamplesWithStartDate
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException

@OptIn(ExperimentalForeignApi::class)
internal object HealthKitQuery {
    private val store = HKHealthStore()

    fun isAvailable(): Boolean = HKHealthStore.isHealthDataAvailable()

    suspend fun requestAuthorization(): NativeResult<Boolean> =
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
            store.requestAuthorizationToShareTypes(shareTypes, readTypes) { success, error ->
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

                val samples = mutableListOf<StepSample>()
                val statisticsList =
                    collection?.statistics().orEmpty().filterIsInstance<HKStatistics>()
                statisticsList.forEach { statistics ->
                    val quantity = statistics.sumQuantity() ?: return@forEach
                    val count = quantity.doubleValueForUnit(HKUnit.countUnit()).toLong()
                    if (count <= 0L) return@forEach

                    val statisticsStart = statistics.startDate
                    val statisticsEnd = statistics.endDate
                    samples += StepSample(
                        count = count,
                        startMs = statisticsStart.toEpochMs(),
                        endMs = statisticsEnd.toEpochMs(),
                        source = STEP_SOURCE_APPLE_HEALTH,
                    )
                }
                continuation.resume(samples)
            }

            try {
                store.executeQuery(query)
            } catch (error: Throwable) {
                continuation.resumeWithException(error)
            }
            continuation.invokeOnCancellation { store.stopQuery(query) }
        }
}

@OptIn(ExperimentalForeignApi::class)
private fun Long.toNSDate(): NSDate =
    NSDate.dateWithTimeIntervalSince1970(this / 1000.0)

@OptIn(ExperimentalForeignApi::class)
private fun NSDate.toEpochMs(): Long =
    (timeIntervalSince1970 * 1000.0).toLong()

@OptIn(ExperimentalForeignApi::class)
internal fun startOfLocalDay(epochMs: Long): Long {
    val date = epochMs.toNSDate()
    val start = NSCalendar.currentCalendar.startOfDayForDate(date)
    return start.toEpochMs()
}
