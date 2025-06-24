//
//  GodotBridge_Private.h
//  GodotBridge (Internal use only)
//
//  Created by Tyler Allen on 6/23/25.
//

#import "GodotBridge.h"

#ifdef __cplusplus
extern "C" {
#endif

// Bridge Handle Type
typedef struct GodotBridgeImpl* GodotBridgeHandle;

// C Bridge Functions (for Swift interop)
GodotBridgeHandle godot_bridge_create(void);
int godot_bridge_initialize(GodotBridgeHandle bridge, void* metal_layer);
void godot_bridge_iteration(GodotBridgeHandle bridge);
void godot_bridge_shutdown(GodotBridgeHandle bridge);
void godot_bridge_destroy(GodotBridgeHandle bridge);

#ifdef __cplusplus
}
#endif
