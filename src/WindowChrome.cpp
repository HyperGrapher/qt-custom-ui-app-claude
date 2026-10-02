#include "WindowChrome.h"

#include <QQuickWindow>

#include "PlatformWindow.h"

WindowChrome::WindowChrome(bool translucencyAllowed, QObject *parent)
    : QObject(parent)
    , m_translucent(translucencyAllowed && PlatformWindow::supportsTranslucentWindows())
{
    if (m_translucent) {
        QQuickWindow::setDefaultAlphaBuffer(true);
    }
}

void WindowChrome::attach(QWindow &window)
{
    if (m_translucent) {
        return;
    }
    const bool rounded = PlatformWindow::requestNativeRoundedCorners(window);
    if (rounded != m_nativeRoundedCorners) {
        m_nativeRoundedCorners = rounded;
        emit nativeRoundedCornersChanged();
    }
}
