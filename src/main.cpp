#include "Application.h"

#include <QApplication>
#include <QFileSystemWatcher>
#include <QQmlApplicationEngine>
#include <QQmlContext>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    Application monapp;
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("app", &monapp);

    engine.load(QUrl(QStringLiteral("qrc:///main.qml")));

    QObject::connect(&monapp, SIGNAL(thresholdReceive(QVariant)),
                     engine.rootObjects().constFirst()->findChild<QObject*>("threshold"), SLOT(aff_threshold(QVariant)));
    QObject::connect(&monapp, SIGNAL(updateList(QVariant)),
                     engine.rootObjects().constFirst()->findChild<QObject*>("Liste"), SLOT(aff_liste(QVariant)));
    QObject::connect(&monapp, SIGNAL(updateTotalTrack(QVariant)),
                     engine.rootObjects().constFirst(), SLOT(totaltrack(QVariant)));
    QObject::connect(&monapp, SIGNAL(updateTrackList(QVariant)),
                     engine.rootObjects().constFirst(), SLOT(aff_liste_track(QVariant)));

    return app.exec();
}
