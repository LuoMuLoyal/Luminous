import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { stream ->
        keystoreProperties.load(stream)
    }
}

fun keystoreValue(key: String): String = (keystoreProperties.getProperty(key) ?: "").trim()

val hasReleaseSigning =
    keystoreValue("storeFile").isNotEmpty() &&
    keystoreValue("storePassword").isNotEmpty() &&
    keystoreValue("keyAlias").isNotEmpty() &&
    keystoreValue("keyPassword").isNotEmpty()

val luminousApplicationId = "com.dev.luminous"
val jpushAppKey = providers.gradleProperty("JPUSH_APP_KEY")
    .orElse(providers.environmentVariable("JPUSH_APP_KEY"))
    .orElse("")

android {
    namespace = "com.dev.luminous"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = luminousApplicationId
        manifestPlaceholders["JPUSH_PKGNAME"] = luminousApplicationId
        manifestPlaceholders["JPUSH_APPKEY"] = jpushAppKey.get()
        manifestPlaceholders["JPUSH_CHANNEL"] = "developer-default"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        ndk {
            // arm64-v8a: all modern 64-bit ARM phones (domestic + international)
            // x86_64:    Android emulators for development
            abiFilters += listOf("arm64-v8a", "x86_64")
        }
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                storeFile = file(keystoreValue("storeFile"))
                storePassword = keystoreValue("storePassword")
                keyAlias = keystoreValue("keyAlias")
                keyPassword = keystoreValue("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            // Keep local release runnable; use real release key when key.properties is provided.
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.core:core-splashscreen:1.0.1")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
