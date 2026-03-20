#!/usr/bin/env bash
set -euo pipefail

TARGET=""
ANGLE_DIR=""
OUTPUT_DIR=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --target)     TARGET="$2"; shift 2 ;;
        --angle-dir)  ANGLE_DIR="$2"; shift 2 ;;
        --output-dir) OUTPUT_DIR="$2"; shift 2 ;;
        *) echo "Unknown argument: $1"; exit 1 ;;
    esac
done

if [[ -z "$TARGET" || -z "$ANGLE_DIR" || -z "$OUTPUT_DIR" ]]; then
    echo "Usage: collect-artifacts.sh --target <target> --angle-dir <dir> --output-dir <dir>"
    exit 1
fi

ANGLE_DIR="$(cd "$ANGLE_DIR" && pwd)"
mkdir -p "$OUTPUT_DIR"
OUTPUT_DIR="$(cd "$OUTPUT_DIR" && pwd)"

BUILD_DIR="$ANGLE_DIR/out/$TARGET"
STAGING_DIR="$OUTPUT_DIR/staging-$TARGET"

echo "=== Collecting artifacts for $TARGET ==="

rm -rf "$STAGING_DIR"
mkdir -p "$STAGING_DIR/lib"
mkdir -p "$STAGING_DIR/include"

# Determine platform from target name
PLATFORM="${TARGET%%-*}"

# Copy built libraries
case "$PLATFORM" in
    macos)
        cp "$BUILD_DIR/libEGL.dylib" "$STAGING_DIR/lib/"
        cp "$BUILD_DIR/libGLESv2.dylib" "$STAGING_DIR/lib/"
        # Fix install names for relocatable linking
        install_name_tool -id "@rpath/libEGL.dylib" "$STAGING_DIR/lib/libEGL.dylib"
        install_name_tool -id "@rpath/libGLESv2.dylib" "$STAGING_DIR/lib/libGLESv2.dylib"
        # Fix cross-references
        install_name_tool -change "./libEGL.dylib" "@rpath/libEGL.dylib" "$STAGING_DIR/lib/libGLESv2.dylib"
        install_name_tool -change "./libGLESv2.dylib" "@rpath/libGLESv2.dylib" "$STAGING_DIR/lib/libEGL.dylib"
        ;;
    linux)
        cp "$BUILD_DIR/libEGL.so" "$STAGING_DIR/lib/"
        cp "$BUILD_DIR/libGLESv2.so" "$STAGING_DIR/lib/"
        ;;
    windows)
        cp "$BUILD_DIR/libEGL.dll" "$STAGING_DIR/lib/"
        cp "$BUILD_DIR/libGLESv2.dll" "$STAGING_DIR/lib/"
        cp "$BUILD_DIR/libEGL.dll.lib" "$STAGING_DIR/lib/"
        cp "$BUILD_DIR/libGLESv2.dll.lib" "$STAGING_DIR/lib/"
        ;;
    android)
        # Android ANGLE outputs have _angle suffix
        cp "$BUILD_DIR/libEGL_angle.so" "$STAGING_DIR/lib/libEGL.so"
        cp "$BUILD_DIR/libGLESv2_angle.so" "$STAGING_DIR/lib/libGLESv2.so"
        ;;
    ios)
        cp "$BUILD_DIR/libEGL.a" "$STAGING_DIR/lib/"
        cp "$BUILD_DIR/libGLESv2.a" "$STAGING_DIR/lib/"
        ;;
    *)
        echo "Error: Unknown platform '$PLATFORM' from target '$TARGET'"
        exit 1
        ;;
esac

# Copy EGL and GLES headers
if [[ -d "$ANGLE_DIR/include/EGL" ]]; then
    cp -r "$ANGLE_DIR/include/EGL" "$STAGING_DIR/include/"
fi
if [[ -d "$ANGLE_DIR/include/GLES2" ]]; then
    cp -r "$ANGLE_DIR/include/GLES2" "$STAGING_DIR/include/"
fi
if [[ -d "$ANGLE_DIR/include/GLES3" ]]; then
    cp -r "$ANGLE_DIR/include/GLES3" "$STAGING_DIR/include/"
fi
if [[ -d "$ANGLE_DIR/include/KHR" ]]; then
    cp -r "$ANGLE_DIR/include/KHR" "$STAGING_DIR/include/"
fi

# Package as tar.gz
ARCHIVE_NAME="angle-$TARGET.tar.gz"
echo "  Creating $ARCHIVE_NAME"
tar -czf "$OUTPUT_DIR/$ARCHIVE_NAME" -C "$STAGING_DIR" .

# Clean up staging
rm -rf "$STAGING_DIR"

echo "=== Artifact ready: $OUTPUT_DIR/$ARCHIVE_NAME ==="
