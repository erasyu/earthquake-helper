# ProGuard rules for Flutter projects
-keep class io.flutter.** { *; }
-keep class androidx.** { *; }
-dontwarn io.flutter.embedding.**
-dontwarn androidx.lifecycle.**
# Keep rules for SplitCompatApplication
-keep class com.google.android.play.core.splitcompat.** { *; }
-keepclassmembers class com.google.android.play.core.splitcompat.** { *; }
-dontwarn com.google.android.play.core.splitcompat.**

# Flutter map
-keep class org.oscim.** { *; }
-keep class com.beust.jcommander.** { *; }
-keep class org.slf4j.** { *; }
-keep class org.locationtech.jts.** { *; }

-dontwarn org.oscim.**
-dontwarn com.beust.jcommander.**
-dontwarn org.slf4j.**
-dontwarn org.locationtech.jts.**

# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.embedding.engine.** { *; }

-dontwarn io.flutter.embedding.**

# OpenStreetMap
-keep class org.openstreetmap.** { *; }
-dontwarn org.openstreetmap.**

# HTTP and network related
-keep class com.android.okhttp.** { *; }
-keep class okhttp3.** { *; }
-keep class okio.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**

# Flutter Map specific
-keep class flutter_map.** { *; }
-keep class latlong2.** { *; }
-dontwarn flutter_map.**
-dontwarn latlong2.**
