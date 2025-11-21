plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.family"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.family"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23
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
dependencies {
    // ✅ ใช้ Firebase BoM เพื่อให้เวอร์ชันของ Firebase เข้ากันได้
    implementation(platform("com.google.firebase:firebase-bom:34.0.0"))

    // ✅ Firebase ที่เปิดใช้งาน
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")

    // 🔹 เพิ่มเติม (ยกเลิกคอมเมนต์ถ้าต้องการใช้):
    // implementation("com.google.firebase:firebase-database")
    // implementation("com.google.firebase:firebase-messaging")
    // implementation("com.google.firebase:firebase-storage")
    // implementation("com.google.firebase:firebase-crashlytics")
    // implementation("com.google.firebase:firebase-config")

    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}