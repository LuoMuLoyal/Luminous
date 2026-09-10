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
            // Explicit intent only: the Flutter Gradle plugin overrides these with
            // its own PLATFORM_ABI_LIST (arm64-v8a + armeabi-v7a + x86_64) unless
            // -Pdisable-abi-filtering=true is passed. Keeping arm64/x86_64 here
            // documents which ABIs this app actually targets.
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
            // NOTE: Do NOT put packagingOptions here. In AGP 9 the legacy
            // packagingOptions DSL is backed by a project-global instance, so a block
            // inside buildTypes.release still strips x86_64 from DEBUG APKs too —
            // which breaks `flutter run` on x86_64 emulators ("Could not find
            // 'libflutter.so'"). Release-only stripping lives in the
            // androidComponents.onVariants(selector().withBuildType("release"))
            // block further down.
        }
    }
}

androidComponents {
    // Strip x86_64/armeabi-v7a native libs ONLY from release APKs via the
    // variant-scoped packaging API (AGP 8+), which genuinely applies per variant.
    // Debug must keep x86_64: `flutter run` on android-x64 emulators builds the
    // x86_64 engine (lib/x86_64/libflutter.so); stripping it crashes the app at
    // startup with "Could not find 'libflutter.so'" (see error.md).
    // The released APK stays arm64-only so Google Play only shows arm64 devices.
    onVariants(selector().withBuildType("release")) { variant ->
        variant.packaging.jniLibs.excludes.addAll(
            listOf("lib/x86_64/**", "lib/armeabi-v7a/**"),
        )
        variant.packaging.resources.excludes.addAll(
            listOf("lib/x86_64/**", "lib/armeabi-v7a/**"),
        )
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
