# My CV - iOS

iOS app for my CV: **SwiftUI** UI on top of a shared **Kotlin Multiplatform** data layer.

The data layer and CV content (`cv.json`) live in [8kt8/CvApi](https://github.com/8kt8/CvApi), included here as a git submodule. The Android app ([8kt8/MyCV-Android](https://github.com/8kt8/MyCV-Android)) uses the same data layer with a Jetpack Compose UI.

## Getting started

```bash
git clone --recurse-submodules git@github.com:8kt8/MyCV-iOS.git
open MyCV-iOS/iosApp.xcodeproj
```

Choose an iPhone simulator and press Run. The **Compile Kotlin Framework** build phase runs
`CvApi/gradlew :shared:embedAndSignAppleFrameworkForXcode` and links the resulting `Shared` framework.

Requirements: Xcode 26+ (iOS 26 SDK for Liquid Glass; the project uses a folder-synced group: files added to `iosApp/` are
picked up automatically), runs on iOS 16+, JDK 17+ and the Android SDK (Gradle also configures the shared module's Android target; it uses
`ANDROID_HOME`, or `~/Library/Android/sdk` by default). To run on a real device, set your team under *Signing & Capabilities*.

Already cloned without submodules? Run `git submodule update --init`.

## Structure

| Path | What |
| --- | --- |
| `iosApp/CvScreen.swift` | Root screen: offline-first content, pull to refresh, navigation bar with name and contact menu on scroll. |
| `iosApp/CvViewModel.swift` | `@MainActor` view model calling the shared `CvService` with `async`/`await`. |
| `iosApp/Views/` | Profile header, experience timeline, sections, `FlowLayout`, status-aware image loader. |
| `iosApp/Theme.swift` | Spacing tokens (same scale as Android) and card style. |
| `iosApp/Assets.xcassets` | Accent color and brand icons (vector templates). |
| `Config/Info.plist` | Extra Info.plist keys, merged with the generated one. |
| `CvApi/` (submodule) | Shared KMP data module and `cv.json`. |

## Design

Follows Apple's Human Interface Guidelines for iOS 26/27 (Liquid Glass): glass stays on the navigation layer - the standard
navigation bar (with the system scroll edge effect), its contact menu and the refresh toast - while content uses system
grouped backgrounds, semantic colors and system bordered buttons. Card corners are concentric with their content.
Earlier iOS versions get the bar material and a material toast. Also: Dynamic Type text styles and `@ScaledMetric` sizes,
44pt minimum tap targets, selection haptics, VoiceOver headers and labels, a readable max content width on iPad, and a
single accent color shared with the Android theme.

Update the shared code with `git submodule update --remote CvApi`.

Brand icons: [Simple Icons](https://simpleicons.org) (CC0). Brand icons are trademarks of their owners.
