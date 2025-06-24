# GodotBridge XCFramework (ARM64 ONLY)

A modern, ARM64-exclusive Objective-C++ bridge for integrating Godot Engine with iOS and macOS applications on Apple Silicon.

## Overview

GodotBridge provides a unified interface for embedding Godot Engine into native iOS and macOS applications. Built exclusively for Apple Silicon (ARM64) - no Intel support, no universal binaries, no legacy code.

**This is a 2025 project for 2025 hardware.**

## Architecture Design

### Why XCFramework?

We chose the XCFramework approach over embedded source files for several critical reasons:

#### 1. **Separation of Concerns**
- **Clean API Boundary**: The framework provides a stable, versioned interface between your app and Godot
- **Modularity**: Bridge logic is isolated from your main application code
- **Reusability**: The same framework can be used across multiple projects without code duplication

#### 2. **Avoiding iOS .mm Compilation Issues**
The primary driver for the XCFramework approach was resolving complex iOS compilation issues:

- **Mixed Language Complexity**: Direct `.mm` files in iOS projects often create module verification failures
- **C++ Symbol Conflicts**: Godot's extensive C++ codebase can conflict with iOS frameworks and other C++ dependencies
- **Template Instantiation Issues**: C++ templates and iOS build systems don't always play nicely together
- **Linker Problems**: Direct inclusion often leads to symbol redefinition and linker errors

#### 3. **Framework Benefits**
- **Pre-compiled**: All C++ compilation happens during framework build, not app build
- **Symbol Isolation**: C++ symbols are contained within the framework boundary
- **Module System**: Proper Swift module support with clean import statements
- **Version Control**: Framework versioning allows for controlled updates

#### 4. **ARM64-Only Platform Support**
```
GodotBridge.xcframework/
├── ios-arm64/           # iOS devices (A12 Bionic and newer)
└── macos-arm64/         # Apple Silicon Macs (M1/M2/M3/M4)
```

**NO UNIVERSAL BINARIES. NO INTEL SUPPORT. ARM64 ONLY.**

## Framework Structure

## Phase 2 Build Status (as of June 23, 2025)

✅ macOS Archive (ARM64) → Success
✅ iOS Archive (ARM64) → Success
✅ XCFramework (ARM64-only) → Success
✅ Modulemaps (macOS + iOS) → Integrated
✅ No Intel / No x86 slices → Verified

**Pending Next Tests:**
- Godot Runtime integration (Phase 2.5)
- App load tests
- CI automation

For full Phase 2 build history — see: [context.md](context.md)

### Public Interface
```objc
@interface GodotBridge : NSObject

// Singleton access
@property (class, nonatomic, readonly) GodotBridge *sharedBridge;

// Lifecycle management
- (BOOL)initializeWithMetalLayer:(CAMetalLayer *)metalLayer error:(NSError **)error;
- (BOOL)startWithError:(NSError **)error;
- (void)stop;

// State properties
@property (nonatomic, readonly) BOOL isInitialized;
@property (nonatomic, readonly) BOOL isRunning;
@property (nonatomic, readonly) CAMetalLayer *godotMetalLayer;

@end
```

### Internal Architecture (ARM64 Native)
```
┌─────────────────────┐    ┌─────────────────────┐    ┌─────────────────────┐
│  Swift App (ARM64)  │ ←→ │ GodotBridge (ARM64) │ ←→ │ libgodot (ARM64)    │
│                     │    │                     │    │                     │
│ • SwiftUI           │    │ • Public ObjC API   │    │ • Godot C++ Runtime │
│ • Metal 3           │    │ • Metal Setup       │    │ • Rendering Engine  │
│ • ProMotion Ready   │    │ • ARM64 Optimized   │    │ • Apple Silicon GPU │
└─────────────────────┘    └─────────────────────┘    └─────────────────────┘
```

## Usage

### 1. Swift Integration (Apple Silicon Optimized)
```swift
import Foundation
import Metal

#if os(iOS)
import GodotBridge_iOS    // ARM64 iOS (A12+)
#elseif os(macOS)
import GodotBridge_macOS  // ARM64 macOS (M1+)
#endif

class GameEngine {
    private let bridge = GodotBridge.sharedBridge()
    
    func initialize() throws {
        let metalLayer = CAMetalLayer()
        // Apple Silicon GPU (M1/M2/M3/M4 or A12+)
        metalLayer.device = MTLCreateSystemDefaultDevice()
        
        var error: NSError?
        let success = bridge.initialize(withMetalLayer: metalLayer, error: &error)
        
        if !success {
            throw error ?? GameEngineError.initializationFailed
        }
    }
    
    func start() throws {
        var error: NSError?
        let success = bridge.start(withError: &error)
        
        if !success {
            throw error ?? GameEngineError.startFailed
        }
    }
}
```

### 2. Framework Import Pattern
```swift
// Modern ARM64-only import
#if os(iOS)
import GodotBridge_iOS    // ARM64 iPhone/iPad
#elif os(macOS)
import GodotBridge_macOS  // ARM64 Apple Silicon Macs
#endif
```

### 3. Project Integration
1. **Add Framework**: Drag `GodotBridge.xcframework` to your project
2. **Link Binary**: Add to "Link Binary With Libraries"
3. **Embed Framework**: Add to "Embed Frameworks"
4. **Verify ARM64**: Check that framework contains ONLY ARM64 slices

## Build Process (ARM64 ONLY)

### Complete Build Script (build_arm64_only.sh)
```bash
#!/bin/bash

echo "🚀 Building ARM64-ONLY XCFramework for Apple Silicon"

# Clean previous builds
rm -rf build/
rm -rf GodotBridge.xcframework

# Build iOS - ARM64 ONLY
echo "📱 Building iOS (ARM64 only)..."
xcodebuild archive \
  -project GodotBridge.xcodeproj \
  -scheme "GodotBridge_iOS" \
  -destination "generic/platform=iOS" \
  -archivePath "build/GodotBridge_iOS.xcarchive" \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  DEFINES_MODULE=NO \
  ARCHS=arm64 \
  VALID_ARCHS=arm64

# Build macOS - ARM64 ONLY
echo "💻 Building macOS (Apple Silicon ONLY)..."
xcodebuild archive \
  -project GodotBridge.xcodeproj \
  -scheme "GodotBridge_macOS" \
  -destination "generic/platform=macOS" \
  -archivePath "build/GodotBridge_macOS.xcarchive" \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  DEFINES_MODULE=NO \
  ARCHS=arm64 \
  VALID_ARCHS=arm64 \
  EXCLUDED_ARCHS=x86_64

# Create XCFramework - ARM64 ONLY
xcodebuild -create-xcframework \
  -framework "build/GodotBridge_iOS.xcarchive/Products/Library/Frameworks/GodotBridge_iOS.framework" \
  -framework "build/GodotBridge_macOS.xcarchive/Products/Library/Frameworks/GodotBridge_macOS.framework" \
  -output "GodotBridge.xcframework"

# Add module maps (required for DEFINES_MODULE=NO)
# iOS
mkdir -p GodotBridge.xcframework/ios-arm64/GodotBridge_iOS.framework/Modules
cat > GodotBridge.xcframework/ios-arm64/GodotBridge_iOS.framework/Modules/module.modulemap << 'EOF'
framework module GodotBridge_iOS {
    umbrella header "GodotBridge.h"
    export *
    module * { export * }
}
EOF

# macOS
mkdir -p GodotBridge.xcframework/macos-arm64/GodotBridge_macOS.framework/Modules
cat > GodotBridge.xcframework/macos-arm64/GodotBridge_macOS.framework/Modules/module.modulemap << 'EOF'
framework module GodotBridge_macOS {
    umbrella header "GodotBridge.h"
    export *
    module * { export * }
}
EOF

echo "✅ ARM64-ONLY XCFramework created!"
```

### Key Build Flags (ARM64 Enforcement)
- **ARCHS=arm64**: Build ONLY for ARM64
- **VALID_ARCHS=arm64**: Accept ONLY ARM64
- **EXCLUDED_ARCHS=x86_64**: Explicitly exclude Intel
- **DEFINES_MODULE=NO**: Avoid VerifyModule issues, add module maps manually

## Module Map Solution

Due to C++ complexity, we use `DEFINES_MODULE=NO` and manually add module maps:

```modulemap
framework module GodotBridge_iOS {
    umbrella header "GodotBridge.h"
    export *
    module * { export * }
}
```

Module maps are placed at:
- `ios-arm64/GodotBridge_iOS.framework/Modules/module.modulemap`
- `macos-arm64/GodotBridge_macOS.framework/Modules/module.modulemap`

## Design Decisions

### Why ARM64 Only?
1. **It's 2025**: Apple Silicon has been available for 5 years
2. **Performance**: Native ARM64 performance without translation layers
3. **Simplicity**: No fat binaries, no architecture checks
4. **Future-Proof**: Apple's direction is clear - ARM64 forever

### Platform Requirements

#### iOS
- **Minimum**: A12 Bionic (iPhone XS, 2018)
- **Recommended**: A15 Bionic or newer
- **Features**: Neural Engine, ProMotion support

#### macOS
- **Minimum**: M1 (2020)
- **Recommended**: M2 or newer
- **Features**: Unified memory, Metal 3

### Error Handling Strategy
```objc
// Objective-C style with NSError for framework boundary
- (BOOL)operationWithError:(NSError **)error;

// Swift translation
func operation() throws {
    var nsError: NSError?
    let success = bridge.operation(withError: &nsError)
    if !success {
        throw nsError ?? BridgeError.unknown
    }
}
```

## Verification

### Verify ARM64-Only Build
```bash
# Check that framework is ARM64 only
lipo -info GodotBridge.xcframework/macos-arm64/GodotBridge_macOS.framework/GodotBridge_macOS
# Output: "Non-fat file: ... is architecture: arm64"

# Check framework structure
ls GodotBridge.xcframework/
# Output: Info.plist  ios-arm64  macos-arm64
# NOT: macos-arm64_x86_64 (that's a universal binary!)
```

## Performance Considerations

### Metal 3 Optimization
- **Direct Layer Access**: Optimized for Apple Silicon GPU architecture
- **ProMotion Support**: 120Hz rendering on supported displays
- **Unified Memory**: Leverages Apple's unified memory architecture

### Threading
- **Main Thread**: SwiftUI and UI operations
- **Render Thread**: Metal 3 optimized rendering
- **Game Thread**: Godot game logic

## Troubleshooting

### Common Issues

#### 1. Module Not Found
```
Error: No such module 'GodotBridge_iOS'
```
**Solution**: Ensure module maps are properly added after building with `DEFINES_MODULE=NO`

#### 2. Wrong Architecture
```
Error: Building for iOS Simulator, but linking in dylib built for iOS
```
**Solution**: This framework is ARM64 only. Use physical devices or Apple Silicon Mac

#### 3. Universal Binary Created
If you see `macos-arm64_x86_64` in your framework:
**Solution**: Rebuild using the `build_arm64_only.sh` script with proper exclusion flags

## Contributing

### Requirements
- **Hardware**: Apple Silicon Mac (M1 or newer)
- **Xcode**: 15.0+ on Apple Silicon
- **Testing**: Physical iOS devices (A12+) or Apple Silicon Macs only

### No Intel Support
- PRs adding x86_64 support will be rejected
- Testing on Intel Macs is not supported
- Rosetta testing is discouraged

## License

MIT License - See [LICENSE](LICENSE) for details.

## Dependencies

- **libgodot.xcframework**: Godot Engine runtime (ARM64 only)
- **Metal Framework**: Apple Silicon GPU rendering
- **Foundation**: Core framework support

---

**This is an ARM64-only framework for Apple Silicon devices. No Intel support. No universal binaries. Pure ARM64 performance for modern Apple hardware.**

## Phase 2 Accomplishments (2025-06-23)

✅ Created a clean 2-step build process:
- `build_arm64_only.sh`: builds iOS + macOS archives
- `prepare_xcframework.sh`: creates XCFramework + injects modulemap

✅ Resolved missing Modules/module.modulemap
✅ Confirmed correct slice structure:
  - iOS ARM64
  - macOS ARM64

✅ Confirmed binaries present and correct:
  - iOS: Non-fat file, architecture: arm64
  - macOS: Non-fat file, architecture: arm64

✅ Confirmed modulemap present in both slices
✅ Verified NativeBridge now sees `GodotBridge.xcframework`

### Roadblocks overcome:
- Xcode’s `BUILD_LIBRARY_FOR_DISTRIBUTION` and `DEFINES_MODULE` do not auto-generate modulemap for Obj-C framework
- Manual `prepare_xcframework.sh` created to handle this properly
- Fixed phase order (previous Run Script phase too late to inject Modules)
- Fixed accidental skipped XCFramework step (restored in correct prep script)

### Current state:
**XCFramework is clean and correct — ready for NativeBridge integration.**

### Next steps:
- Validate import in NativeBridge
- If successful, Phase 2 complete and ready to push to GitHub
