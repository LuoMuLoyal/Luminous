package com.devluo.luminous.bridge

import com.devluo.luminous.bridge.steps.StepHandler
import com.devluo.luminous.bridge.steps.StepHostApi
import com.devluo.luminous.native.core.LuminousNativeApi
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class LuminousNativeBridgePlugin :
    FlutterPlugin,
    MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler(this)
        StepHostApi.setUp(
            binding.binaryMessenger,
            StepHandler(binding.applicationContext),
        )
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "ping" -> result.success(LuminousNativeApi.ping())
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        StepHostApi.setUp(binding.binaryMessenger, null)
    }

    private companion object {
        const val CHANNEL = "luminous_native_bridge"
    }
}
