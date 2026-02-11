import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

fun getKeystoreProperties(project: org.gradle.api.Project): java.util.Properties {
    val properties = Properties()
    val keystorePropertiesFile = project.rootProject.file("key.properties")
    if (keystorePropertiesFile.exists() && keystorePropertiesFile.isFile) {
        try {
            FileInputStream(keystorePropertiesFile).use { fis ->
                properties.load(fis)
            }
        } catch (e: java.io.IOException) {
            project.logger.warn("Could not load keystore properties file.")
        }
    }
    return properties
}

android {
    namespace = "dev.christhoval.apps.multy"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "dev.christhoval.apps.multy"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    val keystoreProperties = getKeystoreProperties(project)

    signingConfigs {
        create("release") {
            if (keystoreProperties.containsKey("storeFile")) {
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
            } else {
                // Configuración de firma de depuración si no se encuentran las propiedades de release
                // Esto es opcional, Flutter suele manejar bien la firma de debug por defecto
                // storeFile = file(debugKeystore.absolutePath) // Ejemplo
                // storePassword = "android"
                // keyAlias = "androiddebugkey"
                // keyPassword = "android"
                project.logger.warn("Release signing config not found. Using debug or no signing.")
            }
        }
        // Puedes tener una configuración de debug explícita si lo deseas, aunque Flutter la gestiona.
        // getByName("debug") {
        //     // Configuración de firma para debug
        // }
    }

    buildTypes {
        getByName("release") {
            // Asigna la configuración de firma al tipo de build 'release'
            signingConfig = signingConfigs.getByName("release")

            // Habilita Proguard/R8 para ofuscación y reducción de tamaño
            // En Kotlin DSL, las propiedades booleanas suelen ser `isPropertyName`
            isMinifyEnabled = true // Flutter suele poner esto en true por defecto para release
            isShrinkResources = true // Flutter suele poner esto en true por defecto para release

            // Especifica los archivos de Proguard
            // proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            // Flutter maneja esto en android/app/proguard-rules.pro
        }
        getByName("debug") {
            // Opcional: configuraciones específicas para debug
            // isMinifyEnabled = false
            // signingConfig = signingConfigs.getByName("debug") // Si tienes una config de debug explícita
        }
        // Puedes tener otros buildTypes como "profile"
        // getByName("profile") {
        //     // ...
        // }
    }
}

flutter {
    source = "../.."
}
