# GodotBridge XCFramework

A clean, multi-platform Objective-C++ bridge for integrating Godot Engine with iOS and macOS applications via Swift.

## Overview

GodotBridge provides a unified interface for embedding Godot Engine into native iOS and macOS applications. The bridge handles platform-specific initialization, Metal rendering setup, and bidirectional communication between Swift/Objective-C and Godot's C++ runtime.

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

#### 4. **Multi-Platform Support**
```
GodotBridge.xcframework/
├── ios-arm64/                    # iOS devices
├── ios-arm64-simulator/          # iOS simulator (if needed)
└── macos-arm64_x86_64/          # macOS universal binary
```

Each platform gets optimized binaries without cross-compilation issues.

## Framework Structure

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

### Internal Architecture
```
┌─────────────────────┐    ┌─────────────────────┐    ┌─────────────────────┐
│      Swift App      │ ←→ │  GodotBridge.xcf    │ ←→ │  libgodot.xcf       │
│                     │    │                     │    │                     │
│ • UI Logic          │    │ • Public ObjC API   │    │ • Godot C++ Runtime │
│ • Game Controller   │    │ • Metal Setup       │    │ • Rendering Engine  │
│ • State Management  │    │ • Platform Handling │    │ • Scene Management  │
└─────────────────────┘    └─────────────────────┘    └─────────────────────┘
```

## Usage

### 1. Swift Integration
```swift
import Foundation

class GameEngine {
    private let bridge = GodotBridge.sharedBridge()
    
    func initialize() throws {
        let metalLayer = CAMetalLayer()
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

### 2. Bridging Header Setup
```objc
//
//  YourApp-Bridging-Header.h
//

#if TARGET_OS_IOS
#import <GodotBridge_iOS/GodotBridge_iOS.h>
#elif TARGET_OS_OSX
#import <GodotBridge_macOS/GodotBridge_macOS.h>
#endif
```

### 3. Project Integration
1. **Add Framework**: Drag `GodotBridge.xcframework` to your project
2. **Link Binary**: Add to "Link Binary With Libraries"
3. **Embed Framework**: Add to "Embed Frameworks"
4. **Configure Bridging Header**: Set up imports as shown above

## Build Process

### Framework Build
```bash
# iOS Framework
xcodebuild archive \
  -project GodotBridge.xcodeproj \
  -scheme "GodotBridge_iOS" \
  -destination "generic/platform=iOS" \
  -archivePath "build/ios.xcarchive" \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# macOS Framework  
xcodebuild archive \
  -project GodotBridge.xcodeproj \
  -scheme "GodotBridge_macOS" \
  -destination "generic/platform=macOS" \
  -archivePath "build/macos.xcarchive" \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# Create XCFramework
xcodebuild -create-xcframework \
  -framework "build/ios.xcarchive/Products/Library/Frameworks/GodotBridge_iOS.framework" \
  -framework "build/macos.xcarchive/Products/Library/Frameworks/GodotBridge_macOS.framework" \
  -output "GodotBridge.xcframework"
```

### Key Build Considerations
- **BUILD_LIBRARY_FOR_DISTRIBUTION=YES**: Ensures compatibility across Xcode versions
- **SKIP_INSTALL=NO**: Required for proper framework archiving
- **Module Definition**: Framework provides proper Swift module support

## Design Decisions

### Why Not Direct Source Integration?
1. **Compilation Complexity**: Godot's C++ codebase is complex and doesn't integrate well with iOS build systems
2. **Symbol Conflicts**: Direct inclusion often causes linker errors and symbol conflicts
3. **Build Time**: Framework pre-compilation reduces app build times
4. **Maintenance**: Cleaner separation makes updates and debugging easier

### Platform-Specific Considerations

#### iOS
- **Metal Integration**: Direct CAMetalLayer setup for optimal rendering performance
- **Lifecycle Management**: Proper handling of iOS app lifecycle (background/foreground)
- **Memory Management**: ARC-compatible reference handling

#### macOS
- **Display Link**: Native macOS display synchronization
- **Window Management**: Integration with NSWindow and NSView hierarchies
- **Input Handling**: macOS-specific keyboard and mouse input

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

## Troubleshooting

### Common Issues

#### 1. Framework Not Found
```
Error: 'GodotBridge_iOS/GodotBridge_iOS.h' file not found
```
**Solution**: Ensure framework is added to both "Link Binary With Libraries" and "Embed Frameworks"

#### 2. Module Verification Failures
```
Error: VerifyModule failed
```
**Solution**: Build framework with `DEFINES_MODULE=NO` if needed, or fix header imports

#### 3. Swift Can't See Bridge
```
Error: Type 'GodotBridge' has no member 'sharedBridge'
```
**Solution**: Verify bridging header is correctly configured and framework is embedded

### Debug Steps
1. **Check Framework Structure**: `find GodotBridge.xcframework -name "*.h"`
2. **Verify Linking**: Check Build Phases for proper framework inclusion
3. **Clean Build**: Remove derived data and rebuild
4. **Module Map**: Verify `module.modulemap` is properly generated

## Performance Considerations

### Metal Rendering
- **Direct Layer Access**: Framework provides direct access to Godot's Metal layer
- **Frame Synchronization**: Proper display link setup for smooth rendering
- **Memory Management**: Efficient handling of Metal resources

### Threading
- **Main Thread**: UI operations and Swift interface on main thread
- **Godot Thread**: Engine operations on dedicated thread
- **Synchronization**: Proper dispatch queue management for cross-thread communication

## Future Improvements

### Planned Features
- **Swift Package Manager**: SPM support for easier distribution
- **Communication Layer**: Enhanced bidirectional messaging system
- **Debug Tools**: Built-in debugging and profiling capabilities
- **Asset Pipeline**: Streamlined asset loading and management

### Platform Expansion
- **iOS Simulator**: Dedicated simulator support
- **tvOS**: Apple TV support
- **watchOS**: Apple Watch integration (limited scope)

## Contributing

### Development Setup
1. Clone the repository
2. Open `GodotBridge.xcodeproj`
3. Configure libgodot.xcframework dependency
4. Build and test on both platforms

### Testing
- **Unit Tests**: Framework functionality testing
- **Integration Tests**: Full app integration validation
- **Performance Tests**: Metal rendering and threading performance

## License

[Your License Here]

## Dependencies

- **libgodot.xcframework**: Godot Engine runtime
- **Metal Framework**: iOS/macOS rendering
- **Foundation**: Core Objective-C/Swift interoperability

---

**Note**: This framework design prioritizes stability and maintainability over convenience. The additional complexity of the XCFramework approach pays dividends in reduced compilation issues, better platform support, and cleaner project organization.