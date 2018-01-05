#include "Application.h"

#include <QApplication>
#include <QFileSystemWatcher>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>

int main(int argc, char* argv[]) {
  QApplication app(argc, argv);
  Application monapp;
  QQmlApplicationEngine engine;

  QQuickStyle::setStyle("Material");

  engine.rootContext()->setContextProperty("app", &monapp);

  engine.load(QUrl(QStringLiteral("qrc:///main.qml")));

  return app.exec();
}
