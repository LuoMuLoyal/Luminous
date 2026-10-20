pluginManagement {
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

dependencyResolutionManagement {
    repositories {
        if (System.getenv("LUMOS_GRADLE_MIRROR") == "aliyun") {
            maven(url = uri("https://maven.aliyun.com/repository/google"))
            maven(url = uri("https://maven.aliyun.com/repository/public"))
        }
        google()
        mavenCentral()
    }
}

rootProject.name = "luminous-native"
include(":luminous-native")
