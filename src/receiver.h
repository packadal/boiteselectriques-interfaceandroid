#ifndef RECEIVER_H
#define RECEIVER_H

#include <QObject>

#include "osc/oscreceiver.h"

class Receiver : public QObject {
  Q_OBJECT

public:
  explicit Receiver(QObject *parent = nullptr);

signals:
  void sensor(int threshold);
  void trackList(QStringList trackNames);
  void enable(int enabledMask);
  void mute(int muteMask);
  void solo(int soloMask);
  void beat(double beat);
  void title(QString title);
  void songList(QStringList trackNames);
  void ready(bool go);
  void masterVolume(int master);
  void trackVolume(int track, int volume);
  void trackPan(int track, int pan);
  void playing(bool playing);
public slots:

  void start();

private:
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
  /**
   * @brief receive the instruments images
   * @param args the number of images and then a blob containing the images
   */
  void handle__box_images(osc::ReceivedMessageArgumentStream args);

  OscReceiver m_oscReceiver{9989};
};

#endif // RECEIVER_H
