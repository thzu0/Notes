allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// Fix for plugins (like xxf_isar_flutter_libs) that ship with an outdated
// compileSdk, which breaks the build once newer androidx dependencies
// (e.g. from image_picker) are pulled in.
// NOTE: this block must be registered BEFORE evaluationDependsOn(":app") below,
// otherwise subprojects get evaluated too early and afterEvaluate throws.
subprojects {
    afterEvaluate {
        if (project.hasProperty("android")) {
            val androidExt = project.extensions.findByName("android")
            if (androidExt is com.android.build.gradle.BaseExtension) {
                val currentCompileSdk = androidExt.compileSdkVersion
                    ?.removePrefix("android-")
                    ?.toIntOrNull() ?: 0
                if (currentCompileSdk < 34) {
                    androidExt.compileSdkVersion(36)
                }
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}