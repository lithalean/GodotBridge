//
//  GodotBridge.h
//  GodotBridge
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

NS_ASSUME_NONNULL_BEGIN

// MARK: - Objective-C Bridge Class (Public Interface)
@interface GodotBridge : NSObject

// Class property for Swift access
@property (class, nonatomic, readonly) GodotBridge *sharedBridge;

// Instance methods
- (BOOL)initializeWithMetalLayer:(CAMetalLayer *)metalLayer error:(NSError **)error;
- (BOOL)startWithError:(NSError **)error;
- (void)stop;

// Properties
@property (nonatomic, readonly) BOOL isInitialized;
@property (nonatomic, readonly) BOOL isRunning;
@property (nonatomic, readonly, nullable) CAMetalLayer *godotMetalLayer;

@end

NS_ASSUME_NONNULL_END
