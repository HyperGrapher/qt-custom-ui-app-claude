#include "PlatformWindow.h"

#include <QWindow>

// windows.h must come first: dwmapi.h relies on its types.
#include <windows.h>

#include <dwmapi.h>

namespace PlatformWindow {

bool supportsTranslucentWindows()
{
    // Windows uses native DWM corners (Windows 11) or square corners (Windows 10) instead of
    // a transparent surface, which keeps the default Direct3D path simple and fast.
    return false;
}

bool requestNativeRoundedCorners(QWindow &window)
{
    // Values from the Windows 11 SDK, defined here so older SDKs (such as MinGW's) build.
    constexpr DWORD kWindowCornerPreference = 33; // DWMWA_WINDOW_CORNER_PREFERENCE
    constexpr DWORD kCornerRound = 2;             // DWMWCP_ROUND

    const auto handle = reinterpret_cast<HWND>(window.winId());
    // Windows 10 does not know this attribute and returns an error, which means "no".
    const HRESULT result =
        DwmSetWindowAttribute(handle, kWindowCornerPreference, &kCornerRound, sizeof(kCornerRound));
    return SUCCEEDED(result);
}

} // namespace PlatformWindow
