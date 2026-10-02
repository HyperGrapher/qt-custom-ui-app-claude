#pragma once

#include <QObject>
#include <QSettings>
#include <QString>
#include <QtQml/qqmlregistration.h>

// User preferences that survive restarts. Stored in an INI file so tests can point it at a
// temporary location.
class AppSettings : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("AppSettings is created by the application.")

    Q_PROPERTY(
        bool reducedMotion READ reducedMotion WRITE setReducedMotion NOTIFY reducedMotionChanged)
    Q_PROPERTY(bool ambientEnabled READ ambientEnabled WRITE setAmbientEnabled NOTIFY
                   ambientEnabledChanged)
    Q_PROPERTY(bool glassHighlights READ glassHighlights WRITE setGlassHighlights NOTIFY
                   glassHighlightsChanged)
    Q_PROPERTY(bool performanceOverlay READ performanceOverlay WRITE setPerformanceOverlay NOTIFY
                   performanceOverlayChanged)
    Q_PROPERTY(AmbientSpeed ambientSpeed READ ambientSpeed WRITE setAmbientSpeed NOTIFY
                   ambientSpeedChanged)
    Q_PROPERTY(double backgroundIntensity READ backgroundIntensity WRITE setBackgroundIntensity
                   NOTIFY backgroundIntensityChanged)
    Q_PROPERTY(int lastSection READ lastSection WRITE setLastSection NOTIFY lastSectionChanged)

public:
    enum class AmbientSpeed
    {
        Calm,
        Normal,
        Lively
    };
    Q_ENUM(AmbientSpeed)

    static constexpr int kSectionCount = 4;
    static constexpr double kMinimumIntensity = 0.2;

    explicit AppSettings(const QString &storagePath, QObject *parent = nullptr);

    [[nodiscard]] bool reducedMotion() const { return m_reducedMotion; }
    void setReducedMotion(bool enabled);

    [[nodiscard]] bool ambientEnabled() const { return m_ambientEnabled; }
    void setAmbientEnabled(bool enabled);

    [[nodiscard]] bool glassHighlights() const { return m_glassHighlights; }
    void setGlassHighlights(bool enabled);

    [[nodiscard]] bool performanceOverlay() const { return m_performanceOverlay; }
    void setPerformanceOverlay(bool visible);

    [[nodiscard]] AmbientSpeed ambientSpeed() const { return m_ambientSpeed; }
    void setAmbientSpeed(AmbientSpeed speed);

    [[nodiscard]] double backgroundIntensity() const { return m_backgroundIntensity; }
    void setBackgroundIntensity(double intensity);

    [[nodiscard]] int lastSection() const { return m_lastSection; }
    void setLastSection(int section);

    Q_INVOKABLE void resetToDefaults();

signals:
    void reducedMotionChanged();
    void ambientEnabledChanged();
    void glassHighlightsChanged();
    void performanceOverlayChanged();
    void ambientSpeedChanged();
    void backgroundIntensityChanged();
    void lastSectionChanged();

private:
    QSettings m_storage;
    bool m_reducedMotion = false;
    bool m_ambientEnabled = true;
    bool m_glassHighlights = true;
    bool m_performanceOverlay = false;
    AmbientSpeed m_ambientSpeed = AmbientSpeed::Normal;
    double m_backgroundIntensity = 1.0;
    int m_lastSection = 0;
};
