#!/bin/bash

# Debug: Print all environment variables to understand the build context
echo "=== Build Environment Debug ==="
echo "ACTION: ${ACTION}"
echo "CONFIGURATION: ${CONFIGURATION}"
echo "PRODUCT_NAME: ${PRODUCT_NAME}"
echo "BUILT_PRODUCTS_DIR: ${BUILT_PRODUCTS_DIR}"
echo "TARGET_BUILD_DIR: ${TARGET_BUILD_DIR}"
echo "INSTALL_PATH: ${INSTALL_PATH}"
echo "ARCHIVE_PRODUCTS_PATH: ${ARCHIVE_PRODUCTS_PATH}"
echo "SRCROOT: ${SRCROOT}"

# Determine the correct framework path based on build action
if [ "${ACTION}" = "install" ]; then
	# Archive/Install build
	FRAMEWORK_PATH="${TARGET_BUILD_DIR}/${PRODUCT_NAME}.framework"
else
	# Regular build
	FRAMEWORK_PATH="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.framework"
fi

echo "Using FRAMEWORK_PATH: ${FRAMEWORK_PATH}"

# Check if framework exists
if [ ! -d "${FRAMEWORK_PATH}" ]; then
	echo "WARNING: Framework not found at ${FRAMEWORK_PATH}"
	echo "Trying alternate path..."
	FRAMEWORK_PATH="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.framework"
	echo "Trying: ${FRAMEWORK_PATH}"
fi

# Create Modules directory
mkdir -p "${FRAMEWORK_PATH}/Modules"

# Determine which modulemap to use
if [[ "${PRODUCT_NAME}" == *"iOS"* ]]; then
	MODULEMAP_FILE="GodotBridge_iOS.modulemap"
else
	MODULEMAP_FILE="GodotBridge_macOS.modulemap"
fi

echo "Looking for modulemap: ${SRCROOT}/${MODULEMAP_FILE}"

# Copy module map
if [ -f "${SRCROOT}/${MODULEMAP_FILE}" ]; then
	cp "${SRCROOT}/${MODULEMAP_FILE}" "${FRAMEWORK_PATH}/Modules/module.modulemap"
	echo "✅ Successfully copied ${MODULEMAP_FILE} to ${FRAMEWORK_PATH}/Modules/module.modulemap"
else
	echo "❌ ERROR: ${MODULEMAP_FILE} not found at ${SRCROOT}"
	echo "Contents of ${SRCROOT}:"
	ls -la "${SRCROOT}"
	exit 1
fi
