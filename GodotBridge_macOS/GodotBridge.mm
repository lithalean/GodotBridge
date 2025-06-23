//
//  GodotBridge.mm
//  GodotBridge
//
//  Created by Tyler Allen on 6/23/25.
//

#import "GodotBridge.h"
#import "GodotBridge_Private.h"

// Platform-specific imports
#if TARGET_OS_IOS
    #import <UIKit/UIKit.h>
#elif TARGET_OS_OSX
    #import <Cocoa/Cocoa.h>
#endif

#import <Metal/Metal.h>
#import <QuartzCore/QuartzCore.h>

// MARK: - Bridge Implementation Structure
struct GodotBridgeImpl {
    CAMetalLayer *metalLayer;
    id<MTLDevice> metalDevice;
    BOOL initialized;
    BOOL running;
};

// MARK: - Private Interface
@interface GodotBridge ()
@property (nonatomic, strong) CAMetalLayer *internalMetalLayer;
@property (nonatomic, assign) BOOL internalInitialized;
@property (nonatomic, assign) BOOL internalRunning;
@end

// MARK: - Implementation
@implementation GodotBridge {
    struct GodotBridgeImpl *_impl;
}

// MARK: - Class Property Implementation
+ (GodotBridge *)sharedBridge {
    static GodotBridge *_sharedBridge = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedBridge = [[GodotBridge alloc] init];
    });
    return _sharedBridge;
}

// MARK: - Initialization
- (instancetype)init {
    self = [super init];
    if (self) {
        _impl = (struct GodotBridgeImpl *)calloc(1, sizeof(struct GodotBridgeImpl));
        _impl->initialized = NO;
        _impl->running = NO;
        
        self.internalInitialized = NO;
        self.internalRunning = NO;
        
        NSLog(@"🎮 GodotBridge: Instance created");
    }
    return self;
}

- (void)dealloc {
    [self stop];
    if (_impl) {
        free(_impl);
        _impl = NULL;
    }
    NSLog(@"🎮 GodotBridge: Instance deallocated");
}

// MARK: - Public Methods
- (BOOL)initializeWithMetalLayer:(CAMetalLayer *)metalLayer error:(NSError **)error {
    if (self.internalInitialized) {
        NSLog(@"🎮 GodotBridge: Already initialized");
        return YES;
    }
    
    if (!metalLayer) {
        NSLog(@"❌ GodotBridge: Metal layer is required");
        if (error) {
            *error = [NSError errorWithDomain:@"GodotBridge"
                                         code:1001
                                     userInfo:@{NSLocalizedDescriptionKey: @"Metal layer is required"}];
        }
        return NO;
    }
    
    NSLog(@"🚀 GodotBridge: Starting initialization...");
    
    @try {
        // Store the metal layer
        self.internalMetalLayer = metalLayer;
        _impl->metalLayer = metalLayer;
        _impl->metalDevice = metalLayer.device;
        
        // Ensure Metal device exists
        if (!_impl->metalDevice) {
            _impl->metalDevice = MTLCreateSystemDefaultDevice();
            metalLayer.device = _impl->metalDevice;
        }
        
        // Configure Metal layer for Godot
        metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
        metalLayer.framebufferOnly = NO;
        
        #if TARGET_OS_IOS
            NSLog(@"🍎 GodotBridge: iOS platform initialization");
        #elif TARGET_OS_OSX
            NSLog(@"💻 GodotBridge: macOS platform initialization");
            metalLayer.displaySyncEnabled = YES;
        #endif
        
        // Mark as initialized
        _impl->initialized = YES;
        self.internalInitialized = YES;
        
        NSLog(@"✅ GodotBridge: Initialization successful");
        return YES;
        
    } @catch (NSException *exception) {
        NSLog(@"❌ GodotBridge: Exception during initialization: %@", exception);
        if (error) {
            *error = [NSError errorWithDomain:@"GodotBridge"
                                         code:1002
                                     userInfo:@{NSLocalizedDescriptionKey: exception.reason ?: @"Unknown error"}];
        }
        return NO;
    }
}

- (BOOL)startWithError:(NSError **)error {
    if (!self.internalInitialized) {
        NSLog(@"❌ GodotBridge: Cannot start - not initialized");
        if (error) {
            *error = [NSError errorWithDomain:@"GodotBridge"
                                         code:1003
                                     userInfo:@{NSLocalizedDescriptionKey: @"Bridge not initialized"}];
        }
        return NO;
    }
    
    if (self.internalRunning) {
        NSLog(@"🎮 GodotBridge: Already running");
        return YES;
    }
    
    NSLog(@"▶️ GodotBridge: Starting engine...");
    
    @try {
        // Start the engine
        _impl->running = YES;
        self.internalRunning = YES;
        
        NSLog(@"✅ GodotBridge: Engine started successfully");
        return YES;
        
    } @catch (NSException *exception) {
        NSLog(@"❌ GodotBridge: Exception during start: %@", exception);
        if (error) {
            *error = [NSError errorWithDomain:@"GodotBridge"
                                         code:1004
                                     userInfo:@{NSLocalizedDescriptionKey: exception.reason ?: @"Unknown error"}];
        }
        return NO;
    }
}

- (void)stop {
    if (!self.internalRunning) {
        NSLog(@"🎮 GodotBridge: Already stopped");
        return;
    }
    
    NSLog(@"⏹️ GodotBridge: Stopping engine...");
    
    @try {
        _impl->running = NO;
        self.internalRunning = NO;
        
        NSLog(@"✅ GodotBridge: Engine stopped");
        
    } @catch (NSException *exception) {
        NSLog(@"❌ GodotBridge: Exception during stop: %@", exception);
    }
}

// MARK: - Properties
- (BOOL)isInitialized {
    return self.internalInitialized;
}

- (BOOL)isRunning {
    return self.internalRunning;
}

- (CAMetalLayer *)godotMetalLayer {
    return self.internalMetalLayer;
}

@end

// MARK: - C Interface Functions for Swift
extern "C" {
    
    GodotBridgeHandle godot_bridge_create(void) {
        GodotBridge *bridge = [GodotBridge sharedBridge];
        return (__bridge_retained GodotBridgeHandle)bridge;
    }
    
    int godot_bridge_initialize(GodotBridgeHandle bridge, void *metal_layer) {
        if (!bridge || !metal_layer) {
            NSLog(@"❌ C Bridge: Invalid parameters");
            return -1;
        }
        
        GodotBridge *objcBridge = (__bridge GodotBridge *)bridge;
        CAMetalLayer *layer = (__bridge CAMetalLayer *)metal_layer;
        
        NSError *error;
        BOOL success = [objcBridge initializeWithMetalLayer:layer error:&error];
        
        if (!success && error) {
            NSLog(@"❌ C Bridge: Initialize failed: %@", error.localizedDescription);
        }
        
        return success ? 0 : -1;
    }
    
    void godot_bridge_iteration(GodotBridgeHandle bridge) {
        if (!bridge) return;
        
        GodotBridge *objcBridge = (__bridge GodotBridge *)bridge;
        if (objcBridge.isRunning) {
            // Perform one iteration of the main loop
            // For now, this is a no-op since we're using stubs
        }
    }
    
    void godot_bridge_shutdown(GodotBridgeHandle bridge) {
        if (!bridge) return;
        
        GodotBridge *objcBridge = (__bridge GodotBridge *)bridge;
        [objcBridge stop];
    }
    
    void godot_bridge_destroy(GodotBridgeHandle bridge) {
        if (!bridge) return;
        
        GodotBridge *objcBridge = (__bridge_transfer GodotBridge *)bridge;
        [objcBridge stop];
        // ARC will handle cleanup
    }
}
