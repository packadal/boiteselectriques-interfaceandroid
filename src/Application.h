#ifndef APPLICATION_H
#define APPLICATION_H

#include <chrono>
#include <thread>
#include <QTime>
#include <QObject>
#include <QDebug>
#include "osc/oscreceiver.h"
#include "osc/oscsender.h"
#include "osc/oscmessagegenerator.h"

class Application : public QObject
{
		Q_OBJECT

	public:
        explicit Application(QObject *parent = 0);
        void handle__box_sensor(osc::ReceivedMessageArgumentStream args);
        void handle__box_enable_out(osc::ReceivedMessageArgumentStream args);
        void handle__box_enable_sync(osc::ReceivedMessageArgumentStream args);
        void handle__box_beat(osc::ReceivedMessageArgumentStream args);
        void handle__box_play(osc::ReceivedMessageArgumentStream args);
        void handle__box_liste(osc::ReceivedMessageArgumentStream args);
        void handle__box_titre(osc::ReceivedMessageArgumentStream args);
        void handle__numb_track(osc::ReceivedMessageArgumentStream args);
        void handle__listeTrack(osc::ReceivedMessageArgumentStream args);
        void handle__ready_to_go(osc::ReceivedMessageArgumentStream args);

    public slots:
        void updatetreshold(int tresh)
        { sender.send(osc::MessageGenerator()("/box/update_treshold", tresh));}

        void buton(int chan)
        { sender.send(osc::MessageGenerator()("/box/enable", chan));}

        void volume(int vol,int chan)
        { sender.send(osc::MessageGenerator()("/box/volume", chan, vol)); }

        void pan(int vol,int chan)
        { sender.send(osc::MessageGenerator()("/box/pan", chan, vol)); }

        void mute(int chan,bool etat)
        { sender.send(osc::MessageGenerator()("/box/mute", chan, etat)); }

        void solo(int chan,bool etat)
        { sender.send(osc::MessageGenerator()("/box/solo", chan, etat)); }

        void play()
        { sender.send(osc::MessageGenerator()("/box/play", true)); }

        void stop()
        { sender.send(osc::MessageGenerator()("/box/stop", true)); isPlaying= false; currentBeat= 0;}

        void mastervolume(int vol)
        { sender.send(osc::MessageGenerator()("/box/master", vol)); }

        void reset()
        { sender.send(osc::MessageGenerator()("/box/reset", true)); isPlaying= false; currentBeat= 0;}

        void refreshsong()
        { sender.send(osc::MessageGenerator()("/box/refreshsong", true)); }

        void selectsong(QString song)
        {
            QByteArray so = song.toLatin1();
            const char *c_song = so.data();
            sender.send(osc::MessageGenerator()("/box/selectsong", c_song));
        }

        void active_box(int chan)
        {
            switch(chan)
            {
            case 0:
               emit channel0();
            break;
            case 1:
               emit channel1();
            break;
            case 2:
               emit channel2();
            break;
            case 3:
               emit channel3();
            break;
            case 4:
               emit channel4();
            break;
            case 5:
               emit channel5();
            break;
            case 6:
               emit channel6();
            break;
            case 7:
               emit channel7();
            break;
           }
        }

        void check_box(int chan)
        {
            switch(chan)
            {
            case 0:
               emit check0();
            break;
            case 1:
               emit check1();
            break;
            case 2:
               emit check2();
            break;
            case 3:
               emit check3();
            break;
            case 4:
               emit check4();
            break;
            case 5:
               emit check5();
            break;
            case 6:
               emit check6();
            break;
            case 7:
               emit check7();
            break;
           }
        }

        void uncheck_box(int chan)
        {
            switch(chan)
            {
            case 0:
               emit uncheck0();
            break;
            case 1:
               emit uncheck1();
            break;
            case 2:
               emit uncheck2();
            break;
            case 3:
               emit uncheck3();
            break;
            case 4:
               emit uncheck4();
            break;
            case 5:
               emit uncheck5();
            break;
            case 6:
               emit uncheck6();
            break;
            case 7:
               emit uncheck7();
            break;
           }
        }

        void send_treshold(QVariant treshold_in){
            emit treshold_receive(treshold_in);
        }
        void send_titre(QVariant titre){
            emit update_titre(titre);
        }
        void send_liste(QVariant liste){
            emit update_liste(liste);
        }
        void send_liste_track(QVariant listetrack){
            emit update_liste_track(listetrack);
        }
        void numb_track(QVariant totaltrack){
            emit update_totaltrack(totaltrack);
        }
        void ready_to_go(bool go){
            emit update_ready(go);
        }

    private:
        OscSender sender{"192.170.0.1", 9988};
        OscReceiver oscReceiver{9989};

        bool isPlaying{false};
        int currentBeat;
        QTime beatsTimer{};

        void nextBeat(int beat= -1);
        void playBeats(int tempo);
        void decimal2binaireInBool(int val, bool res[], int taille);
        void sync_box(int val);

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
        void treshold_receive(QVariant);
        void update_beat(QVariant);
        void update_titre(QVariant);
        void update_liste(QVariant);
        void update_liste_track(QVariant);
        void update_totaltrack(QVariant);
        void update_ready(bool);
};

#endif // APPLICATION_H
