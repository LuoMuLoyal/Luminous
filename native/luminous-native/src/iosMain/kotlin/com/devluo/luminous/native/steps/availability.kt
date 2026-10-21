package com.devluo.luminous.native.steps

import platform.HealthKit.HKHealthStore

internal fun isHealthDataAvailable(): Boolean =
    HKHealthStore.isHealthDataAvailable()
