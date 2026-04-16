# Keep Flutter engine & plugins
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Firebase & Google Play Services
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Keep url_launcher (WhatsApp purchase flow)
-keep class io.flutter.plugins.urllauncher.** { *; }