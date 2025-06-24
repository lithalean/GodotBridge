#!/bin/bash

# Create output directory for logs
LOG_DIR="build_logs_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$LOG_DIR"

# Define log files
SUMMARY_LOG="$LOG_DIR/00_summary.md"
ERRORS_LOG="$LOG_DIR/01_errors_only.md"
IOS_BUILD_LOG="$LOG_DIR/02_ios_build.md"
MACOS_BUILD_LOG="$LOG_DIR/03_macos_build.md"
VERIFICATION_LOG="$LOG_DIR/05_verification.md"
FULL_LOG="$LOG_DIR/99_full_build.log"

# Function to log to specific file
log_to() {
    local file="$1"
    shift
    echo "$@" | tee -a "$file"
}

# Function to log to summary and full log
log() {
    echo "$1" | tee -a "$SUMMARY_LOG" | tee -a "$FULL_LOG"
}

# Function to log errors
log_error() {
    local message="$1"
    echo "$message" | tee -a "$ERRORS_LOG" | tee -a "$FULL_LOG"
    echo "$message" >> "$SUMMARY_LOG"
}

# Initialize summary
cat > "$SUMMARY_LOG" << EOF
# GodotBridge ARM64 Build Summary
**Date**: $(date)
**Directory**: $(pwd)
EOF

###
# Build iOS Archive
###
log "==> Building iOS Archive..."
xcodebuild archive     -project GodotBridge.xcodeproj     -scheme GodotBridge_iOS     -destination "generic/platform=iOS"     -archivePath build/GodotBridge_iOS.xcarchive     SKIP_INSTALL=NO     BUILD_LIBRARY_FOR_DISTRIBUTION=YES     DEFINES_MODULE=NO     ARCHS=arm64     VALID_ARCHS=arm64     2>&1 | tee "$IOS_BUILD_LOG"

###
# Build macOS Archive
###
log "==> Building macOS Archive..."
xcodebuild archive     -project GodotBridge.xcodeproj     -scheme GodotBridge_macOS     -destination "generic/platform=macOS"     -archivePath build/GodotBridge_macOS.xcarchive     SKIP_INSTALL=NO     BUILD_LIBRARY_FOR_DISTRIBUTION=YES     DEFINES_MODULE=NO     ARCHS=arm64     VALID_ARCHS=arm64     EXCLUDED_ARCHS=x86_64     2>&1 | tee "$MACOS_BUILD_LOG"

###
# Locate iOS Framework
###
log "==> Locating iOS framework after archive..."
IOS_FRAMEWORK_PATH=$(find build/GodotBridge_iOS.xcarchive -name "GodotBridge_iOS.framework" -type d | head -n 1)

if [ -z "$IOS_FRAMEWORK_PATH" ]; then
    log_error "ERROR: Could not find iOS framework after archive."
    exit 1
else
    log "Found iOS framework at: $IOS_FRAMEWORK_PATH"
fi

###
# Define macOS framework path
###
MACOS_FRAMEWORK_PATH="build/GodotBridge_macOS.xcarchive/Products/Library/Frameworks/GodotBridge_macOS.framework"

if [ ! -d "$MACOS_FRAMEWORK_PATH" ]; then
    log_error "ERROR: Could not find macOS framework at expected path."
    exit 1
else
    log "Found macOS framework at: $MACOS_FRAMEWORK_PATH"
fi

###
# Stop here — user will run prepare_xcframework manually
###
log "==> Ready to prepare XCFramework — run prepare_xcframework_v1.sh next."

