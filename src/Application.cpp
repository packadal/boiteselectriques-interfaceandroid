#include "Application.h"
#include "instrumentimageprovider.h"

#include <QBuffer>
#include <QImage>
#include <cmath>

Application::Application(QObject* parent) : QObject(parent) {
  m_volumeTimer.setInterval(30);
  m_volumeTimer.setSingleShot(true);

  for (unsigned char i = 0; i < 8; ++i) {
    m_tracks.append(new Track(i, m_transmitter, this));
  }

  m_transmitter->registerEventHandler(
      "/box/sensor",
      std::bind(&Application::handle__box_sensor, this, std::placeholders::_1));
  m_transmitter->registerEventHandler(
      "/box/enable_sync", std::bind(&Application::handle__box_enableSync, this,
                                    std::placeholders::_1));
  m_transmitter->registerEventHandler(
      "/box/beat",
      std::bind(&Application::handle__box_beat, this, std::placeholders::_1));
  m_transmitter->registerEventHandler(
      "/box/title",
      std::bind(&Application::handle__box_title, this, std::placeholders::_1));
  m_transmitter->registerEventHandler(
      "/box/songs_list", std::bind(&Application::handle__box_songsList, this,
                                   std::placeholders::_1));
  m_transmitter->registerEventHandler(
      "/box/ready",
      std::bind(&Application::handle__box_ready, this, std::placeholders::_1));
  m_transmitter->registerEventHandler(
      "/box/tracks_list", std::bind(&Application::handle__box_tracksList, this,
                                    std::placeholders::_1));
  m_transmitter->registerEventHandler(
      "/box/master",
      std::bind(&Application::handle__box_master, this, std::placeholders::_1));
  m_transmitter->registerEventHandler(
      "/box/volume",
      std::bind(&Application::handle__box_volume, this, std::placeholders::_1));
  m_transmitter->registerEventHandler(
      "/box/pan",
      std::bind(&Application::handle__box_pan, this, std::placeholders::_1));
  m_transmitter->registerEventHandler(
      "/box/mute",
      std::bind(&Application::handle__box_mute, this, std::placeholders::_1));
  m_transmitter->registerEventHandler(
      "/box/solo",
      std::bind(&Application::handle__box_solo, this, std::placeholders::_1));
  m_transmitter->registerEventHandler(
      "/box/play", std::bind(&Application::handle__box_playing, this,
                             std::placeholders::_1));
  m_transmitter->registerEventHandler(
      "/box/images",
      std::bind(&Application::handle__box_images, this, std::placeholders::_1));

  connect(m_transmitter.get(), &Transmitter::isConnectedChanged, [this]() {
    if (m_transmitter->isConnected()) {
      sync();
    }
    emit connectionErrorChanged();
  });

  setBeat(0);

  checkConnection();
}

Application::~Application() {
  m_transmitter->send("/box/quit", true);
  QCoreApplication::processEvents(QEventLoop::AllEvents, 100);
  m_transmitter = nullptr;
}

void Application::handle__box_sensor(QDataStream& args) {
  qint32 threshold_in;
  args >> threshold_in;
  setThreshold(threshold_in);
}

void Application::handle__box_tracksList(QDataStream& args) {
  QStringList trackNames;
  args >> trackNames;
  for (unsigned char i = 0; i < trackNames.size(); ++i) {
    m_tracks[i]->setName(trackNames[i]);
  }

  m_enabledTrackCount = trackNames.size();
  emit enabledTrackCountChanged();
}

void Application::handle__box_enableSync(QDataStream& args) {
  emit connectionEstablished();

  qint32 val;
  args >> val;

  for (unsigned char i = 0; i < m_tracks.size(); ++i) {
    // this creates an integer with only one bit enabled, which is the i-th one,
    // e.g. for i == 4, this will make an int whose value is 0b00010000
    const int mask = 1 << i;
    // this is a binary comparison that checks if val has the bit in the mask
    // set to true or false
    m_tracks[i]->setActivated((mask & val) != 0);
  }
}

void Application::handle__box_beat(QDataStream& args) {
  double beat;
  args >> beat;

  setBeat(beat);
  // nextBeat((int)beat);
}

void Application::handle__box_title(QDataStream& args) {
  QString title;
  args >> title;
  setCurrentSongTitle(title);
}

void Application::handle__box_songsList(QDataStream& args) {
  QStringList liste;
  args >> liste;

  setSongList(liste);
}

void Application::handle__box_ready(QDataStream& args) {
  bool go;
  args >> go;
  ready(go);
}

void Application::handle__box_master(QDataStream& args) {
  qint32 master;
  args >> master;
  setMasterVolume(master);
}

void Application::handle__box_volume(QDataStream& args) {
  qint32 track;
  qint32 vol;
  args >> track >> vol;

  if (track < m_tracks.size()) {
    m_tracks[track]->setVolume(vol);
  }
}

void Application::handle__box_pan(QDataStream& args) {
  qint32 track;
  qint32 pan;
  args >> track >> pan;

  if (track < m_tracks.size()) {
    m_tracks[track]->setPan(pan);
  }
}

void Application::handle__box_mute(QDataStream& args) {
  qint32 muteStatus;
  args >> muteStatus;

  for (unsigned char i = 0; i < m_tracks.size(); ++i) {
    // this creates an integer with only one bit enabled, which is the i-th one,
    // e.g. for i == 4, this will make an int whose value is 0b00010000
    const int mask = 1 << i;
    // this is a binary comparison that checks if val has the bit in the mask
    // set to true or false
    m_tracks[i]->setMuted((mask & muteStatus) != 0);
  }
}

void Application::handle__box_solo(QDataStream& args) {
  qint32 soloStatus;
  args >> soloStatus;

  for (unsigned char i = 0; i < m_tracks.size(); ++i) {
    // this creates an integer with only one bit enabled, which is the i-th one,
    // e.g. for i == 4, this will make an int whose value is 0b00010000
    const int mask = 1 << i;
    // this is a binary comparison that checks if val has the bit in the mask
    // set to true or false
    m_tracks[i]->setSolo((mask & soloStatus) != 0);
  }
}

void Application::handle__box_playing(QDataStream& args) {
  bool playing;
  args >> playing;
  setPlaying(playing);
}

void Application::handle__box_images(QDataStream& args) {
  QString imageName;
  args >> imageName;

  QByteArray imageData;
  args >> imageData;

  QBuffer dataBuffer;
  dataBuffer.setData(imageData);
  dataBuffer.open(QBuffer::ReadOnly);

  QImage image;
  image.load(&dataBuffer, "JPG");
  if (image.isNull()) {
    std::cerr << "Image is invalid :(" << std::endl;
  }

  InstrumentImageProvider::registerImage(m_currentSongTitle + " - " + imageName,
                                         image);
}

void Application::deleteSong(const QString& songName) {
  m_transmitter->send("/box/delete_song", songName);
}

QString Application::song() const {
  return m_song;
}

void Application::updateThreshold(int thresh) {
  if (thresh != threshold()) {
    // convert from sensitivity (as shown by the UI), to threshold
    m_transmitter->send("/box/update_threshold", 100 - thresh);
  }
}

void Application::play() {
  m_transmitter->send("/box/play", true);
}

void Application::stop() {
  m_transmitter->send("/box/stop", true);
  setPlaying(false);
}

void Application::updateMasterVolume(int vol) {
  if (!m_volumeTimer.isActive() && vol != m_masterVolume) {
    m_volumeTimer.start();
    m_transmitter->send("/box/master", vol);
  }
}

void Application::reset() {
  m_transmitter->send("/box/reset", true);
  setPlaying(false);
}

void Application::resetThreshold() {
  m_transmitter->send("/box/reset_threshold", 0);
}

void Application::refreshSong() {
  m_transmitter->send("/box/refresh_song", true);
}

void Application::selectSong(const QString& song) {
  m_transmitter->send("/box/select_song", song);
}

void Application::reloadSong() {
  selectSong(m_song);
}

void Application::sync() {
  m_transmitter->send("/box/sync", true);
}

void Application::checkConnection() {
  m_transmitter->connectToServer();
  if (m_transmitter->isConnected()) {
    sync();
  }
}

void Application::ready(bool go) {
  emit updateReady(go);
}

QQmlListProperty<Track> Application::tracks() {
  return QQmlListProperty<Track>(this, m_tracks);
}
