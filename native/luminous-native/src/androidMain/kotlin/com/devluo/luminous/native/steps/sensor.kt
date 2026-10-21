package com.devluo.luminous.native.steps

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit

internal class StepSensor(context: Context) {
    private val manager =
        context.getSystemService(Context.SENSOR_SERVICE) as? SensorManager

    fun hasSensor(): Boolean =
        manager?.getDefaultSensor(Sensor.TYPE_STEP_COUNTER) != null

    fun readTotal(timeoutMs: Long = 2_000L): Long? {
        val sensorManager = manager ?: return null
        val sensor = sensorManager.getDefaultSensor(Sensor.TYPE_STEP_COUNTER) ?: return null
        val latch = CountDownLatch(1)
        var total: Long? = null

        val listener = object : SensorEventListener {
            override fun onSensorChanged(event: SensorEvent) {
                if (event.sensor.type == Sensor.TYPE_STEP_COUNTER) {
                    total = event.values.firstOrNull()?.toLong()
                    latch.countDown()
                }
            }

            override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) = Unit
        }

        val registered = sensorManager.registerListener(
            listener,
            sensor,
            SensorManager.SENSOR_DELAY_UI,
        )
        if (!registered) return null

        return try {
            latch.await(timeoutMs, TimeUnit.MILLISECONDS)
            total
        } catch (_: InterruptedException) {
            Thread.currentThread().interrupt()
            null
        } finally {
            sensorManager.unregisterListener(listener)
        }
    }
}
