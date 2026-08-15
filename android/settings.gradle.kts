pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        // maven.google.com 在本机网络被挡（2026-08-15 实测超时）；设 LUMOS_GRADLE_MIRROR=aliyun
        // 时改用阿里云镜像兜底（默认关闭，不影响 CI）。
        if (System.getenv("LUMOS_GRADLE_MIRROR") == "aliyun") {
            maven(url = uri("https://maven.aliyun.com/repository/google"))
            maven(url = uri("https://maven.aliyun.com/repository/public"))
        }
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "9.1.0" apply false
    // KGP 仅钉版本提供 classpath（Flutter 插件要求 Kotlin >= 2.2.20，3.47 验证矩阵为 2.4.0）；
    // 各插件自行 apply，app 模块不应用。
    id("org.jetbrains.kotlin.android") version "2.4.0" apply false
}

include(":app")
