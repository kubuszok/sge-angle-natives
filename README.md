# sge-angle-natives

Pre-built [ANGLE](https://chromium.googlesource.com/angle/angle) (Almost Native Graphics Layer Engine) binaries for the [SGE](https://github.com/ArcticLampyrid/sge-porting) (Scala Game Engine) project.

ANGLE translates OpenGL ES calls to the platform's native graphics API (Metal on macOS/iOS, Vulkan on Linux, D3D11/Vulkan on Windows, native on Android), providing a consistent GL ES implementation across all targets.

## Platforms

This repository builds ANGLE from source via GitHub Actions and produces pre-built binaries for **10 targets**:

| Platform | Architectures | Graphics Backend |
|----------|---------------|------------------|
| macOS    | x86_64, aarch64 | Metal |
| Linux    | x86_64, aarch64 | Vulkan |
| Windows  | x86_64, aarch64 | D3D11 + Vulkan |
| Android  | arm64, arm32, x86_64 | Native GLES |
| iOS      | arm64 (static) | Metal |

## Triggering a Build

Builds are triggered via `workflow_dispatch` on the **Build ANGLE** workflow:

1. Go to **Actions** > **Build ANGLE** > **Run workflow**
2. Enter the ANGLE branch to build (e.g., `chromium/7151`)
3. Click **Run workflow**

Alternatively, push a tag matching `chromium-*` (e.g., `chromium-7151`) to trigger a build and create a GitHub Release automatically.

## Downloading Binaries

Pre-built binaries are available from [GitHub Releases](../../releases), tagged by ANGLE version (e.g., `chromium-7151`).

Each release contains platform-specific `.tar.gz` archives:

```
angle-macos-aarch64.tar.gz
angle-macos-x86_64.tar.gz
angle-linux-x86_64.tar.gz
angle-linux-aarch64.tar.gz
angle-windows-x86_64.tar.gz
angle-windows-aarch64.tar.gz
angle-android-arm64.tar.gz
angle-android-arm32.tar.gz
angle-android-x86_64.tar.gz
angle-ios-arm64.tar.gz
```

Each archive contains:
- Shared libraries (`.dylib` / `.so` / `.dll`) or static libraries (`.a` for iOS)
- Import libraries (`.dll.lib` for Windows)
- EGL and GLES headers

## License

ANGLE is licensed under the BSD 3-Clause License. See [LICENSE](LICENSE) for details.
