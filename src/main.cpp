#include <cstdlib>

#include <QCommandLineParser>
#include <QDir>
#include <QFont>
#include <QFontDatabase>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QQuickWindow>
#include <QStandardPaths>
#include <QUrl>

#include "AppSettings.h"
#include "CollectionModel.h"
#include "TaskSimulator.h"
#include "WindowChrome.h"

namespace {

struct LaunchOptions
{
    bool reducedMotion = false;
    bool translucencyAllowed = true;
    QString tourDirectory;
    QString settingsPath;
};

LaunchOptions parseLaunchOptions(const QGuiApplication &app)
{
    QCommandLineParser parser;
    parser.setApplicationDescription(QStringLiteral("Lumina UI proof of concept"));
    parser.addHelpOption();
    parser.addVersionOption();

    const QCommandLineOption reducedMotion(
        QStringLiteral("reduced-motion"),
        QStringLiteral("Start in reduced-motion mode for this session."));
    const QCommandLineOption noTranslucency(
        QStringLiteral("no-translucency"),
        QStringLiteral("Use an opaque window with square corners (for X11 without compositor)."));
    const QCommandLineOption tour(
        QStringLiteral("tour"),
        QStringLiteral("Run the automated demo tour, save screenshots to <dir>, then quit."),
        QStringLiteral("dir"));
    const QCommandLineOption settings(QStringLiteral("settings"),
                                      QStringLiteral("Use <file> to store settings."),
                                      QStringLiteral("file"));
    parser.addOptions({reducedMotion, noTranslucency, tour, settings});
    parser.process(app);

    LaunchOptions options;
    options.reducedMotion = parser.isSet(reducedMotion);
    options.translucencyAllowed = !parser.isSet(noTranslucency);
    options.tourDirectory = parser.value(tour);
    options.settingsPath = parser.value(settings);
    if (options.settingsPath.isEmpty()) {
        const QString configDir =
            QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation);
        options.settingsPath = QDir(configDir).filePath(QStringLiteral("settings.ini"));
    }
    return options;
}

void loadBundledFonts()
{
    const QStringList fontFiles{
        QStringLiteral(":/fonts/Inter-Regular.ttf"),  QStringLiteral(":/fonts/Inter-Medium.ttf"),
        QStringLiteral(":/fonts/Inter-SemiBold.ttf"), QStringLiteral(":/fonts/Inter-Bold.ttf"),
        QStringLiteral(":/fonts/Phosphor.ttf"),       QStringLiteral(":/fonts/Phosphor-Fill.ttf"),
    };
    for (const QString &fontFile : fontFiles) {
        if (QFontDatabase::addApplicationFont(fontFile) < 0) {
            qWarning("Could not load bundled font %s", qPrintable(fontFile));
        }
    }

    QFont uiFont(QStringLiteral("Inter"));
    uiFont.setHintingPreference(QFont::PreferVerticalHinting);
    QGuiApplication::setFont(uiFont);
}

} // namespace

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QGuiApplication::setOrganizationName(QStringLiteral("Lumina"));
    QGuiApplication::setApplicationName(QStringLiteral("Lumina"));
    QGuiApplication::setApplicationVersion(QStringLiteral(PROJECT_VERSION_STRING));

    const LaunchOptions options = parseLaunchOptions(app);
    loadBundledFonts();

    // Every control is custom-styled, so use the style designed for customization; native
    // styles would ignore or fight the custom backgrounds.
    QQuickStyle::setStyle(QStringLiteral("Basic"));

    WindowChrome chrome(options.translucencyAllowed);
    AppSettings settings(options.settingsPath);
    TaskSimulator taskSimulator;
    CollectionModel collectionModel;

    QQmlApplicationEngine engine;
    engine.setInitialProperties({
        {QStringLiteral("chrome"), QVariant::fromValue(&chrome)},
        {QStringLiteral("appSettings"), QVariant::fromValue(&settings)},
        {QStringLiteral("taskSimulator"), QVariant::fromValue(&taskSimulator)},
        {QStringLiteral("collectionModel"), QVariant::fromValue(&collectionModel)},
        {QStringLiteral("reducedMotionForced"), options.reducedMotion},
        {QStringLiteral("tourDirectory"), options.tourDirectory},
    });
    engine.load(QUrl(QStringLiteral("qrc:/qt/qml/Lumina/Main.qml")));
    if (engine.rootObjects().isEmpty()) {
        return EXIT_FAILURE;
    }

    if (auto *window = qobject_cast<QQuickWindow *>(engine.rootObjects().constFirst())) {
        chrome.attach(*window);
    }

    return QGuiApplication::exec();
}
