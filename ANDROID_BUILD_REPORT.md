# ANDROID_BUILD_REPORT.md — Android Release Build

**Date:** 2026-06-23
**Status:** BLOCKED — Flutter SDK not installed

---

## Build Configuration

| Setting | Value | Status |
|---|---|---|
| `applicationId` | `com.nexora.control_center` | ✅ |
| `minSdk` | 21 | ✅ |
| `targetSdk` | 34 | ✅ |
| `compileSdk` | Flutter default | ✅ |
| `versionCode` | Flutter versionCode | ✅ |
| `versionName` | Flutter versionName | ✅ |
| `signingConfig` | Falls back to debug (no key.properties) | ⚠️ |
| `isMinifyEnabled` | true | ✅ |
| `isShrinkResources` | true | ✅ |
| ProGuard | `proguard-rules.pro` present | ✅ |
| Network Security | `network_security_config.xml` (localhost only) | ✅ |
| `AndroidManifest.xml` | Label="Nexora", permissions set | ✅ |

---

## Build Commands

```bash
# Step 1: Install Flutter SDK 3.12.1+
# Step 2: Enable Windows desktop
flutter config --enable-windows-desktop

# Step 3: Clean
cd control_center
flutter clean
flutter pub get

# Step 4: Build APK
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# Step 5: Build AAB
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

---

## Signing (Production)

To create a release keystore:
```bash
keytool -genkey -v -keystore nexora-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias nexora
```

Create `android/key.properties`:
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=nexora
storeFile=<path>/nexora-release.jks
```

---

## Android Permissions

| Permission | Purpose |
|---|---|
| INTERNET | API calls |
| ACCESS_NETWORK_STATE | Network detection |
| CAMERA | Agent camera features |
| RECORD_AUDIO | Voice AI calls |
| READ_EXTERNAL_STORAGE | File access |
| WRITE_EXTERNAL_STORAGE | File saving |
| POST_NOTIFICATIONS | Push notifications |

---

## Verdict: ⏳ AWAITING FLUTTER SDK INSTALLATION
