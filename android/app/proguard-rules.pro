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
