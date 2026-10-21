package com.devluo.luminous.native.steps

import kotlinx.cinterop.ExperimentalForeignApi
import platform.HealthKit.HKHealthStore

@OptIn(ExperimentalForeignApi::class)
internal val healthStore: HKHealthStore = HKHealthStore()
