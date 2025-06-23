//
//  GodotBridge_macOS.h
//  GodotBridge_macOS
//
//  Created by Tyler Allen on 6/23/25.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <QuartzCore/QuartzCore.h>

#if TARGET_OS_IOS
    #import <UIKit/UIKit.h>
#elif TARGET_OS_OSX
    #import <Cocoa/Cocoa.h>
#endif

//! Project version number for GodotBridge_macOS.
FOUNDATION_EXPORT double GodotBridge_macOSVersionNumber;

//! Project version string for GodotBridge_macOS.
FOUNDATION_EXPORT const unsigned char GodotBridge_macOSVersionString[];

// Inline the GodotBridge class definition since the header isn't being included properly
@interface GodotBridge : NSObject

@property (class, nonatomic, readonly) GodotBridge *sharedBridge;

- (BOOL)initializeWithMetalLayer:(CAMetalLayer *)metalLayer error:(NSError **)error;
- (BOOL)startWithError:(NSError **)error;
- (void)stop;

@property (nonatomic, readonly) BOOL isInitialized;
@property (nonatomic, readonly) BOOL isRunning;
@property (nonatomic, readonly) CAMetalLayer *godotMetalLayer;

@end
