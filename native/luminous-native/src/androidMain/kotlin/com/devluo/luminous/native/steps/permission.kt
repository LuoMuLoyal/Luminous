package com.devluo.luminous.native.steps

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build

internal fun Context.hasActivityRecognitionPermission(): Boolean {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) return true
    return checkSelfPermission(Manifest.permission.ACTIVITY_RECOGNITION) ==
        PackageManager.PERMISSION_GRANTED
}
