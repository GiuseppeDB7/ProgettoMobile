# ProGuard rules for ML Kit Text Recognition
-keep class com.google.mlkit.vision.text.** { *; }
-keep class com.google.mlkit.vision.common.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_text_common.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_common.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_text_** { *; }

# ML Kit specifiche lingue - seguendo le istruzioni fornite
-dontwarn com.google.mlkit.vision.text.chinese.**
-assumenosideeffects class com.google.mlkit.vision.text.chinese.** { *; }
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# Google Play Core moderni - solo moduli necessari senza conflitti
-keep class com.google.android.play.core.assetpacks.** { *; }
-keep class com.google.android.play.core.review.** { *; }
-keep class com.google.android.play.core.ktx.** { *; }
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# Firebase rules
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Flutter specifiche - regole base come richiesto
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }

# Flutter deferred components (risolve errori PlayStore)
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
-dontwarn io.flutter.embedding.engine.deferredcomponents.**

# Dart specifiche  
-dontwarn com.google.gson.**
-keep class org.json.** { *; }

# Image picker e camera
-keep class androidx.camera.** { *; }
-dontwarn androidx.camera.**

# Provider e ChangeNotifier
-keep class ** extends androidx.lifecycle.ViewModel { *; }
-keep class ** implements android.os.Parcelable { *; }

# Impedisce l'obfuscation di classi utilizzate tramite reflection
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable

# Regole per evitare warning comuni
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**
