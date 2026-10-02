#pragma once

class QWindow;

// Narrow interface to platform-specific window behavior. Each platform provides its own
// implementation file; CMake picks the right one.
namespace PlatformWindow {

// True when the platform can show a per-pixel transparent window, so the app can draw its
// own antialiased rounded corners and soft shadow.
[[nodiscard]] bool supportsTranslucentWindows();

// Asks the window manager to round the window corners itself. Returns false when the
// platform has no such feature (for example Windows 10 or Linux).
[[nodiscard]] bool requestNativeRoundedCorners(QWindow &window);

} // namespace PlatformWindow
