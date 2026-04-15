package com.dev.luminous

import android.content.ContentValues
import android.os.Build
import android.os.Bundle
import android.provider.MediaStore
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.renderer.FlutterUiDisplayListener
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
  private val channelName = "com.dev.luminous/gallery"
  private var keepNativeSplash = true

  override fun onCreate(savedInstanceState: Bundle?) {
    val splashScreen = installSplashScreen()
    splashScreen.setKeepOnScreenCondition { keepNativeSplash }
    super.onCreate(savedInstanceState)

    val renderer = flutterEngine?.renderer
    if (renderer == null) {
      keepNativeSplash = false
      return
    }

    val uiListener =
      object : FlutterUiDisplayListener {
        override fun onFlutterUiDisplayed() {
          keepNativeSplash = false
          renderer.removeIsDisplayingFlutterUiListener(this)
        }

        override fun onFlutterUiNoLongerDisplayed() = Unit
      }
    renderer.addIsDisplayingFlutterUiListener(uiListener)

    // 兜底：即便 Flutter 首帧异常延迟，也避免原生 splash 长时间卡住。
    window.decorView.postDelayed({ keepNativeSplash = false }, 3500)
  }

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
      .setMethodCallHandler { call, result ->
        when (call.method) {
          "saveImage" -> {
            val bytes = call.argument<ByteArray>("bytes")
            val fileName = call.argument<String>("fileName")
              ?: "luminous_${System.currentTimeMillis()}.jpg"
            val mimeType = call.argument<String>("mimeType") ?: "image/jpeg"

            if (bytes == null) {
              result.error("INVALID_ARGUMENT", "bytes is null", null)
              return@setMethodCallHandler
            }

            try {
              val uri = saveImageToGallery(bytes, fileName, mimeType)
              result.success(uri)
            } catch (e: Exception) {
              result.error("SAVE_FAILED", e.message, null)
            }
          }
          else -> result.notImplemented()
        }
      }
  }

  private fun saveImageToGallery(bytes: ByteArray, fileName: String, mimeType: String): String {
    val resolver = applicationContext.contentResolver

    val values = ContentValues().apply {
      put(MediaStore.Images.Media.DISPLAY_NAME, fileName)
      put(MediaStore.Images.Media.MIME_TYPE, mimeType)
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
        put(MediaStore.Images.Media.RELATIVE_PATH, "Pictures/Luminous")
        put(MediaStore.Images.Media.IS_PENDING, 1)
      }
    }

    val uri = resolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values)
      ?: throw RuntimeException("Failed to create MediaStore record")

    resolver.openOutputStream(uri).use { out ->
      if (out == null) {
        throw RuntimeException("Failed to open output stream")
      }
      out.write(bytes)
      out.flush()
    }

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
      val pendingValues = ContentValues().apply {
        put(MediaStore.Images.Media.IS_PENDING, 0)
      }
      resolver.update(uri, pendingValues, null, null)
    }

    return uri.toString()
  }
}
