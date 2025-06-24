# GodotBridge Phase 2 Build History + Debug Notes

## Summary (as of June 23, 2025)

✅ Phase 2 XCFramework build now working — ARM64-only — clean verified slices

---

## Key Roadblocks & How We Solved Them

### 1️⃣ Ghost "Run Script" Phase Bug

**Problem:**  
- Original Run Script Phase used a filename with space:  
  `GodotBridge_macOS target.sh`  
- Xcode embedded the full script into project.pbxproj  
- Even after renaming to `_target.sh`, Xcode used the old cached embedded version  
- This caused:  
  `WriteAuxiliaryFile .../Script-DFFxxxx.sh` in every Archive build  
  → Archive failed

**Solution:**  
✅ Created `pbxproj_clean_script.sh`  
✅ Found and deleted ghost phase lines from .pbxproj  
✅ Rebuilt — Archive succeeded

---

### 2️⃣ DerivedData Caching

**Problem:**  
Even after cleaning .pbxproj, Xcode reused cached phase from DerivedData

**Solution:**  
✅ Manual DerivedData delete:  

```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/GodotBridge-*
```

✅ Full Xcode quit → reopen → success

---

### 3️⃣ iOS Archive Failing

**Problem:**  
iOS Run Script Phase also had embedded ghost phase:  
→ Same cause as macOS  
→ Same fix

**Solution:**  
✅ Cleaned iOS ghost phase  
✅ Archive now succeeds

---

### 4️⃣ Final Phase 2 Results

✅ `build_arm64_only.sh` — now builds:  
✅ macOS archive  
✅ iOS archive  
✅ XCFramework — verified slices

```
build/GodotBridge.xcframework
├── ios-arm64/GodotBridge_iOS.framework
├── macos-arm64/GodotBridge_macOS.framework
```

---

### 5️⃣ Lessons Learned

- Be very careful with spaces in Run Script filenames  
- Always verify project.pbxproj after adding Run Script  
- Xcode cache is very persistent — clear it!  
- Run Script phases with `"Run script only when installing"` required for Archive builds  
- BUILD_LIBRARY_FOR_DISTRIBUTION and SKIP_INSTALL required

---

### Next Steps

**Pending Tests:**  
- Godot Runtime integration (Phase 2.5)  
- App load tests  
- CI automation of full build

**Prepared:**  
✅ XCFramework now working  
✅ Phase 2 ready for further testing

---

# Phase 2 Context Update (2025-06-23)

## Build System Evolution

- **build_arm64_only.sh** now builds iOS + macOS archives only
- **prepare_xcframework.sh** performs:
  - Creates XCFramework from archives
  - Adds required module.modulemap to both slices

## Key Issues Discovered + Solved

- Xcode does not auto-generate modulemap for Objective-C frameworks — required manual generation
- Previous "Run Script Phase" in Xcode was executing too late — not injecting Modules properly
- Original combined build script was doing too much (overwrote XCFramework)
- Clean separation into archive step + prepare step now ensures correctness

## Verification

- Framework structure validated via Terminal
- Binaries present and correct
- Architectures verified: arm64 only
- Modules/module.modulemap present in both slices
- Ready for NativeBridge import

## Current Status

✅ GodotBridge.xcframework verified and correct  
✅ Ready for Phase 2 final commit and integration testing  
✅ Will push updated ReadMe.md, context.md and all scripts to GitHub after validation
