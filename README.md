# My CV - iOS

iOS app for my CV, built with **Kotlin Multiplatform** and **Compose Multiplatform**.

The UI, data layer and CV content live in the shared module in [8kt8/CvApi](https://github.com/8kt8/CvApi), included here as a git submodule. The Android app is [8kt8/MyCV-Android](https://github.com/8kt8/MyCV-Android).

## Getting started

```bash
git clone --recurse-submodules git@github.com:8kt8/MyCV-iOS.git
open MyCV-iOS/iosApp.xcodeproj
```

Choose an iPhone simulator and press Run. The **Compile Kotlin Framework** build phase runs
`CvApi/gradlew :shared:embedAndSignAppleFrameworkForXcode` and links the resulting `Shared` framework.

Requirements: Xcode, JDK 17+ and the Android SDK (Gradle configures the shared module's Android target too;
it uses `ANDROID_HOME`, or `~/Library/Android/sdk` by default). To run on a real device, set your team under
*Signing & Capabilities*.

Already cloned without submodules? Run `git submodule update --init`.

## Structure

| Path | What |
| --- | --- |
| `iosApp/` | SwiftUI entry point hosting the shared Compose UI (`MainViewControllerKt.MainViewController()`). |
| `iosApp.xcodeproj` | Xcode project. |
| `CvApi/` (submodule) | Shared KMP module and `cv.json`. |

Update the shared code with `git submodule update --remote CvApi`.
