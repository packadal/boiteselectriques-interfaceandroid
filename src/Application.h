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

#include <QDebug>
#include <QObject>
#include <QTime>
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
   * @brief play event handling
   * @param args Song's tempo
   */
  void handle__box_play(osc::ReceivedMessageArgumentStream args);
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
   * @brief Toggle a track on the server
   * @param chan Track id (number)
   *
   * Inform the server of a track's status toggling via the client
   */
  void button(int chan);
  /**
   * @brief Change a server track's volume
   * @param vol New volume
   * @param chan Track id (number)
   *
   * Send to the server the new volume of a track
   */
  void volume(int vol, int chan);
  /**
   * @brief Change a server track's pan
   * @param vol New pan
   * @param chan Track id (number)
   *
   * Send to the server the new pan of a track
   */
  void pan(int vol, int chan);
  /**
   * @brief Mute/Unmute a server's track
   * @param chan Track id (number)
   * @param state New mute state (mute = true, unmute = false)
   *
   * Send to the server the new mute state of a track
   */
  void mute(int chan, bool state);
  /**
   * @brief Solo/Unsolo a server's track
   * @param chan Track id (number)
   * @param state New solo state (solo=true, unsolo=false)
   *
   * Send to the server the new solo state of a track
   */
  void solo(int chan, bool state);
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
  void masterVolume(int vol);
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

  /******************
   * CLIENT'S UPDATE *
   *******************/

  /**
   * @brief Activate a client's track
   * @param chan Track number
   */
  void setChannel(int chan, bool enabled);
  /**
   * @brief Signals that the current song is loaded
   * @param go New ready state
   */
  void ready(bool go);

 private:
  OscSender m_sender{"127.0.0.1", 9988};
  OscReceiver m_oscReceiver{9989};

  bool m_isPlaying{false};
  int m_currentBeat = 0;
  QTime m_beatsTimer{};

  QString m_song{""};

  void syncBox(int val);

 private:
  Q_PROPERTY(QString currentSongTitle READ currentSongTitle WRITE
                 setCurrentSongTitle NOTIFY currentSongTitleChanged)
  Q_PROPERTY(QStringList songList READ songList WRITE setSongList NOTIFY
                 songListChanged)
  Q_PROPERTY(QStringList trackList READ trackList WRITE setTrackList NOTIFY
                 trackListChanged)
  Q_PROPERTY(int beat READ beat WRITE setBeat NOTIFY beatChanged)
  Q_PROPERTY(bool playing READ isPlaying WRITE setPlaying NOTIFY playingChanged)
  Q_PROPERTY(
      bool channel0 READ channel0 WRITE setChannel0 NOTIFY channel0Changed)
  Q_PROPERTY(
      bool channel1 READ channel1 WRITE setChannel1 NOTIFY channel1Changed)
  Q_PROPERTY(
      bool channel2 READ channel2 WRITE setChannel2 NOTIFY channel2Changed)
  Q_PROPERTY(
      bool channel3 READ channel3 WRITE setChannel3 NOTIFY channel3Changed)
  Q_PROPERTY(
      bool channel4 READ channel4 WRITE setChannel4 NOTIFY channel4Changed)
  Q_PROPERTY(
      bool channel5 READ channel5 WRITE setChannel5 NOTIFY channel5Changed)
  Q_PROPERTY(
      bool channel6 READ channel6 WRITE setChannel6 NOTIFY channel6Changed)
  Q_PROPERTY(
      bool channel7 READ channel7 WRITE setChannel7 NOTIFY channel7Changed)

  Q_PROPERTY(
      int threshold READ threshold WRITE setThreshold NOTIFY thresholdChanged)

  int m_threshold;
  QStringList m_songList = {};
  QStringList m_trackList = {};
  QString m_currentSongTitle = QString::null;

  bool m_channel0 = false;
  bool m_channel1 = false;
  bool m_channel2 = false;
  bool m_channel3 = false;
  bool m_channel4 = false;
  bool m_channel5 = false;
  bool m_channel6 = false;
  bool m_channel7 = false;
 public slots:

  void setCurrentSongTitle(const QString& title) {
    if (title != m_currentSongTitle) {
      m_currentSongTitle = title;
      emit currentSongTitleChanged();
    }
  }

  void setThreshold(int threshold) {
    if (threshold != m_threshold) {
      m_threshold = threshold;
      emit thresholdChanged();
      updateThreshold(m_threshold);
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

  void setBeat(int beat) {
    if (beat != m_currentBeat) {
      m_currentBeat = beat;
      emit beatChanged();
    }
  }

  void setChannel0(bool enabled) {
    if (enabled != m_channel0) {
      m_channel0 = enabled;
      emit channel0Changed();
    }
  }

  void setChannel1(bool enabled) {
    if (enabled != m_channel1) {
      m_channel1 = enabled;
      emit channel1Changed();
    }
  }

  void setChannel2(bool enabled) {
    if (enabled != m_channel2) {
      m_channel2 = enabled;
      emit channel2Changed();
    }
  }

  void setChannel3(bool enabled) {
    if (enabled != m_channel3) {
      m_channel3 = enabled;
      emit channel3Changed();
    }
  }

  void setChannel4(bool enabled) {
    if (enabled != m_channel4) {
      m_channel4 = enabled;
      emit channel4Changed();
    }
  }

  void setChannel5(bool enabled) {
    if (enabled != m_channel5) {
      m_channel5 = enabled;
      emit channel5Changed();
    }
  }

  void setChannel6(bool enabled) {
    if (enabled != m_channel6) {
      m_channel6 = enabled;
      emit channel6Changed();
    }
  }

  void setChannel7(bool enabled) {
    if (enabled != m_channel7) {
      m_channel7 = enabled;
      emit channel7Changed();
    }
  }

 public:
  int threshold() const { return m_threshold; }
  QString currentSongTitle() const { return m_currentSongTitle; }
  bool isPlaying() const { return m_isPlaying; }
  int beat() const { return m_currentBeat; }

  bool channel0() const { return m_channel0; }

  bool channel1() const { return m_channel1; }

  bool channel2() const { return m_channel2; }

  bool channel3() const { return m_channel3; }

  bool channel4() const { return m_channel4; }

  bool channel5() const { return m_channel5; }

  bool channel6() const { return m_channel6; }

  bool channel7() const { return m_channel7; }

  const QStringList& songList() const { return m_songList; }
  const QStringList& trackList() const { return m_trackList; }

 signals:

  void playingChanged();

  void channel0Changed();
  void channel1Changed();
  void channel2Changed();
  void channel3Changed();
  void channel4Changed();
  void channel5Changed();
  void channel6Changed();
  void channel7Changed();

  void songListChanged();
  void currentSongTitleChanged();
  void trackListChanged();
  void beatChanged();
  void thresholdChanged();
  void updateReady(bool);
};

#endif  // APPLICATION_H
