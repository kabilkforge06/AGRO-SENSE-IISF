plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.agrosense.farmingassist"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.agrosense.farmingassist"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// Create a task to copy APK to Flutter expected location
tasks.register("copyApkToFlutterLocation") {
    doLast {
        val buildOutputs = file("${rootProject.projectDir}/../build/app/outputs")
        val flutterApkDir = file("${buildOutputs}/flutter-apk")
        flutterApkDir.mkdirs()
        
        // Copy from both possible locations
        copy {
            from("${buildDir}/outputs/apk/debug")
            into(flutterApkDir)
            include("*.apk")
        }
        copy {
            from("${buildDir}/outputs/flutter-apk")
            into(flutterApkDir)
            include("*.apk")
        }
    }
}

// Make the copy task run after any assemble task
tasks.matching { it.name.startsWith("assemble") }.configureEach {
    finalizedBy("copyApkToFlutterLocation")
}

dependencies {
    implementation("androidx.concurrent:concurrent-futures:1.2.0")
    implementation("androidx.concurrent:concurrent-futures-ktx:1.2.0")
}
