#pragma once

#include <QObject>
#include <QtQml/qqmlregistration.h>

class QWindow;

// Tells the QML window shell how the frameless window should look on this platform:
// either a transparent surface with app-drawn rounded corners and shadow, or an opaque
// surface whose corners are rounded by the OS (Windows 11) or left square.
class WindowChrome : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("WindowChrome is created by the application.")

    Q_PROPERTY(bool translucent READ isTranslucent CONSTANT)
    Q_PROPERTY(
        bool nativeRoundedCorners READ hasNativeRoundedCorners NOTIFY nativeRoundedCornersChanged)

public:
    // Must be created before the first window, because translucency is a surface format
    // decision.
    explicit WindowChrome(bool translucencyAllowed, QObject *parent = nullptr);

    [[nodiscard]] bool isTranslucent() const { return m_translucent; }
    [[nodiscard]] bool hasNativeRoundedCorners() const { return m_nativeRoundedCorners; }

    void attach(QWindow &window);

signals:
    void nativeRoundedCornersChanged();

private:
    const bool m_translucent;
    bool m_nativeRoundedCorners = false;
};
