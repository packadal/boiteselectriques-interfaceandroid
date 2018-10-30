#include "receiver.h"
#include "instrumentimageprovider.h"

#include <QBuffer>
#include <QDebug>
#include <QImage>

Receiver::Receiver(QObject *parent) : QObject(parent) {

  m_oscReceiver.addHandler(
      "/box/sensor",
      std::bind(&Receiver::handle__box_sensor, this, std::placeholders::_1));
  m_oscReceiver.addHandler("/box/enable_sync",
                           std::bind(&Receiver::handle__box_enableSync, this,
                                     std::placeholders::_1));
  m_oscReceiver.addHandler("/box/beat", std::bind(&Receiver::handle__box_beat,
                                                  this, std::placeholders::_1));
  m_oscReceiver.addHandler(
      "/box/title",
      std::bind(&Receiver::handle__box_title, this, std::placeholders::_1));
  m_oscReceiver.addHandler(
      "/box/songs_list",
      std::bind(&Receiver::handle__box_songsList, this, std::placeholders::_1));
  m_oscReceiver.addHandler(
      "/box/ready",
      std::bind(&Receiver::handle__box_ready, this, std::placeholders::_1));
  m_oscReceiver.addHandler("/box/tracks_list",
                           std::bind(&Receiver::handle__box_tracksList, this,
                                     std::placeholders::_1));
  m_oscReceiver.addHandler(
      "/box/master",
      std::bind(&Receiver::handle__box_master, this, std::placeholders::_1));
  m_oscReceiver.addHandler(
      "/box/volume",
      std::bind(&Receiver::handle__box_volume, this, std::placeholders::_1));
  m_oscReceiver.addHandler("/box/pan", std::bind(&Receiver::handle__box_pan,
                                                 this, std::placeholders::_1));
  m_oscReceiver.addHandler("/box/mute", std::bind(&Receiver::handle__box_mute,
                                                  this, std::placeholders::_1));
  m_oscReceiver.addHandler("/box/solo", std::bind(&Receiver::handle__box_solo,
                                                  this, std::placeholders::_1));
  m_oscReceiver.addHandler(
      "/box/play",
      std::bind(&Receiver::handle__box_playing, this, std::placeholders::_1));
  m_oscReceiver.addHandler(
      "/box/images",
      std::bind(&Receiver::handle__box_images, this, std::placeholders::_1));
}

void Receiver::handle__box_sensor(osc::ReceivedMessageArgumentStream args) {
  osc::int32 threshold_in;
  args >> threshold_in;
  emit sensor(threshold_in);
}

void Receiver::handle__box_tracksList(osc::ReceivedMessageArgumentStream args) {
  const char *listeT;
  args >> listeT;
  QStringList trackNames = QString::fromUtf8(listeT).split('|');

  emit trackList(trackNames);
}

void Receiver::handle__box_enableSync(osc::ReceivedMessageArgumentStream args) {
  osc::int32 val;
  args >> val;

  emit enable(val);
}

void Receiver::handle__box_beat(osc::ReceivedMessageArgumentStream args) {
  double b;
  args >> b;

  emit beat(b);
}

void Receiver::handle__box_title(osc::ReceivedMessageArgumentStream args) {
  const char *t;
  args >> t;

  emit title(t);
}

void Receiver::handle__box_songsList(osc::ReceivedMessageArgumentStream args) {
  const char *liste;
  args >> liste;

  emit songList(QString::fromUtf8(liste).split('|'));
}

void Receiver::handle__box_ready(osc::ReceivedMessageArgumentStream args) {
  bool go;
  args >> go;

  emit ready(go);
}

void Receiver::handle__box_master(osc::ReceivedMessageArgumentStream args) {
  osc::int32 master;
  args >> master;

  emit masterVolume(master);
}

void Receiver::handle__box_volume(osc::ReceivedMessageArgumentStream args) {
  osc::int32 track;
  osc::int32 vol;
  args >> track >> vol;

  emit trackVolume(track, vol);
}

void Receiver::handle__box_pan(osc::ReceivedMessageArgumentStream args) {
  osc::int32 track;
  osc::int32 pan;
  args >> track >> pan;

  emit trackVolume(track, pan);
}

void Receiver::handle__box_mute(osc::ReceivedMessageArgumentStream args) {
  osc::int32 muteStatus;
  args >> muteStatus;

  emit mute(muteStatus);
}

void Receiver::handle__box_solo(osc::ReceivedMessageArgumentStream args) {
  osc::int32 soloStatus;
  args >> soloStatus;
  emit solo(soloStatus);
}

void Receiver::handle__box_playing(osc::ReceivedMessageArgumentStream args) {
  bool p;
  args >> p;

  emit playing(p);
}

void Receiver::handle__box_images(osc::ReceivedMessageArgumentStream args) {
  const char *name;
  osc::Blob b;
  args >> name;
  args >> b;

  const QString imageName = QString::fromUtf8(name);

  QBuffer dataBuffer;
  dataBuffer.setData(static_cast<const char *>(b.data), b.size);
  dataBuffer.open(QBuffer::ReadOnly);

  QImage image;
  image.load(&dataBuffer, "JPG");
  if (image.isNull()) {
    std::cerr << "Image is invalid :(" << std::endl;
  }

  InstrumentImageProvider::registerImage(imageName, image);
}

void Receiver::start() {
  qWarning() << "starting receiver";
  m_oscReceiver.run();
}
