#include <chrono>

#include <QSignalSpy>
#include <QTest>

#include "TaskSimulator.h"

using namespace std::chrono_literals;

class TaskSimulatorTest final : public QObject
{
    Q_OBJECT

private slots:
    void startsIdle();
    void runsToCompletion();
    void pauseKeepsProgress();
    void failStopsTheTask();
    void resetReturnsToIdle();
    void startAfterCompletionRestarts();
};

void TaskSimulatorTest::startsIdle()
{
    const TaskSimulator simulator;
    QCOMPARE(simulator.state(), TaskSimulator::State::Idle);
    QCOMPARE(simulator.progress(), 0.0);
    QCOMPARE(simulator.completedSteps(), 0);
    QCOMPARE(simulator.stepNames().size(), 5);
}

void TaskSimulatorTest::runsToCompletion()
{
    TaskSimulator simulator(200ms);
    simulator.start();
    QCOMPARE(simulator.state(), TaskSimulator::State::Running);
    QTRY_COMPARE_WITH_TIMEOUT(simulator.state(), TaskSimulator::State::Completed, 3000);
    QCOMPARE(simulator.progress(), 1.0);
    QCOMPARE(simulator.completedSteps(), 5);
}

void TaskSimulatorTest::pauseKeepsProgress()
{
    TaskSimulator simulator(1000ms);
    simulator.start();
    QTRY_VERIFY_WITH_TIMEOUT(simulator.progress() > 0.1, 3000);
    simulator.pause();
    QCOMPARE(simulator.state(), TaskSimulator::State::Paused);

    const double pausedProgress = simulator.progress();
    QTest::qWait(150);
    QCOMPARE(simulator.progress(), pausedProgress);

    simulator.start();
    QCOMPARE(simulator.state(), TaskSimulator::State::Running);
    QTRY_VERIFY_WITH_TIMEOUT(simulator.progress() > pausedProgress, 3000);
}

void TaskSimulatorTest::failStopsTheTask()
{
    TaskSimulator simulator(1000ms);
    simulator.fail();
    QCOMPARE(simulator.state(), TaskSimulator::State::Idle);

    simulator.start();
    simulator.fail();
    QCOMPARE(simulator.state(), TaskSimulator::State::Failed);

    const double progress = simulator.progress();
    QTest::qWait(100);
    QCOMPARE(simulator.progress(), progress);
}

void TaskSimulatorTest::resetReturnsToIdle()
{
    TaskSimulator simulator(1000ms);
    simulator.start();
    QTRY_VERIFY_WITH_TIMEOUT(simulator.progress() > 0.0, 3000);

    QSignalSpy stateSpy(&simulator, &TaskSimulator::stateChanged);
    simulator.reset();
    QCOMPARE(simulator.state(), TaskSimulator::State::Idle);
    QCOMPARE(simulator.progress(), 0.0);
    QCOMPARE(stateSpy.count(), 1);
}

void TaskSimulatorTest::startAfterCompletionRestarts()
{
    TaskSimulator simulator(100ms);
    simulator.start();
    QTRY_COMPARE_WITH_TIMEOUT(simulator.state(), TaskSimulator::State::Completed, 3000);

    simulator.start();
    QCOMPARE(simulator.state(), TaskSimulator::State::Running);
    QVERIFY(simulator.progress() < 1.0);
}

QTEST_GUILESS_MAIN(TaskSimulatorTest)
#include "tst_tasksimulator.moc"
