#!/bin/bash

# Script to fix the "Unknown build action 'DEBUGGER_ENABLED'" error
# This script properly formats the build flags for xcodebuild

echo "=== Building in Debug Mode with Properly Formatted Flags ==="
echo "Custom debugger has been enabled"

# Use xcodebuild with proper flags format
xcodebuild \
  -project 'backdoor.xcodeproj' \
  -scheme 'backdoor (Debug)' \
  -configuration Debug \
  -arch arm64 -sdk iphoneos \
  SWIFT_ACTIVE_COMPILATION_CONDITIONS="DEBUG DEBUGGER_ENABLED" \
  OTHER_SWIFT_FLAGS="-DDEBUG=1" \
  SWIFT_OPTIMIZATION_LEVEL="-Onone" \
  SWIFT_COMPILATION_MODE="singlefile" \
  GCC_PREPROCESSOR_DEFINITIONS="DEBUG=1 DEBUGGER_ENABLED=1" \
  GCC_OPTIMIZATION_LEVEL=0 \
  COPY_PHASE_STRIP=NO \
  ENABLE_TESTABILITY=YES \
  INCLUDE_DEBUGGER=YES \
  ENABLE_ENHANCED_LOGGING=YES \
  VERBOSE_LOGGING=YES

echo "Build completed!"
