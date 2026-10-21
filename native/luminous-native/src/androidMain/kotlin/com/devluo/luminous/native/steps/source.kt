package com.devluo.luminous.native.steps

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.os.SystemClock
import com.devluo.luminous.native.core.Capability
import com.devluo.luminous.native.core.Failure
import com.devluo.luminous.native.core.FailureCode
import com.devluo.luminous.native.core.NativeResult
import com.devluo.luminous.native.core.UnavailableReason
import com.devluo.luminous.native.core.toFailureCode
import java.time.Instant
import java.time.ZoneId
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class AndroidStepSource(context: Context) : StepSource {
    private val appContext = context.applicationContext
    private val sensor = StepSensor(appContext)
    private val baseline = StepBaselineStore(appContext)

    override fun capability(): Capability {
        if (!sensor.hasSensor()) {
            return Capability.unavailable(UnavailableReason.noStepSensor)
        }
        if (!hasPermission()) {
            return Capability.unavailable(UnavailableReason.permissionDenied)
        }
        return Capability.Available
    }

    override suspend fun read(request: StepRequest): NativeResult<List<StepSample>> =
        withContext(Dispatchers.Default) {
            if (request.endMs <= request.startMs) {
                return@withContext NativeResult.Error(
                    Failure(FailureCode.invalidRequest, "endMs must be greater than startMs"),
                )
            }

            val currentCapability = capability()
            if (currentCapability is Capability.Unavailable) {
                return@withContext NativeResult.Error(
                    Failure(
                        currentCapability.reason.toFailureCode(),
                        currentCapability.message,
                    ),
                )
            }

            val currentTotal = sensor.readTotal()
                ?: return@withContext NativeResult.Success(emptyList())

            val now = System.currentTimeMillis()
            val previous = baseline.read()
            baseline.write(currentTotal, now)

            val count = stepsAfterBaseline(currentTotal, previous?.total)
            if (count <= 0L) {
                return@withContext NativeResult.Success(emptyList())
            }

            val startMs = when {
                previous == null -> now
                currentTotal < previous.total ->
                    (now - SystemClock.elapsedRealtime()).coerceAtLeast(0L)
                else -> previous.recordedAtMs.coerceAtMost(now)
            }

            val sample = StepSample(
                count = count,
                startMs = startMs,
                endMs = now,
                source = STEP_SOURCE_ANDROID_SENSOR,
            )
            NativeResult.Success(
                normalizeSteps(listOf(sample), request, ::startOfLocalDay),
            )
        }

    private fun hasPermission(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) return true
        return appContext.checkSelfPermission(Manifest.permission.ACTIVITY_RECOGNITION) ==
            PackageManager.PERMISSION_GRANTED
    }

    private fun startOfLocalDay(epochMs: Long): Long =
        Instant.ofEpochMilli(epochMs)
            .atZone(ZoneId.systemDefault())
            .toLocalDate()
            .atStartOfDay(ZoneId.systemDefault())
            .toInstant()
            .toEpochMilli()
}
