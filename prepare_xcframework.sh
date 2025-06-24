#!/bin/bash

echo "==> Preparing XCFramework — creating + adding manual modulemap..."

XCFRAMEWORK_PATH="./build/GodotBridge.xcframework"

# Paths to framework slices
IOS_FRAMEWORK_PATH="build/GodotBridge_iOS.xcarchive/Products/Library/Frameworks/GodotBridge_iOS.framework"
MACOS_FRAMEWORK_PATH="build/GodotBridge_macOS.xcarchive/Products/Library/Frameworks/GodotBridge_macOS.framework"

# Step 1 — Create XCFramework
echo "==> Running xcodebuild -create-xcframework..."
xcodebuild -create-xcframework     -framework "$IOS_FRAMEWORK_PATH"     -framework "$MACOS_FRAMEWORK_PATH"     -output "$XCFRAMEWORK_PATH"

if [ $? -ne 0 ]; then
    echo "❌ ERROR: Failed to create XCFramework."
    exit 1
fi

echo "✅ XCFramework created successfully at: $XCFRAMEWORK_PATH"

# Function to generate simple modulemap if missing
generate_modulemap() {
    local platform="$1"
    local name="$2"
    local mapfile="$3"

    if [ ! -f "$mapfile" ]; then
        echo "==> No ${mapfile} found — generating basic modulemap"
        cat > "$mapfile" << EOF
framework module ${name} {
    umbrella header "GodotBridge.h"
    export *
    module * { export * }
}
EOF
        echo "✅ Generated ${mapfile}"
    else
        echo "✅ Found existing ${mapfile}"
    fi
}

# Step 2 — Add modulemap to macOS slice
MACOS_MODULE_DIR="${XCFRAMEWORK_PATH}/macos-arm64/GodotBridge_macOS.framework/Modules"
mkdir -p "${MACOS_MODULE_DIR}"

generate_modulemap "macOS" "GodotBridge" "GodotBridge_macOS.modulemap"

cp GodotBridge_macOS.modulemap "${MACOS_MODULE_DIR}/module.modulemap"
echo "✅ Copied module.modulemap to macOS slice"

# Step 3 — Add modulemap to iOS slice
IOS_MODULE_DIR="${XCFRAMEWORK_PATH}/ios-arm64/GodotBridge_iOS.framework/Modules"
mkdir -p "${IOS_MODULE_DIR}"

generate_modulemap "iOS" "GodotBridge" "GodotBridge_iOS.modulemap"

cp GodotBridge_iOS.modulemap "${IOS_MODULE_DIR}/module.modulemap"
echo "✅ Copied module.modulemap to iOS slice"

echo "==> XCFramework now prepared — ready for import 🚀"
