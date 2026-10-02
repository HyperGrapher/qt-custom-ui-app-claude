#pragma once

#include <QElapsedTimer>
#include <QObject>
#include <QTimer>
#include <QtQml/qqmlregistration.h>

// The single time source for all ambient (decorative, endless) motion.
//
// It lives in C++ on purpose: a QML Timer or animation runs on Qt Quick's animation driver,
// which keeps the window rendering at full display rate. A plain QTimer changes "time" only
// frameRate times per second, so when nothing else moves, the window renders at that rate.
// When stopped, nothing ticks and the window renders no frames at all.
class AmbientClock : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(bool running READ isRunning WRITE setRunning NOTIFY runningChanged)
    Q_PROPERTY(double speed READ speed WRITE setSpeed NOTIFY speedChanged)
    Q_PROPERTY(int frameRate READ frameRate WRITE setFrameRate NOTIFY frameRateChanged)
    Q_PROPERTY(double time READ time NOTIFY timeChanged)

public:
    // A start offset avoids the symmetric look all sine paths have at t = 0.
    static constexpr double kStartTime = 42.0;

    explicit AmbientClock(QObject *parent = nullptr);

    [[nodiscard]] bool isRunning() const { return m_ticker.isActive(); }
    void setRunning(bool running);

    [[nodiscard]] double speed() const { return m_speed; }
    void setSpeed(double speed);

    [[nodiscard]] int frameRate() const { return m_frameRate; }
    void setFrameRate(int frameRate);

    [[nodiscard]] double time() const { return m_time; }

signals:
    void runningChanged();
    void speedChanged();
    void frameRateChanged();
    void timeChanged();

private:
    void tick();

    QTimer m_ticker;
    QElapsedTimer m_tickClock;
    double m_speed = 1.0;
    int m_frameRate = 30;
    double m_time = kStartTime;
};
