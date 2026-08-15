allprojects {
    repositories {
        // maven.google.com 在本机网络被挡（2026-08-15 实测超时）；设 LUMOS_GRADLE_MIRROR=aliyun
        // 时改用阿里云镜像兜底（默认关闭，不影响 CI）。
        if (System.getenv("LUMOS_GRADLE_MIRROR") == "aliyun") {
            maven(url = uri("https://maven.aliyun.com/repository/google"))
            maven(url = uri("https://maven.aliyun.com/repository/public"))
        }
        google()
        mavenCentral()
    }
}

subprojects {
    configurations.configureEach {
        resolutionStrategy.force(
            "androidx.test:runner:1.6.1",
            "androidx.test:rules:1.6.1",
            "androidx.test.espresso:espresso-core:3.6.1",
        )
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
