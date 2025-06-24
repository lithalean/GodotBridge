#!/bin/bash

# Debug print
echo "CONFIGURATION=${CONFIGURATION}"
echo "ACTION=${ACTION}"
echo "PRODUCT_NAME=${PRODUCT_NAME}"
echo "BUILT_PRODUCTS_DIR=${BUILT_PRODUCTS_DIR}"
echo "TARGET_BUILD_DIR=${TARGET_BUILD_DIR}"
echo "SRCROOT=${SRCROOT}"

# Determine FRAMEWORK_PATH
if [ "${ACTION}" = "install" ]; then
    FRAMEWORK_PATH="${TARGET_BUILD_DIR}/${PRODUCT_NAME}.framework"
else
    FRAMEWORK_PATH="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.framework"
fi

echo "Resolved FRAMEWORK_PATH=${FRAMEWORK_PATH}"

# Check if framework exists
if [ ! -d "${FRAMEWORK_PATH}" ]; then
    echo "ERROR: Framework not found at ${FRAMEWORK_PATH}"
    exit 1
fi

# Create Modules dir
mkdir -p "${FRAMEWORK_PATH}/Modules"


# Copy modulemap for macOS
MODULEMAP_FILE="GodotBridge_macOS.modulemap"
echo "Looking for modulemap: ${SRCROOT}/${MODULEMAP_FILE}"

if [ -f "${SRCROOT}/${MODULEMAP_FILE}" ]; then
    cp "${SRCROOT}/${MODULEMAP_FILE}" "${FRAMEWORK_PATH}/Modules/module.modulemap"
    echo "✅ Copied ${MODULEMAP_FILE} to Modules"
else
    echo "❌ ERROR: Missing ${SRCROOT}/${MODULEMAP_FILE}"
    exit 1
fi
