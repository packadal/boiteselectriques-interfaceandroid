#include "Application.h"
#include "instrumentimageprovider.h"

#include <QApplication>
#include <QFileSystemWatcher>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>

#ifdef __arm__
#include <QAndroidJniObject>
#include <QtAndroid>
void keepScreenOn() {
  QtAndroid::runOnAndroidThread([]() {
    QAndroidJniObject activity = QtAndroid::androidActivity();
    if (activity.isValid()) {
      QAndroidJniObject window =
          activity.callObjectMethod("getWindow", "()Landroid/view/Window;");

      if (window.isValid()) {
        const int FLAG_KEEP_SCREEN_ON = 128;
        window.callMethod<void>("addFlags", "(I)V", FLAG_KEEP_SCREEN_ON);
      }
    }
  });
}
#endif

int main(int argc, char* argv[]) {
  QApplication app(argc, argv);
  Application monapp;
  QQmlApplicationEngine engine;

  QQuickStyle::setStyle("Material");

  qmlRegisterType<Track>("ElectricalBoxes", 1, 0, "Track");

  engine.rootContext()->setContextProperty("app", &monapp);
  engine.addImageProvider("instruments", new InstrumentImageProvider());

  engine.load(QUrl(QStringLiteral("qrc:///main.qml")));

#ifdef __arm__
  keepScreenOn();
#endif

  return app.exec();
}
