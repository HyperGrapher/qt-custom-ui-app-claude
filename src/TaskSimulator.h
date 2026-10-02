#pragma once

#include <chrono>

#include <QElapsedTimer>
#include <QObject>
#include <QStringList>
#include <QTimer>
#include <QtQml/qqmlregistration.h>

// Mock long-running task for the Activity page. It only animates numbers; nothing real
// happens. The tick timer runs only while the task is Running.
class TaskSimulator : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("TaskSimulator is created by the application.")

    Q_PROPERTY(State state READ state NOTIFY stateChanged)
    Q_PROPERTY(double progress READ progress NOTIFY progressChanged)
    Q_PROPERTY(int completedSteps READ completedSteps NOTIFY progressChanged)
    Q_PROPERTY(QStringList stepNames READ stepNames CONSTANT)

public:
    enum class State
    {
        Idle,
        Running,
        Paused,
        Completed,
        Failed
    };
    Q_ENUM(State)

    explicit TaskSimulator(std::chrono::milliseconds duration = std::chrono::milliseconds(9000),
                           QObject *parent = nullptr);

    [[nodiscard]] State state() const { return m_state; }
    [[nodiscard]] double progress() const { return m_progress; }
    [[nodiscard]] int completedSteps() const;
    [[nodiscard]] QStringList stepNames() const { return m_stepNames; }

    // Starts, resumes after pause, or restarts after the task ended.
    Q_INVOKABLE void start();
    Q_INVOKABLE void pause();
    Q_INVOKABLE void reset();
    // Simulates a warning: stops a running or paused task in the Failed state.
    Q_INVOKABLE void fail();

signals:
    void stateChanged();
    void progressChanged();

private:
    void advance();
    void setState(State state);
    void setProgress(double progress);

    const std::chrono::milliseconds m_duration;
    const QStringList m_stepNames;
    QTimer m_ticker;
    QElapsedTimer m_runClock;
    State m_state = State::Idle;
    double m_progress = 0.0;
    double m_progressAtResume = 0.0;
};
