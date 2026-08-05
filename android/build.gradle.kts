allprojects {
    repositories {
        google()
        mavenCentral()
        flatDir {
            dirs("libs") // 指定libs目录
        }
        maven { url  = uri("https://artifactory.bidmachine.io/bidmachine") }
        maven { url  = uri("https://android-sdk.is.com") }
        maven { url  = uri("https://dl-maven-android.mintegral.com/repository/mbridge_android_sdk_oversea") }
        maven { url  = uri("https://artifact.bytedance.com/repository/pangle") }
        maven {
            url  = uri("https://jfrog.anythinktech.com/artifactory/debugger")
        }

        // TU(Core)
        maven {
            url = uri("https://jfrog.anythinktech.com/artifactory/overseas_sdk")
        }

        // Ironsource
        maven {
            url = uri("https://android-sdk.is.com/")
        }

        // Pangle
        maven {
            url = uri("https://artifact.bytedance.com/repository/pangle")
        }

        // Mintegral
        maven {
            url = uri("https://dl-maven-android.mintegral.com/repository/mbridge_android_sdk_oversea")
        }

        // Chartboost
        maven {
            url = uri("https://cboost.jfrog.io/artifactory/chartboost-ads")
        }
        maven {
            url = uri("https://cboost.jfrog.io/artifactory/chartboost-mediation")
        }
        maven {
            url = uri("https://cboost.jfrog.io/artifactory/chartboost-core")
        }

        //Pubnative
        maven {
            url = uri("https://verve.jfrog.io/artifactory/verve-gradle-release")
        }

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
