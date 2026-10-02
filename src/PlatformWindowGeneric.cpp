#include "PlatformWindow.h"

#include <QGuiApplication>

namespace PlatformWindow {

bool supportsTranslucentWindows()
{
    // Wayland compositors always support alpha. X11 needs a compositing window manager;
    // without one the corners show black, and --no-translucency is the documented way out.
    const QString platform = QGuiApplication::platformName();
    return platform.startsWith(QLatin1String("wayland")) || platform == QLatin1String("xcb");
}

bool requestNativeRoundedCorners(QWindow &)
{
    return false;
}

} // namespace PlatformWindow
