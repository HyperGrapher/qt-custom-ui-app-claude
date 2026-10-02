#include <QSignalSpy>
#include <QTemporaryDir>
#include <QTest>

#include "AppSettings.h"

class AppSettingsTest final : public QObject
{
    Q_OBJECT

private slots:
    void init();
    void hasDefaults();
    void persistsValues();
    void clampsOutOfRangeValues();
    void emitsOnlyOnRealChanges();
    void resetRestoresDefaults();

private:
    [[nodiscard]] QString storagePath() const { return m_directory->filePath("settings.ini"); }

    std::unique_ptr<QTemporaryDir> m_directory;
};

void AppSettingsTest::init()
{
    m_directory = std::make_unique<QTemporaryDir>();
    QVERIFY(m_directory->isValid());
}

void AppSettingsTest::hasDefaults()
{
    const AppSettings settings(storagePath());
    QCOMPARE(settings.reducedMotion(), false);
    QCOMPARE(settings.ambientEnabled(), true);
    QCOMPARE(settings.glassHighlights(), true);
    QCOMPARE(settings.performanceOverlay(), false);
    QCOMPARE(settings.ambientSpeed(), AppSettings::AmbientSpeed::Normal);
    QCOMPARE(settings.backgroundIntensity(), 1.0);
    QCOMPARE(settings.lastSection(), 0);
}

void AppSettingsTest::persistsValues()
{
    {
        AppSettings settings(storagePath());
        settings.setReducedMotion(true);
        settings.setAmbientEnabled(false);
        settings.setAmbientSpeed(AppSettings::AmbientSpeed::Lively);
        settings.setBackgroundIntensity(0.5);
        settings.setLastSection(2);
    }

    const AppSettings reloaded(storagePath());
    QCOMPARE(reloaded.reducedMotion(), true);
    QCOMPARE(reloaded.ambientEnabled(), false);
    QCOMPARE(reloaded.ambientSpeed(), AppSettings::AmbientSpeed::Lively);
    QCOMPARE(reloaded.backgroundIntensity(), 0.5);
    QCOMPARE(reloaded.lastSection(), 2);
}

void AppSettingsTest::clampsOutOfRangeValues()
{
    AppSettings settings(storagePath());
    settings.setBackgroundIntensity(-3.0);
    QCOMPARE(settings.backgroundIntensity(), AppSettings::kMinimumIntensity);
    settings.setLastSection(99);
    QCOMPARE(settings.lastSection(), AppSettings::kSectionCount - 1);
}

void AppSettingsTest::emitsOnlyOnRealChanges()
{
    AppSettings settings(storagePath());
    QSignalSpy spy(&settings, &AppSettings::reducedMotionChanged);
    settings.setReducedMotion(false);
    QCOMPARE(spy.count(), 0);
    settings.setReducedMotion(true);
    settings.setReducedMotion(true);
    QCOMPARE(spy.count(), 1);
}

void AppSettingsTest::resetRestoresDefaults()
{
    AppSettings settings(storagePath());
    settings.setReducedMotion(true);
    settings.setPerformanceOverlay(true);
    settings.setBackgroundIntensity(0.3);
    settings.resetToDefaults();
    QCOMPARE(settings.reducedMotion(), false);
    QCOMPARE(settings.performanceOverlay(), false);
    QCOMPARE(settings.backgroundIntensity(), 1.0);
}

QTEST_GUILESS_MAIN(AppSettingsTest)
#include "tst_appsettings.moc"
