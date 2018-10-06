#pragma once
#include <QObject>
#include <QTimer>

#include <osc/oscsender.h>

class Track : public QObject {
  Q_OBJECT

  Q_PROPERTY(
      bool activated READ activated WRITE setActivated NOTIFY activatedChanged)
  Q_PROPERTY(bool muted READ muted WRITE setMuted NOTIFY mutedChanged)
  Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)
  Q_PROPERTY(bool solo READ solo WRITE setSolo NOTIFY soloChanged)
  Q_PROPERTY(int volume READ volume WRITE setVolume NOTIFY volumeChanged)
  Q_PROPERTY(int pan READ pan WRITE setPan NOTIFY panChanged)
  Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)

 public:
  Track();
  explicit Track(unsigned char trackID,
                 std::shared_ptr<OscSender> sender,
                 QObject* parent = nullptr);

  bool activated() const { return m_activated; }
  bool enabled() const { return m_enabled; }
  bool muted() const { return m_muted; }
  bool solo() const { return m_solo; }
  int volume() const { return m_volume; }
  int pan() const { return m_pan; }
  QString name() const { return m_name; }

 public slots:

  // these functions are the property setter
  void setActivated(bool activated);
  void setEnabled(bool enabled);
  void setMuted(bool muted);
  void setSolo(bool solo);
  void setVolume(int volume);
  void setPan(int pan);
  void setName(const QString& name);

  // these functions only send the data to the server
  void updateActivated(bool activated);
  void updateMuted(bool muted);
  void updateSolo(bool solo);
  void updateVolume(int volume);
  void updatePan(int pan);

  void reset();

 signals:
  void activatedChanged();
  void enabledChanged();
  void mutedChanged();
  void soloChanged();
  void volumeChanged();
  void panChanged();
  void nameChanged();

 private:
  bool m_activated = false;
  bool m_enabled = true;
  bool m_muted = false;
  bool m_solo = false;
  int m_volume = 50;
  int m_pan = 0;
  QString m_name = QString::null;

  unsigned char m_trackID = 255;

  std::shared_ptr<OscSender> m_sender;
  QTimer m_volumeTimer;
};
