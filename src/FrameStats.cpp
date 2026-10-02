#include "FrameStats.h"

#include <algorithm>

namespace {

constexpr qint64 kSampleWindowMs = 500;

} // namespace

FrameStats::FrameStats(QObject *parent)
    : QObject(parent)
{}

void FrameStats::setWindow(QQuickWindow *window)
{
    if (m_window == window) {
        return;
    }
    m_window = window;
    reconnect();
    emit windowChanged();
}

void FrameStats::setActive(bool active)
{
    if (m_active == active) {
        return;
    }
    m_active = active;
    reconnect();
    emit activeChanged();
}

void FrameStats::reconnect()
{
    disconnect(m_frameConnection);
    m_framesInSample = 0;
    m_worstInSampleMs = 0;
    m_frameClock.invalidate();
    if (!m_active || m_window.isNull()) {
        return;
    }
    // frameSwapped is emitted on the render thread; the queued connection measures
    // intervals on the GUI thread, which is accurate enough for an overlay.
    m_frameConnection = connect(m_window, &QQuickWindow::frameSwapped, this,
                                &FrameStats::onFrameSwapped, Qt::QueuedConnection);
    m_sampleClock.start();
}

void FrameStats::onFrameSwapped()
{
    ++m_totalFrames;
    ++m_framesInSample;
    if (m_frameClock.isValid()) {
        m_worstInSampleMs = std::max(m_worstInSampleMs, m_frameClock.restart());
    } else {
        m_frameClock.start();
    }

    const qint64 sampleMs = m_sampleClock.elapsed();
    if (sampleMs >= kSampleWindowMs) {
        publish(sampleMs);
    }
}

void FrameStats::publish(qint64 sampleMs)
{
    m_framesPerSecond = 1000.0 * m_framesInSample / static_cast<double>(sampleMs);
    m_averageFrameMs = static_cast<double>(sampleMs) / std::max(1, m_framesInSample);
    m_worstFrameMs = static_cast<double>(m_worstInSampleMs);
    m_framesInSample = 0;
    m_worstInSampleMs = 0;
    m_sampleClock.restart();
    emit statsChanged();
}
