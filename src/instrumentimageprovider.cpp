#include "instrumentimageprovider.h"

QMap<QString, QImage> InstrumentImageProvider::s_images;

InstrumentImageProvider::InstrumentImageProvider()
    : QQuickImageProvider(QQuickImageProvider::Image) {}

QImage InstrumentImageProvider::requestImage(const QString& id,
                                             QSize* size,
                                             const QSize& /*requestedSize*/) {
  if (s_images.contains(id)) {
    QImage image = s_images[id];
    if (size) {
      *size = image.size();
    }
    return image;
  }
  return QImage();
}

void InstrumentImageProvider::registerImage(const QString& id,
                                            const QImage& image) {
  s_images[id] = image;
}
