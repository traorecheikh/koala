# Shader Warmup Certification Guide

## Why this is important
Flutter apps on Android (especially older devices) can experience "jank" (stuttering) the first time a complex animation runs. This is because the GPU shader needs to compile on the fly.
We solve this by "warming up" the shaders during the build process.

## Prerequisites
- A physical Android device connected via USB.
- Flutter SDK installed and environment variables set.

## Step-by-Step Guide

### 1. Run the App in Profile Mode with Cache SkSL
Run the app on your device in profile mode, enabling the shader cache capture.

```bash
flutter run --profile --cache-sksl --purge-persistent-cache
```

### 2. Navigate Through the App
Perform every major animation and transition in the app to "record" the shaders.
- Open the app (Splash screen animation).
- Scroll up/down the Home Dashboard.
- Open the "Plus" menu (FAB).
- Navigate to Analytics.
- Swipe through Analytics tabs.
- Navigate to Budget.
- Open a Budget detail.
- Go to Settings.
- Toggle Dark/Light mode (important!).
- Open the Simulator.

### 3. Save the Shader Data
Once you have exercised the app fully, press `M` (uppercase) in the terminal where `flutter run` is running.
This will write a file named `flutter_01.sksl.json` (or similar) to your project root.

### 4. Rename and Move
Rename the file to `flutter_shaders.sksl.json` and move it to a safe location (e.g., project root).

### 5. Build Release with Bundle
When building your release APK or App Bundle, include the bundle-sksl-path argument.

**For APK:**
```bash
flutter build apk --bundle-sksl-path flutter_shaders.sksl.json
```

**For App Bundle (Play Store):**
```bash
flutter build appbundle --bundle-sksl-path flutter_shaders.sksl.json
```

## Verification
Install the release build on a *different* device (or uninstall and reinstall). The first-run animations should now be buttery smooth!
