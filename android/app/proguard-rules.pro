# Preserve Flutter's classes and methods
-keep class io.flutter.** { *; }

# Preserve AndroidX library classes
-keep class androidx.** { *; }

# Prevent warnings related to Flutter embedding and AndroidX lifecycle
-dontwarn io.flutter.embedding.**
-dontwarn androidx.lifecycle.**

# Preserve methods annotated with @JavascriptInterface
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Keep your app's main activity and other entry points
-keep class com.yourpackage.name.** { *; }

# Optional: Keep any custom models or critical classes
# For example, if using Firebase Firestore:
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
-keep public class com.google.android.play.core.splitcompat.** { *; }
-keep public class com.google.android.play.core.splitinstall.** { *; }
-keep public class com.google.android.play.core.appupdate.** { *; }
-keep public class com.google.android.play.core.tasks.** { *; }

# Please add these rules to your existing keep rules in order to suppress warnings.
# This is generated automatically by the Android Gradle plugin.
-dontwarn com.google.android.play.core.common.IntentSenderForResultStarter
-dontwarn com.google.android.play.core.common.PlayCoreDialogWrapperActivity
-dontwarn com.google.android.play.core.listener.StateUpdatedListener

# Please add these rules to your existing keep rules in order to suppress warnings.
# This is generated automatically by the Android Gradle plugin.
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
# Keep Google Play Core classes for in-app updates
-keep class com.google.android.play.core.** { *; }

# Keep the specific classes mentioned in the error
-keep class com.google.android.play.core.common.IntentSenderForResultStarter { *; }
-keep class com.google.android.play.core.common.PlayCoreDialogWrapperActivity { *; }
-keep class com.google.android.play.core.listener.StateUpdatedListener { *; }
-keep class com.pixelCrafters.hide_out_lounge.MainActivity { *; }
-keep class proguard.annotation.Keep
-keep class proguard.annotation.KeepClassMembers
