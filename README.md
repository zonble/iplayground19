# iPlayground app 2019

2019 by Weizhong Yang a.k.a zonble

[![Build](https://github.com/zonble/iplayground19/actions/workflows/android_ci.yml/badge.svg)](https://github.com/zonble/iplayground19/actions/workflows/android_ci.yml)

The repo is for [iPlayground 2019](https://iplayground.io/2019/), an iOS
conference in Taipei, Taiwan.

- [iPlayground 19 on App Store](https://apps.apple.com/tw/app/iplayground-18/id1367423535)
- [iPlayground 19 on Google Play](https://play.google.com/store/apps/details?id=net.zonble.iplayground19)

## Requirements

- Flutter 3.32.0 or later
- Dart SDK 3.0.0 or later
- Java 17 (for Android builds)

## Build

This is a Flutter app. Install dependencies first, then build:

```sh
flutter pub get
```

- To build the iOS version, call `flutter build ios`.
- To build the Android version, call `flutter build apk` or `flutter build aab`.
- To run tests, call `flutter test`.
