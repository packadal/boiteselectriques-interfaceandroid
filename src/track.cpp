#include "track.h"

#include "osc/oscmessagegenerator.h"

Track::Track() {}

Track::Track(unsigned char trackID, std::shared_ptr<OscSender> sender,
             QObject *parent)
    : QObject(parent), m_trackID(trackID), m_sender(sender) {
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

void Track::setName(const QString& name) {
  if (name != m_name) {
    m_name = name;
    emit nameChanged();
  }
}

void Track::updateActivated(bool activated) {
  // this toggles the track's state, despite the message name
  m_sender->send(osc::MessageGenerator()("/box/enable", m_trackID, activated));
}

void Track::updateMuted(bool muted) {
  m_sender->send(osc::MessageGenerator()("/box/mute", m_trackID, muted));
}

void Track::updateSolo(bool solo) {
  m_sender->send(osc::MessageGenerator()("/box/solo", m_trackID, solo));
}

void Track::updateVolume(int volume) {
  if (!m_volumeTimer.isActive() && volume != m_volume) {
    m_volumeTimer.start();
    m_sender->send(osc::MessageGenerator()("/box/volume", m_trackID, volume));
  }
}

void Track::updatePan(int pan) {
  if (pan != m_pan) {
    m_sender->send(osc::MessageGenerator()("/box/pan", m_trackID, pan));
  }
}

void Track::reset() {
  updateActivated(false);
  updateMuted(false);
  updateSolo(false);
  updateVolume(50);
  updatePan(0);
}
