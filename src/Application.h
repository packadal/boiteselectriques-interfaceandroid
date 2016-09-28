#ifndef APPLICATION_H
#define APPLICATION_H

/**
 * @file Application.h
 * @brief Application interface
 */

#include <chrono>
#include <thread>
#include <QTime>
#include <QObject>
#include <QDebug>
#include "osc/oscreceiver.h"
#include "osc/oscsender.h"
#include "osc/oscmessagegenerator.h"

/**
 * @brief The Application class
 *
 * Main program
 */
class Application : public QObject{
    Q_OBJECT

    public:
        explicit Application(QObject *parent = 0);

        /**
         * @brief Song's title getter
         * @return Name of the song being played
         */
        QString song() const;
        /**
         * @brief Change the actual song
         * @param song New song's name
         */
        void setSong(const QString &song);


        /*******************
        * EVENTS HANDLING *
        *******************/

        /**
         * @brief sensor event handling
         * @param args New threshold value
         */
        void handle__box_sensor(osc::ReceivedMessageArgumentStream args);
        /**
         * @brief enable_out event handling
         * @param args Triggered box's id
         */
        void handle__box_enableOut(osc::ReceivedMessageArgumentStream args);
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
         * @brief tracks_count event handling
         * @param args Song's tracks count
         */
        void handle__box_tracksCount(osc::ReceivedMessageArgumentStream args);
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
        void volume(int vol,int chan);
        /**
         * @brief Change a server track's pan
         * @param vol New pan
         * @param chan Track id (number)
         *
         * Send to the server the new pan of a track
         */
        void pan(int vol,int chan);
        /**
         * @brief Mute/Unmute a server's track
         * @param chan Track id (number)
         * @param state New mute state (mute = true, unmute = false)
         *
         * Send to the server the new mute state of a track
         */
        void mute(int chan,bool state);
        /**
         * @brief Solo/Unsolo a server's track
         * @param chan Track id (number)
         * @param state New solo state (solo=true, unsolo=false)
         *
         * Send to the server the new solo state of a track
         */
        void solo(int chan,bool state);
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
        void selectSong(QString song);
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
         * @brief Toggle a client's track
         * @param chan Track number
         */
        void activeBox(int chan);
        /**
         * @brief Activate a client's track
         * @param chan Track number
         */
        void checkBox(int chan);
        /**
         * @brief Deactivate a client's track
         * @param chan Track number
         */
        void uncheckBox(int chan);
        /**
         * @brief Update the client's threshold
         * @param threshold New threshold
         */
        void sendThreshold(QVariant thresholdIn);
        /**
         * @brief Update the client's current song
         * @param title New title
         */
        void sendTitle(QVariant title);
        /**
         * @brief Update the client's songs' list
         * @param list List of songs
         *
         * The list is the concatenation of the songs' filenames,
         * separated by the character |
         */
        void sendList(QVariant list);
        /**
         * @brief Update the client's current song's list of tracks
         * @param trackList New list of tracks
         *
         * The list is the concatenation of the tracks' names,
         * separated by the character |
         */
        void sendTracksList(QVariant trackList);
        /**
         * @brief Update the count of the current server's song's tracks
         * @param totalTrack
         */
        void tracksCount(QVariant totalTrack);
        /**
         * @brief Signals that the current song is loaded
         * @param go New ready state
         */
        void ready(bool go);

    private:
        OscSender m_sender{"192.170.0.1", 9988};
        OscReceiver m_oscReceiver{9989};

        bool m_isPlaying{false};
        int m_currentBeat;
        QTime m_beatsTimer{};

        QString m_song{""};

        void nextBeat(int beat= -1);
        void playBeats(int tempo);
        void decimal2BinaryInBool(int val, bool res[], int size);
        void syncBox(int val);

    signals:
        void channel0();
        void channel1();
        void channel2();
        void channel3();
        void channel4();
        void channel5();
        void channel6();
        void channel7();
        void check0();
        void check1();
        void check2();
        void check3();
        void check4();
        void check5();
        void check6();
        void check7();
        void uncheck0();
        void uncheck1();
        void uncheck2();
        void uncheck3();
        void uncheck4();
        void uncheck5();
        void uncheck6();
        void uncheck7();
        void thresholdReceive(QVariant);
        void updateBeat(QVariant);
        void updateTitle(QVariant);
        void updateList(QVariant);
        void updateTrackList(QVariant);
        void updateTotalTrack(QVariant);
        void updateReady(bool);
};

#endif // APPLICATION_H
