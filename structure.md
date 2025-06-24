# GodotBridge Project Structure (as of June 23, 2025)

---

## Top Level

- GodotBridge.xcodeproj
- GodotBridge_Testing.sh
- GodotBridge_iOS/
- GodotBridge_iOS_target.sh
- GodotBridge_macOS/
- GodotBridge_macOS_target.sh
- ReadMe.md
- context.md
- build_arm64_only.sh
- build/  ← Phase 2 outputs here
- build_logs_20250623_214523/  ← Phase 2 logs here

---

## Key Folders

```text
./GodotBridge.xcodeproj/project.xcworkspace
./GodotBridge_iOS/GodotBridge_iOS.docc
./GodotBridge_macOS/GodotBridge_macOS.docc
```

---

## Build Outputs

```text
build/GodotBridge.xcframework/
├── ios-arm64/GodotBridge_iOS.framework
├── macos-arm64/GodotBridge_macOS.framework

build/GodotBridge_iOS.xcarchive/
├── Products/Library/Frameworks/GodotBridge_iOS.framework
├── dSYMs/GodotBridge_iOS.framework.dSYM

build/GodotBridge_macOS.xcarchive/
├── Products/Library/Frameworks/GodotBridge_macOS.framework
├── dSYMs/GodotBridge_macOS.framework.dSYM
```

---

## Build Logs

```text
build_logs_20250623_214523/
├── 00_summary.md
├── 02_ios_build.md
├── 03_macos_build.md
├── 04_xcframework.md
├── 05_verification.md
├── 99_full_build.log
```

---

## Notes

✅ Phase 2 XCFramework is present and verified: `build/GodotBridge.xcframework`  
✅ Both macOS and iOS archives exist  
✅ No Intel/x86 slices  
✅ Verified ARM64-only

---

# Phase 2 Structure Update (2025-06-23)

## Build Scripts

- **build_arm64_only.sh**
  - Builds iOS + macOS archives
  - No longer auto-creates XCFramework
  - Prepares log directory and full build logs

- **prepare_xcframework.sh**
  - Runs `xcodebuild -create-xcframework`
  - Adds module.modulemap to both slices
  - Ensures XCFramework is properly prepared for NativeBridge

## Targets

- GodotBridge_iOS_target.sh (v3)
- GodotBridge_macOS_target.sh (v3)
  - Correct framework paths
  - No more broken "Run Script Phase" in Xcode — all handled via external scripts

## Outputs

- **build/GodotBridge_iOS.xcarchive/**
- **build/GodotBridge_macOS.xcarchive/**
- **build/GodotBridge.xcframework/**
  - Includes Modules/module.modulemap
  - Correct ARM64 binaries
  - Ready for NativeBridge import

## Logs

- **build_logs_YYYYMMDD_HHMMSS/**
  - Summary, full logs, per-target logs
