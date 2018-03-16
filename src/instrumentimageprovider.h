#pragma once

#include <QQuickImageProvider>

class InstrumentImageProvider : public QQuickImageProvider {
 public:
  InstrumentImageProvider();

  QImage requestImage(const QString& id,
                      QSize* size,
                      const QSize& requestedSize);

  static void registerImage(const QString& id, const QImage& image);

 private:
  static QMap<QString, QImage> s_images;
};
