#!/usr/bin/env bash
set -euo pipefail

TARGET=""
ANGLE_DIR=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --target)    TARGET="$2"; shift 2 ;;
        --angle-dir) ANGLE_DIR="$2"; shift 2 ;;
        *) echo "Unknown argument: $1"; exit 1 ;;
    esac
done

if [[ -z "$TARGET" || -z "$ANGLE_DIR" ]]; then
    echo "Usage: build-angle.sh --target <target> --angle-dir <dir>"
    echo "  Targets: macos-x86_64, macos-aarch64, linux-x86_64, linux-aarch64,"
    echo "           windows-x86_64, windows-aarch64, android-arm64, android-arm32,"
    echo "           android-x86_64, ios-arm64"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
GN_ARGS_FILE="$REPO_ROOT/scripts/gn-args/$TARGET.gn"

if [[ ! -f "$GN_ARGS_FILE" ]]; then
    echo "Error: GN args file not found: $GN_ARGS_FILE"
    exit 1
fi

ANGLE_DIR="$(cd "$ANGLE_DIR" && pwd)"
OUT_DIR="$ANGLE_DIR/out/$TARGET"

echo "=== Building ANGLE for $TARGET ==="
echo "  ANGLE dir: $ANGLE_DIR"
echo "  Output:    $OUT_DIR"
echo "  GN args:   $GN_ARGS_FILE"

# Read GN args, joining lines with spaces
GN_ARGS=$(tr '\n' ' ' < "$GN_ARGS_FILE")

cd "$ANGLE_DIR"

# Generate build files
gn gen "$OUT_DIR" --args="$GN_ARGS"

# Build ANGLE libraries
if [[ "$TARGET" == ios-* ]]; then
    # iOS builds static libraries
    autoninja -C "$OUT_DIR" libEGL_static libGLESv2_static
else
    autoninja -C "$OUT_DIR" libEGL libGLESv2
fi

echo "=== Build complete for $TARGET ==="
