#ifndef APPLICATION_H
#define APPLICATION_H

/**
 * @file Application.h
 * @brief Application interface
 */

#include <iostream>

#include "osc/oscmessagegenerator.h"
#include "osc/oscreceiver.h"
#include "osc/oscsender.h"

#include "track.h"

#include <QDebug>
#include <QObject>
#include <QQmlListProperty>
#include <QTime>
#include <QTimer>
#include <chrono>
#include <thread>

/**
 * @brief The Application class
 *
 * Main program
 */
class Application : public QObject {
  Q_OBJECT

 public:
  explicit Application(QObject* parent = nullptr);

  /**
   * @brief Song's title getter
   * @return Name of the song being played
   */
  QString song() const;
  /**
   * @brief Change the actual song
   * @param song New song's name
   */
  void setSong(const QString& song);

  /*******************
   * EVENTS HANDLING *
   *******************/

  /**
   * @brief sensor event handling
   * @param args New threshold value
   */
  void handle__box_sensor(osc::ReceivedMessageArgumentStream args);
  /**
   * @brief enable_sync event handling
   * @param args The list of the enabled tracks
   *
   * The list is under the form of a binary number indicating
   * the activated tracks.
   * For example, for an 8-tracks song with its 2nd, 4th, 5th and 8th
   * tracks activated, the number is 10011010.
   */
  void handle__box_enableSync(osc::ReceivedMessageArgumentStream args);
  /**
   * @brief beat event handling
   * @param args Server's current beat count value
   */
  void handle__box_beat(osc::ReceivedMessageArgumentStream args);
  /**
   * @brief songs_list event handling
   * @param args Songs' list
   *
   * The list is the concatenation of the songs' filenames,
   * separated by the character |
   */
  void handle__box_songsList(osc::ReceivedMessageArgumentStream args);
  /**
   * @brief title event handling
   * @param args Song's title
   */
  void handle__box_title(osc::ReceivedMessageArgumentStream args);
  /**
   * @brief tracks_list event handling
   * @param args Song's list of tracks
   *
   * The list is the concatenation of the tracks' names,
   * separated by the character |
   */
  void handle__box_tracksList(osc::ReceivedMessageArgumentStream args);
  /**
   * @brief ready event handling
   * @param args Loading state (ready or not)
   */
  void handle__box_ready(osc::ReceivedMessageArgumentStream args);
  /**
   * @brief master volume event handling
   * @param args the master volume as an int between 0 an 100 included
   */
  void handle__box_master(osc::ReceivedMessageArgumentStream args);
  /**
   * @brief track volume event handling
   * @param args the track and volume as an int between 0 an 100 included
   */
  void handle__box_volume(osc::ReceivedMessageArgumentStream args);
  /**
   * @brief track pan event handling
   * @param args the track and pan as an int between -100 an 100 included
   */
  void handle__box_pan(osc::ReceivedMessageArgumentStream args);
  /**
   * @brief track mute event handling
   * @param args the list of muted tracks as a int, where each bit indicates a
   * track's status
   */
  void handle__box_mute(osc::ReceivedMessageArgumentStream args);
  /**
   * @brief track solo event handling
   * @param args the id of the track performing a solo
   */
  void handle__box_solo(osc::ReceivedMessageArgumentStream args);
  /**
   * @brief playing event handling
   * @param args wether the player is playing or stopped.
   */
  void handle__box_playing(osc::ReceivedMessageArgumentStream args);

 public slots:

  /*******************
   * SERVER'S CONTROL *
   *******************/

  /**
   * @brief delete a song on the server machine
   * this will physically remove the file
   * @param songName the name of the song to delete
   */
  void deleteSong(const QString& songName);

  /**
   * @brief Update the server's threshold value
   * @param thresh New threshold value
   *
   * Send to the server the new threshold value
   */
  void updateThreshold(int thresh);
  /**
   * @brief Start the song
   *
   * Ask the server to play the current song
   */
  void play();
  /**
   * @brief Stop the song
   *
   * Ask the server to stop the current song
   */
  void stop();
  /**
   * @brief Update the server's master volume
   * @param vol New volume
   *
   * Send to the server the new master volume
   */
  void updateMasterVolume(int vol);
  /**
   * @brief Reset the current song's settings on the server
   *
   * Send a reset order to the server
   */
  void reset();
  /**
   * @brief Reset the server's threshold
   */
  void resetThreshold();
  /**
   * @brief Refresh the client songs' list
   *
   * Ask the songs' list to the server
   */
  void refreshSong();
  /**
   * @brief Change the current server's song
   * @param song New song's name
   *
   * Ask the server to change the current song
   */
  void selectSong(const QString& song);
  /**
   * @brief Reload the current server's song
   */
  void reloadSong();
  /**
   * @brief Synchronize the client's informations with the server's
   */
  void sync();

  /**
   * @brief tries to connect to the server and updates the connectionError
   * property.
   */
  void checkConnection();

  void acceptConnection();

  /******************
   * CLIENT'S UPDATE *
   *******************/

  /**
   * @brief Signals that the current song is loaded
   * @param go New ready state
   */
  void ready(bool go);

 private:
  std::shared_ptr<OscSender> m_sender =
#ifdef __arm__
      std::make_shared<OscSender>("192.170.0.1", 9988);
#else
      std::make_shared<OscSender>("127.0.0.1", 9988);
#endif

  OscReceiver m_oscReceiver{9989};

  bool m_isPlaying{false};
  double m_currentBeat = 0;

  QString m_song{""};

 private:
  Q_PROPERTY(QString currentSongTitle READ currentSongTitle WRITE
                 setCurrentSongTitle NOTIFY currentSongTitleChanged)
  Q_PROPERTY(QStringList songList READ songList WRITE setSongList NOTIFY
                 songListChanged)

  Q_PROPERTY(QQmlListProperty<Track> tracks READ tracks NOTIFY tracksChanged)

  Q_PROPERTY(QStringList trackList READ trackList WRITE setTrackList NOTIFY
                 trackListChanged)
  Q_PROPERTY(double beat READ beat WRITE setBeat NOTIFY beatChanged)
  Q_PROPERTY(int enabledTrackCount READ enabledTrackCount NOTIFY
                 enabledTrackCountChanged)
  Q_PROPERTY(bool playing READ isPlaying WRITE setPlaying NOTIFY playingChanged)

  Q_PROPERTY(
      int threshold READ threshold WRITE setThreshold NOTIFY thresholdChanged)
  Q_PROPERTY(int masterVolume READ masterVolume WRITE setMasterVolume NOTIFY
                 masterVolumeChanged)

  Q_PROPERTY(
      bool connectionError READ connectionError NOTIFY connectionErrorChanged)

  int m_enabledTrackCount = 0;
  int m_masterVolume = 0;
  int m_threshold = 49;
  bool m_connectionError = false;
  QStringList m_songList = {};
  QStringList m_trackList = {};
  QString m_currentSongTitle = QString::null;
  QList<Track*> m_tracks = {};
  QTimer m_connectionTest;

 public slots:

  void setCurrentSongTitle(const QString& title) {
    if (title != m_currentSongTitle) {
      m_currentSongTitle = title;
      emit currentSongTitleChanged();
    }
  }

  void setMasterVolume(int masterVolume) {
    if (masterVolume != m_masterVolume) {
      m_masterVolume = masterVolume;
      emit masterVolumeChanged();
    }
  }

  void setThreshold(int threshold) {
    if (threshold != m_threshold) {
      m_threshold = threshold;
      emit thresholdChanged();
    }
  }

  void setTrackList(const QStringList& trackList) {
    m_trackList = trackList;
    trackListChanged();
  }

  void setSongList(const QStringList& songList) {
    m_songList = songList;
    songListChanged();
  }

  void setPlaying(bool playing) {
    if (playing != m_isPlaying) {
      m_isPlaying = playing;
      emit playingChanged();
    }
  }

  void setBeat(double beat) {
    if (beat != m_currentBeat) {
      m_currentBeat = beat;
      emit beatChanged();
    }
  }

 public:
  bool connectionError() const { return m_connectionError; }
  int enabledTrackCount() const { return m_enabledTrackCount; }
  int masterVolume() const { return m_masterVolume; }
  int threshold() const { return m_threshold; }
  QString currentSongTitle() const { return m_currentSongTitle; }
  bool isPlaying() const { return m_isPlaying; }
  double beat() const { return m_currentBeat; }

  QQmlListProperty<Track> tracks();
  const QStringList& songList() const { return m_songList; }
  const QStringList& trackList() const { return m_trackList; }

 signals:

  void playingChanged();
  void songListChanged();
  void currentSongTitleChanged();
  void trackListChanged();
  void beatChanged();
  void thresholdChanged();
  void updateReady(bool);
  void masterVolumeChanged();
  void tracksChanged();
  void enabledTrackCountChanged();
  void connectionErrorChanged();
  void connectionEstablished();
};

#endif  // APPLICATION_H
