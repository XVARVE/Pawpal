pluginManagement {
    val props = java.util.Properties()
    file("local.properties").inputStream().use { props.load(it) }
    val flutterSdk = props.getProperty("flutter.sdk")
        ?: throw GradleException("flutter.sdk not set in local.properties")
    includeBuild("$flutterSdk/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }


}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.5.2"
    id("org.jetbrains.kotlin.android") version "1.9.24"
    id("com.google.gms.google-services") version "4.4.2"
    id("com.google.firebase.crashlytics") version "3.0.2"
}

include(":app")
