#pragma once

#include <QElapsedTimer>
#include <QMetaObject>
#include <QObject>
#include <QPointer>
#include <QQuickWindow>
#include <QtQml/qqmlregistration.h>

// Counts presented frames of a window for the performance overlay. It is only connected
// while active, so it costs nothing when the overlay is hidden. The frame counter also shows
// when rendering stops entirely (it stays still), which is how idle behavior is verified.
class FrameStats : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QQuickWindow *window READ window WRITE setWindow NOTIFY windowChanged)
    Q_PROPERTY(bool active READ isActive WRITE setActive NOTIFY activeChanged)
    Q_PROPERTY(double framesPerSecond READ framesPerSecond NOTIFY statsChanged)
    Q_PROPERTY(double averageFrameMs READ averageFrameMs NOTIFY statsChanged)
    Q_PROPERTY(double worstFrameMs READ worstFrameMs NOTIFY statsChanged)
    Q_PROPERTY(qint64 totalFrames READ totalFrames NOTIFY statsChanged)

public:
    explicit FrameStats(QObject *parent = nullptr);

    [[nodiscard]] QQuickWindow *window() const { return m_window; }
    void setWindow(QQuickWindow *window);

    [[nodiscard]] bool isActive() const { return m_active; }
    void setActive(bool active);

    [[nodiscard]] double framesPerSecond() const { return m_framesPerSecond; }
    [[nodiscard]] double averageFrameMs() const { return m_averageFrameMs; }
    [[nodiscard]] double worstFrameMs() const { return m_worstFrameMs; }
    [[nodiscard]] qint64 totalFrames() const { return m_totalFrames; }

signals:
    void windowChanged();
    void activeChanged();
    void statsChanged();

private:
    void reconnect();
    void onFrameSwapped();
    void publish(qint64 sampleMs);

    QPointer<QQuickWindow> m_window;
    QMetaObject::Connection m_frameConnection;
    QElapsedTimer m_sampleClock;
    QElapsedTimer m_frameClock;
    bool m_active = false;
    int m_framesInSample = 0;
    qint64 m_worstInSampleMs = 0;
    double m_framesPerSecond = 0.0;
    double m_averageFrameMs = 0.0;
    double m_worstFrameMs = 0.0;
    qint64 m_totalFrames = 0;
};
