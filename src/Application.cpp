#include "Application.h"
#include "instrumentimageprovider.h"

#include <cmath>

Application::Application(QObject *parent) : QObject(parent) {

  m_receiver.moveToThread(&m_receiverThread);
  connect(&m_receiverThread, &QThread::started, &m_receiver, &Receiver::start);
  m_receiverThread.start();

  connect(&m_receiver, &Receiver::sensor, this, &Application::setThreshold);
  connect(&m_receiver, &Receiver::beat, this, &Application::setBeat);
  connect(&m_receiver, &Receiver::title, this,
          &Application::setCurrentSongTitle);
  connect(&m_receiver, &Receiver::songList, this, &Application::setSongList);
  connect(&m_receiver, &Receiver::ready, this, &Application::ready);
  connect(&m_receiver, &Receiver::masterVolume, this,
          &Application::setMasterVolume);
  connect(&m_receiver, &Receiver::trackVolume, [this](int track, int volume) {
    if (track < m_tracks.size()) {
      m_tracks[track]->setVolume(volume);
    }
  });
  connect(&m_receiver, &Receiver::mute, [this](int muteMask) {
    for (unsigned char i = 0; i < m_tracks.size(); ++i) {
      // this creates an integer with only one bit enabled, which is the i-th
      // one, e.g. for i == 4, this will make an int whose value is 0b00010000
      const int mask = 1 << i;
      // this is a binary comparison that checks if val has the bit in the mask
      // set to true or false
      m_tracks[i]->setMuted((mask & muteMask) != 0);
    }
  });
  connect(&m_receiver, &Receiver::solo, [this](int soloMask) {
    for (unsigned char i = 0; i < m_tracks.size(); ++i) {
      // this creates an integer with only one bit enabled, which is the i-th
      // one, e.g. for i == 4, this will make an int whose value is 0b00010000
      const int mask = 1 << i;
      // this is a binary comparison that checks if val has the bit in the mask
      // set to true or false
      m_tracks[i]->setSolo((mask & soloMask) != 0);
    }
  });
  connect(&m_receiver, &Receiver::playing, this, &Application::setPlaying);

  connect(&m_receiver, &Receiver::trackList, [this](QStringList trackNames) {
    for (unsigned char i = 0; i < trackNames.size(); ++i) {
      m_tracks[i]->setName(trackNames[i]);
    }
    m_enabledTrackCount = trackNames.size();
    emit enabledTrackCountChanged();
  });
  connect(&m_receiver, &Receiver::enable, [this](int enableMask) {
    // stop the timer that tries to find out if there are connection issues
    emit connectionEstablished();

    for (unsigned char i = 0; i < m_tracks.size(); ++i) {
      // this creates an integer with only one bit enabled, which is the
      // i-thone, e.g. for i == 4, this will make an int whose value is
      // 0b00010000
      const int mask = 1 << i;
      // this is a binary comparison that checks if val has the bit in the mask
      // set to true or false
      m_tracks[i]->setActivated((mask & enableMask) != 0);
    }
  });

  m_volumeTimer.setInterval(30);
  m_volumeTimer.setSingleShot(true);

  for (unsigned char i = 0; i < 8; ++i) {
    m_tracks.append(new Track(i, m_sender, this));
  }

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

void Application::deleteSong(const QString &songName) {
  m_sender->send(
      osc::MessageGenerator()("/box/delete_song", songName.toUtf8().data()));
}

QString Application::song() const { return m_song; }

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
  if (!m_volumeTimer.isActive() && vol != m_masterVolume) {
    m_volumeTimer.start();
    m_sender->send(osc::MessageGenerator()("/box/master", vol));
  }
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

void Application::selectSong(const QString &song) {
  m_song = song;
  QByteArray so = song.toUtf8();
  const char *c_song = so.data();
  m_sender->send(osc::MessageGenerator()("/box/select_song", c_song));
}

void Application::reloadSong() { selectSong(m_song); }

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

void Application::ready(bool go) { emit updateReady(go); }

QQmlListProperty<Track> Application::tracks() {
  return QQmlListProperty<Track>(this, m_tracks);
}
