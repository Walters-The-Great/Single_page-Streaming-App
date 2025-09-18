## Live Stream Demo — Flutter (Android)

A minimal single-screen Flutter app that autoplays a single livestream when launched. Designed as a simple demo: one channel, no switching, minimal UI.

### How it works
- **Single screen**: `lib/main.dart` defines `LivePlayerScreen` as the home screen.
- **Autoplay on launch**: A `VideoPlayerController` is initialized in `initState` with an HLS URL and immediately `play()`s.
- **Minimal UI**: Black background, centered video with proper aspect ratio, simple loading and error states.
- **Network permission**: Android `INTERNET` permission is declared in `android/app/src/main/AndroidManifest.xml`.
- **Dependency**: Uses `video_player` for playback, declared in `pubspec.yaml`.

### Change the livestream URL
Edit `_streamUrl` in `lib/main.dart`:
```dart
static const String _streamUrl = 'https://your-host/path/stream.m3u8';
```
Prefer HLS (.m3u8) for widest device compatibility.

## Run on another system with VS Code

### Prerequisites
- Flutter SDK installed and on PATH
- Android Studio with Android SDK + Platform Tools
- AVD (Android emulator) or a physical Android device with USB debugging
- VS Code with the Flutter and Dart extensions

Verify setup:
```bash
flutter doctor -v
```

### Get the code and dependencies
```bash
git clone <this-repo-url>
cd test_app
flutter pub get
```

### Open in VS Code and run
1. Open the folder in VS Code.
2. Start an emulator (e.g., Pixel 6) via Android Studio or the VS Code device picker, or plug in a device.
3. In VS Code, press F5 or use the Run and Debug button to launch.
   - Or from terminal:
   ```bash
   flutter run -d <deviceId>
   ```
   Use `flutter devices` to list device IDs.

### Build an Android APK
```bash
flutter build apk --release
```
The APK will be in `build/app/outputs/flutter-apk/app-release.apk`.

## Troubleshooting
- "Gradle could not resolve dependencies" or Kotlin stdlib download errors:
  - Ensure internet access and that `dl.google.com`, `repo.maven.apache.org`, and `storage.googleapis.com` are reachable.
  - If behind a proxy, configure Gradle proxy in `~/.gradle/gradle.properties` or project `android/gradle.properties`:
    ```
    systemProp.http.proxyHost=YOUR_PROXY_HOST
    systemProp.http.proxyPort=YOUR_PROXY_PORT
    systemProp.https.proxyHost=YOUR_PROXY_HOST
    systemProp.https.proxyPort=YOUR_PROXY_PORT
    ```
  - Then run:
    ```bash
    flutter clean
    flutter pub get
    flutter run
    ```
- Emulator performance or playback issues: try a physical device, or use an emulator image with hardware acceleration enabled. HLS streams generally work best.

## Project structure
- `lib/main.dart`: App entry point and live player screen
- `pubspec.yaml`: Dependencies (`video_player`)
- `android/app/src/main/AndroidManifest.xml`: Declares `INTERNET` permission

## License
Demo use only.
