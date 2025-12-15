# Flutter specific ProGuard rules

# Keep Flutter engine
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep annotations
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions

# Keep Hive models (reflection-based)
-keep class * extends com.hive.** { *; }

# Keep Get/GetX
-keep class get.** { *; }

# Keep serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Parcelables
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep R8 from stripping interfaces
-keep interface * { *; }

# Prevent obfuscation of type parameters
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Flutter local_auth
-keep class androidx.biometric.** { *; }

# Home widgets
-keep class com.chouly.koaa.** { *; }

# Google Play Core - ignore missing classes (not used but referenced by Flutter)
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**
