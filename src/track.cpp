#include "track.h"

Track::Track() {}

Track::Track(unsigned char trackID, std::shared_ptr<Transmitter> sender,
             QObject *parent)
    : QObject(parent), m_trackID(trackID), m_transmitter(sender) {
  m_volumeTimer.setInterval(30);
  m_volumeTimer.setSingleShot(true);
}

void Track::setActivated(bool activated) {
  if (activated != m_activated) {
    m_activated = activated;
    emit activatedChanged();
  }
}

void Track::setEnabled(bool enabled) {
  if (enabled != m_enabled) {
    m_enabled = enabled;
    emit enabledChanged();
  }
}

void Track::setMuted(bool muted) {
  if (muted != m_muted) {
    m_muted = muted;
    emit mutedChanged();
  }
}

void Track::setSolo(bool solo) {
  if (solo != m_solo) {
    m_solo = solo;
    emit soloChanged();
  }
}

void Track::setVolume(int volume) {
  if (volume != m_volume) {
    m_volume = volume;
    emit volumeChanged();
  }
}

void Track::setPan(int pan) {
  if (pan != m_pan) {
    m_pan = pan;
    emit panChanged();
  }
}

void Track::setName(const QString &name) {
  if (name != m_name) {
    m_name = name;
    emit nameChanged();
  }
}

void Track::updateActivated(bool activated) {
  // this toggles the track's state, despite the message name
  m_transmitter->send("/box/enable", qint32(m_trackID), activated);
}

void Track::updateMuted(bool muted) {
  m_transmitter->send("/box/mute", qint32(m_trackID), muted);
}

void Track::updateSolo(bool solo) {
  m_transmitter->send("/box/solo", qint32(m_trackID), solo);
}

void Track::updateVolume(int volume) {
  if (!m_volumeTimer.isActive() && volume != m_volume) {
    m_volumeTimer.start();
    m_transmitter->send("/box/volume", qint32(m_trackID), qint32(volume));
  }
}

void Track::updatePan(int pan) {
  if (pan != m_pan) {
    m_transmitter->send("/box/pan", qint32(m_trackID), qint32(pan));
  }
}

void Track::reset() {
  updateActivated(false);
  updateMuted(false);
  updateSolo(false);
  updateVolume(50);
  updatePan(0);
}
