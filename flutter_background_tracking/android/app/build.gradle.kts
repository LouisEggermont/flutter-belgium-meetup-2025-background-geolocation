import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val backgroundGeolocation = project(":flutter_background_geolocation")
apply { from("${backgroundGeolocation.projectDir}/background_geolocation.gradle") }

// 🔐 Load keystore properties
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    load(FileInputStream(keystorePropertiesFile))
}

// 🔐 Load .env properties (e.g. GOOGLE_MAPS_API_KEY)
val localEnv = Properties()
val localEnvFile = file("../../.env")
if (localEnvFile.exists()) {
    localEnv.load(localEnvFile.inputStream())
}

android {
    namespace = "com.example.flutter_background_tracking"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    signingConfigs {
        getByName("debug") {
            storeFile = file(keystoreProperties["storeFile"] as String)
            keyAlias = keystoreProperties["keyAlias"] as String
            storePassword = keystoreProperties["storePassword"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
        }
        create("release") {
            storeFile = file(keystoreProperties["storeFile"] as String)
            keyAlias = keystoreProperties["keyAlias"] as String
            storePassword = keystoreProperties["storePassword"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
        }
    }

    defaultConfig {
        applicationId = "com.example.flutter_background_tracking"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // 🔑 Inject Google Maps API key from .env
        manifestPlaceholders["GOOGLE_MAPS_API_KEY"] =
    (localEnv["GOOGLE_MAPS_API_KEY"] ?: throw GradleException("Missing GOOGLE_MAPS_API_KEY in .env")) as String
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
            isShrinkResources = false
        }
    }

    flutter {
        source = "../.."
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }
}