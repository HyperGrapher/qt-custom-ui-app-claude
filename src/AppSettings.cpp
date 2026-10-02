#include "AppSettings.h"

#include <algorithm>

namespace {

constexpr auto kReducedMotionKey = "motion/reduced";
constexpr auto kAmbientEnabledKey = "motion/ambient";
constexpr auto kAmbientSpeedKey = "motion/ambientSpeed";
constexpr auto kGlassHighlightsKey = "appearance/glassHighlights";
constexpr auto kBackgroundIntensityKey = "appearance/backgroundIntensity";
constexpr auto kPerformanceOverlayKey = "diagnostics/performanceOverlay";
constexpr auto kLastSectionKey = "navigation/lastSection";

AppSettings::AmbientSpeed toAmbientSpeed(int value)
{
    const int clamped = std::clamp(value, static_cast<int>(AppSettings::AmbientSpeed::Calm),
                                   static_cast<int>(AppSettings::AmbientSpeed::Lively));
    return static_cast<AppSettings::AmbientSpeed>(clamped);
}

} // namespace

AppSettings::AppSettings(const QString &storagePath, QObject *parent)
    : QObject(parent)
    , m_storage(storagePath, QSettings::IniFormat)
{
    m_reducedMotion = m_storage.value(kReducedMotionKey, m_reducedMotion).toBool();
    m_ambientEnabled = m_storage.value(kAmbientEnabledKey, m_ambientEnabled).toBool();
    m_glassHighlights = m_storage.value(kGlassHighlightsKey, m_glassHighlights).toBool();
    m_performanceOverlay = m_storage.value(kPerformanceOverlayKey, m_performanceOverlay).toBool();
    m_ambientSpeed =
        toAmbientSpeed(m_storage.value(kAmbientSpeedKey, static_cast<int>(m_ambientSpeed)).toInt());
    m_backgroundIntensity =
        std::clamp(m_storage.value(kBackgroundIntensityKey, m_backgroundIntensity).toDouble(),
                   kMinimumIntensity, 1.0);
    m_lastSection =
        std::clamp(m_storage.value(kLastSectionKey, m_lastSection).toInt(), 0, kSectionCount - 1);
}

void AppSettings::setReducedMotion(bool enabled)
{
    if (m_reducedMotion == enabled) {
        return;
    }
    m_reducedMotion = enabled;
    m_storage.setValue(kReducedMotionKey, enabled);
    emit reducedMotionChanged();
}

void AppSettings::setAmbientEnabled(bool enabled)
{
    if (m_ambientEnabled == enabled) {
        return;
    }
    m_ambientEnabled = enabled;
    m_storage.setValue(kAmbientEnabledKey, enabled);
    emit ambientEnabledChanged();
}

void AppSettings::setGlassHighlights(bool enabled)
{
    if (m_glassHighlights == enabled) {
        return;
    }
    m_glassHighlights = enabled;
    m_storage.setValue(kGlassHighlightsKey, enabled);
    emit glassHighlightsChanged();
}

void AppSettings::setPerformanceOverlay(bool visible)
{
    if (m_performanceOverlay == visible) {
        return;
    }
    m_performanceOverlay = visible;
    m_storage.setValue(kPerformanceOverlayKey, visible);
    emit performanceOverlayChanged();
}

void AppSettings::setAmbientSpeed(AmbientSpeed speed)
{
    if (m_ambientSpeed == speed) {
        return;
    }
    m_ambientSpeed = speed;
    m_storage.setValue(kAmbientSpeedKey, static_cast<int>(speed));
    emit ambientSpeedChanged();
}

void AppSettings::setBackgroundIntensity(double intensity)
{
    const double clamped = std::clamp(intensity, kMinimumIntensity, 1.0);
    if (qFuzzyCompare(m_backgroundIntensity, clamped)) {
        return;
    }
    m_backgroundIntensity = clamped;
    m_storage.setValue(kBackgroundIntensityKey, clamped);
    emit backgroundIntensityChanged();
}

void AppSettings::setLastSection(int section)
{
    const int clamped = std::clamp(section, 0, kSectionCount - 1);
    if (m_lastSection == clamped) {
        return;
    }
    m_lastSection = clamped;
    m_storage.setValue(kLastSectionKey, clamped);
    emit lastSectionChanged();
}

void AppSettings::resetToDefaults()
{
    setReducedMotion(false);
    setAmbientEnabled(true);
    setGlassHighlights(true);
    setPerformanceOverlay(false);
    setAmbientSpeed(AmbientSpeed::Normal);
    setBackgroundIntensity(1.0);
}
