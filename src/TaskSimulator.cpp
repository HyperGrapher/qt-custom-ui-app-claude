#include "TaskSimulator.h"

#include <algorithm>
#include <cmath>

namespace {

// 25 Hz is enough: the progress ring smooths between ticks on the QML side.
constexpr std::chrono::milliseconds kTickInterval{40};

} // namespace

TaskSimulator::TaskSimulator(std::chrono::milliseconds duration, QObject *parent)
    : QObject(parent)
    , m_duration(std::max(duration, std::chrono::milliseconds(1)))
    , m_stepNames{tr("Preparing workspace"), tr("Indexing items"), tr("Optimizing previews"),
                  tr("Syncing changes"), tr("Finalizing")}
{
    m_ticker.setInterval(kTickInterval);
    m_ticker.setTimerType(Qt::CoarseTimer);
    connect(&m_ticker, &QTimer::timeout, this, &TaskSimulator::advance);
}

int TaskSimulator::completedSteps() const
{
    const auto stepCount = static_cast<int>(m_stepNames.size());
    const int completed = static_cast<int>(std::floor(m_progress * stepCount));
    return std::clamp(completed, 0, stepCount);
}

void TaskSimulator::start()
{
    if (m_state == State::Running) {
        return;
    }
    if (m_state == State::Completed || m_state == State::Failed) {
        setProgress(0.0);
    }
    m_progressAtResume = m_progress;
    m_runClock.start();
    m_ticker.start();
    setState(State::Running);
}

void TaskSimulator::pause()
{
    if (m_state != State::Running) {
        return;
    }
    advance();
    m_ticker.stop();
    setState(State::Paused);
}

void TaskSimulator::reset()
{
    m_ticker.stop();
    setProgress(0.0);
    setState(State::Idle);
}

void TaskSimulator::fail()
{
    if (m_state != State::Running && m_state != State::Paused) {
        return;
    }
    m_ticker.stop();
    setState(State::Failed);
}

void TaskSimulator::advance()
{
    // Progress follows wall-clock time, so timer jitter does not change the total duration.
    const double elapsedShare =
        static_cast<double>(m_runClock.elapsed()) / static_cast<double>(m_duration.count());
    const double progress = std::min(1.0, m_progressAtResume + elapsedShare);
    setProgress(progress);
    if (progress >= 1.0) {
        m_ticker.stop();
        setState(State::Completed);
    }
}

void TaskSimulator::setState(State state)
{
    if (m_state == state) {
        return;
    }
    m_state = state;
    emit stateChanged();
}

void TaskSimulator::setProgress(double progress)
{
    if (qFuzzyCompare(m_progress + 1.0, progress + 1.0)) {
        return;
    }
    m_progress = progress;
    emit progressChanged();
}
