#include "Application.h"

#include <cmath>

Application::Application(QObject* parent) : QObject(parent) {
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
      "/box/play",
      std::bind(&Application::handle__box_play, this, std::placeholders::_1));
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

  m_oscReceiver.run();

  m_beatsTimer.start();

  setBeat(0);
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
  setTrackList(QString(listeT).split('|'));
}

void Application::handle__box_enableSync(
    osc::ReceivedMessageArgumentStream args) {
  osc::int32 val;
  args >> val;
  syncBox(val);
}

void Application::handle__box_beat(osc::ReceivedMessageArgumentStream args) {
  osc::int32 beat;
  args >> beat;

  setBeat(beat);
  // nextBeat((int)beat);
}

void Application::handle__box_play(osc::ReceivedMessageArgumentStream args) {
  m_beatsTimer.restart();
  osc::int32 tempo;
  args >> tempo;
  tempo = static_cast<int>(tempo);

  setPlaying(true);
}

void Application::handle__box_title(osc::ReceivedMessageArgumentStream args) {
  const char* title;
  args >> title;
  setCurrentSongTitle(title);
}

void Application::handle__box_songsList(
    osc::ReceivedMessageArgumentStream args) {
  const char* liste;
  args >> liste;

  setSongList(QString(liste).split('|'));
}

void Application::handle__box_ready(osc::ReceivedMessageArgumentStream args) {
  bool go;
  args >> go;
  ready(go);
}

void Application::deleteSong(const QString& songName) {
  m_sender.send(
      osc::MessageGenerator()("/box/delete_song", songName.toUtf8().data()));
}

void Application::syncBox(int val) {
  for (int i = 0; i < 8; ++i) {
    // this creates an integer with only one bit enabled, which is the i-th one,
    // e.g. for i == 4, this will make an int whose value is 0b00010000
    const int mask = 1 << i;
    // this is a binary comparison that checks if val has the bit in the mask
    // set to true or false
    setChannel(i, (mask & val) != 0);
  }
}
QString Application::song() const {
  return m_song;
}

void Application::updateThreshold(int thresh) {
  m_sender.send(osc::MessageGenerator()("/box/update_threshold", thresh));
}

void Application::button(int chan) {
  m_sender.send(osc::MessageGenerator()("/box/enable", chan));
}

void Application::volume(int vol, int chan) {
  m_sender.send(osc::MessageGenerator()("/box/volume", chan, vol));
}

void Application::pan(int vol, int chan) {
  m_sender.send(osc::MessageGenerator()("/box/pan", chan, vol));
}

void Application::mute(int chan, bool state) {
  m_sender.send(osc::MessageGenerator()("/box/mute", chan, state));
}

void Application::solo(int chan, bool state) {
  m_sender.send(osc::MessageGenerator()("/box/solo", chan, state));
}

void Application::play() {
  m_sender.send(osc::MessageGenerator()("/box/play", true));
}

void Application::stop() {
  m_sender.send(osc::MessageGenerator()("/box/stop", true));
  setPlaying(false);
  setBeat(0);
}

void Application::masterVolume(int vol) {
  m_sender.send(osc::MessageGenerator()("/box/master", vol));
}

void Application::reset() {
  m_sender.send(osc::MessageGenerator()("/box/reset", true));
  setPlaying(false);
  setBeat(0);
}

void Application::resetThreshold() {
  m_sender.send(osc::MessageGenerator()("/box/reset_threshold", 0));
}

void Application::refreshSong() {
  m_sender.send(osc::MessageGenerator()("/box/refresh_song", true));
}

void Application::selectSong(const QString& song) {
  m_song = song;
  QByteArray so = song.toLatin1();
  const char* c_song = so.data();
  m_sender.send(osc::MessageGenerator()("/box/select_song", c_song));
}

void Application::reloadSong() {
  selectSong(m_song);
}

void Application::sync() {
  m_sender.send(osc::MessageGenerator()("/box/sync", true));
}

void Application::setChannel(int chan, bool enabled) {
  static const std::function<void(bool)> enableFunctions[8] = {
      std::bind(&Application::setChannel0, this, std::placeholders::_1),
      std::bind(&Application::setChannel1, this, std::placeholders::_1),
      std::bind(&Application::setChannel2, this, std::placeholders::_1),
      std::bind(&Application::setChannel3, this, std::placeholders::_1),
      std::bind(&Application::setChannel4, this, std::placeholders::_1),
      std::bind(&Application::setChannel5, this, std::placeholders::_1),
      std::bind(&Application::setChannel6, this, std::placeholders::_1),
      std::bind(&Application::setChannel7, this, std::placeholders::_1),
  };

  enableFunctions[chan](enabled);
}

void Application::ready(bool go) {
  emit updateReady(go);
}
