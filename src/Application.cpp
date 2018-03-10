#include "Application.h"

#include <cmath>

Application::Application(QObject* parent) : QObject(parent) {
  for (unsigned char i = 0; i < 8; ++i) {
    m_tracks.append(new Track(i, m_sender, this));
  }

  m_oscReceiver.addHandler(
      "/box/sensor",
      std::bind(&Application::handle__box_sensor, this, std::placeholders::_1));
  m_oscReceiver.addHandler("/box/enable_sync",
                           std::bind(&Application::handle__box_enableSync, this,
                                     std::placeholders::_1));
  m_oscReceiver.addHandler(
      "/box/beat",
      std::bind(&Application::handle__box_beat, this, std::placeholders::_1));
  m_oscReceiver.addHandler(
      "/box/title",
      std::bind(&Application::handle__box_title, this, std::placeholders::_1));
  m_oscReceiver.addHandler("/box/songs_list",
                           std::bind(&Application::handle__box_songsList, this,
                                     std::placeholders::_1));
  m_oscReceiver.addHandler(
      "/box/ready",
      std::bind(&Application::handle__box_ready, this, std::placeholders::_1));
  m_oscReceiver.addHandler("/box/tracks_list",
                           std::bind(&Application::handle__box_tracksList, this,
                                     std::placeholders::_1));
  m_oscReceiver.addHandler(
      "/box/master",
      std::bind(&Application::handle__box_master, this, std::placeholders::_1));
  m_oscReceiver.addHandler(
      "/box/volume",
      std::bind(&Application::handle__box_volume, this, std::placeholders::_1));
  m_oscReceiver.addHandler("/box/pan", std::bind(&Application::handle__box_pan,
                                                 this, std::placeholders::_1));
  m_oscReceiver.addHandler(
      "/box/mute",
      std::bind(&Application::handle__box_mute, this, std::placeholders::_1));
  m_oscReceiver.addHandler(
      "/box/solo",
      std::bind(&Application::handle__box_solo, this, std::placeholders::_1));
  m_oscReceiver.addHandler("/box/play",
                           std::bind(&Application::handle__box_playing, this,
                                     std::placeholders::_1));

  m_oscReceiver.run();

  setBeat(0);
  connect(&m_connectionTest, &QTimer::timeout, [this]() {
    qWarning() << "connection error";
    m_connectionError = true;
    emit connectionErrorChanged();
  });
  connect(this, &Application::connectionEstablished, this,
          &Application::acceptConnection);
  checkConnection();
}

Application::~Application() {
  m_sender->send(osc::MessageGenerator()("/box/quit", true));
}

void Application::handle__box_sensor(osc::ReceivedMessageArgumentStream args) {
  osc::int32 threshold_in;
  args >> threshold_in;
  setThreshold(threshold_in);
}

void Application::handle__box_tracksList(
    osc::ReceivedMessageArgumentStream args) {
  const char* listeT;
  args >> listeT;
  QStringList trackNames = QString::fromUtf8(listeT).split('|');
  for (unsigned char i = 0; i < trackNames.size(); ++i) {
    m_tracks[i]->setName(trackNames[i]);
  }

  m_enabledTrackCount = trackNames.size();
  emit enabledTrackCountChanged();
}

void Application::handle__box_enableSync(
    osc::ReceivedMessageArgumentStream args) {
  // stop the timer that tries to find out if there are connection issues
  emit connectionEstablished();

  osc::int32 val;
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

void Application::handle__box_beat(osc::ReceivedMessageArgumentStream args) {
  double beat;
  args >> beat;

  setBeat(beat);
  // nextBeat((int)beat);
}

void Application::handle__box_title(osc::ReceivedMessageArgumentStream args) {
  const char* title;
  args >> title;
  setCurrentSongTitle(QString::fromUtf8(title));
}

void Application::handle__box_songsList(
    osc::ReceivedMessageArgumentStream args) {
  const char* liste;
  args >> liste;

  setSongList(QString::fromUtf8(liste).split('|'));
}

void Application::handle__box_ready(osc::ReceivedMessageArgumentStream args) {
  bool go;
  args >> go;
  ready(go);
}

void Application::handle__box_master(osc::ReceivedMessageArgumentStream args) {
  osc::int32 master;
  args >> master;
  setMasterVolume(master);
}

void Application::handle__box_volume(osc::ReceivedMessageArgumentStream args) {
  osc::int32 track;
  osc::int32 vol;
  args >> track >> vol;

  if (track < m_tracks.size()) {
    m_tracks[track]->setVolume(vol);
  }
}

void Application::handle__box_pan(osc::ReceivedMessageArgumentStream args) {
  osc::int32 track;
  osc::int32 pan;
  args >> track >> pan;

  if (track < m_tracks.size()) {
    m_tracks[track]->setPan(pan);
  }
}

void Application::handle__box_mute(osc::ReceivedMessageArgumentStream args) {
  osc::int32 muteStatus;
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

void Application::handle__box_solo(osc::ReceivedMessageArgumentStream args) {
  osc::int32 soloStatus;
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

void Application::handle__box_playing(osc::ReceivedMessageArgumentStream args) {
  bool playing;
  args >> playing;
  setPlaying(playing);
}

void Application::deleteSong(const QString& songName) {
  m_sender->send(
      osc::MessageGenerator()("/box/delete_song", songName.toUtf8().data()));
}

QString Application::song() const {
  return m_song;
}

void Application::updateThreshold(int thresh) {
  if (thresh != threshold()) {
    m_sender->send(osc::MessageGenerator()("/box/update_threshold", thresh));
  }
}

void Application::play() {
  m_sender->send(osc::MessageGenerator()("/box/play", true));
}

void Application::stop() {
  m_sender->send(osc::MessageGenerator()("/box/stop", true));
  setPlaying(false);
}

void Application::updateMasterVolume(int vol) {
  m_sender->send(osc::MessageGenerator()("/box/master", vol));
}

void Application::reset() {
  m_sender->send(osc::MessageGenerator()("/box/reset", true));
  setPlaying(false);
}

void Application::resetThreshold() {
  m_sender->send(osc::MessageGenerator()("/box/reset_threshold", 0));
}

void Application::refreshSong() {
  m_sender->send(osc::MessageGenerator()("/box/refresh_song", true));
}

void Application::selectSong(const QString& song) {
  m_song = song;
  QByteArray so = song.toUtf8();
  const char* c_song = so.data();
  m_sender->send(osc::MessageGenerator()("/box/select_song", c_song));
}

void Application::reloadSong() {
  selectSong(m_song);
}

void Application::sync() {
  m_sender->send(osc::MessageGenerator()("/box/sync", true));
}

void Application::checkConnection() {
  sync();
  m_connectionTest.setSingleShot(true);
  m_connectionTest.start(500);
}

void Application::acceptConnection() {
  m_connectionTest.stop();
  m_connectionError = false;
  emit connectionErrorChanged();
}

void Application::ready(bool go) {
  emit updateReady(go);
}

QQmlListProperty<Track> Application::tracks() {
  return QQmlListProperty<Track>(this, m_tracks);
}
