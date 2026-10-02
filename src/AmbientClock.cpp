#include "AmbientClock.h"

#include <algorithm>

namespace {

// Long pauses (a stalled event loop, a debugger) would otherwise make the motion jump.
constexpr double kMaxStepSeconds = 0.1;

} // namespace

AmbientClock::AmbientClock(QObject *parent)
    : QObject(parent)
{
    m_ticker.setTimerType(Qt::PreciseTimer);
    m_ticker.setInterval(1000 / m_frameRate);
    connect(&m_ticker, &QTimer::timeout, this, &AmbientClock::tick);
}

void AmbientClock::setRunning(bool running)
{
    if (isRunning() == running) {
        return;
    }
    if (running) {
        m_tickClock.start();
        m_ticker.start();
    } else {
        m_ticker.stop();
    }
    emit runningChanged();
}

void AmbientClock::setSpeed(double speed)
{
    if (qFuzzyCompare(m_speed, speed)) {
        return;
    }
    m_speed = speed;
    emit speedChanged();
}

void AmbientClock::setFrameRate(int frameRate)
{
    const int clamped = std::clamp(frameRate, 1, 240);
    if (m_frameRate == clamped) {
        return;
    }
    m_frameRate = clamped;
    m_ticker.setInterval(1000 / m_frameRate);
    emit frameRateChanged();
}

void AmbientClock::tick()
{
    // Advance by real elapsed time, so the motion speed does not depend on timer accuracy.
    const double elapsedSeconds = static_cast<double>(m_tickClock.restart()) / 1000.0;
    m_time += std::min(elapsedSeconds, kMaxStepSeconds) * m_speed;
    emit timeChanged();
}
