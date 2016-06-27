#include "Application.h"

Application::Application(QObject *parent) :
	QObject(parent)
{
    oscReceiver.addHandler("/box/sensor",
                            std::bind(&Application::handle__box_sensor,
                            this, std::placeholders::_1));
    oscReceiver.addHandler("/box/enable_out",
                            std::bind(&Application::handle__box_enable_out,
                            this, std::placeholders::_1));
    oscReceiver.addHandler("/box/enable_sync",
                            std::bind(&Application::handle__box_enable_sync,
                            this, std::placeholders::_1));
    oscReceiver.addHandler("/box/beat",
                            std::bind(&Application::handle__box_beat,
                            this, std::placeholders::_1));
    oscReceiver.addHandler("/box/play",
                            std::bind(&Application::handle__box_play,
                            this, std::placeholders::_1));
    oscReceiver.addHandler("/box/titre",
                            std::bind(&Application::handle__box_titre,
                            this, std::placeholders::_1));
    oscReceiver.addHandler("/box/liste",
                            std::bind(&Application::handle__box_liste,
                            this, std::placeholders::_1));
    oscReceiver.addHandler("/box/NumbTrack",
                            std::bind(&Application::handle__numb_track,
                            this, std::placeholders::_1));
    oscReceiver.addHandler("/box/ready_to_go",
                            std::bind(&Application::handle__ready_to_go,
                            this, std::placeholders::_1));
    oscReceiver.addHandler("/box/listeTrack",
                            std::bind(&Application::handle__listeTrack,
                            this, std::placeholders::_1));

    oscReceiver.run();

    beatsTimer.start();
}

void Application::handle__box_sensor(osc::ReceivedMessageArgumentStream args)
{
    osc::int32 treshold_in;
    args >> treshold_in;
    send_treshold(QString::number(treshold_in));
}

void Application::handle__listeTrack(osc::ReceivedMessageArgumentStream args)
{
    const char *listeT;
    args >> listeT;
    send_liste_track(listeT);
}

void Application::handle__box_enable_out(osc::ReceivedMessageArgumentStream args)
{
    osc::int32 box;
    args >> box;
    active_box(box);
}

void Application::handle__box_enable_sync(osc::ReceivedMessageArgumentStream args)
{
    osc::int32 val;
    args >> val;
    sync_box(val);
}

void Application::handle__box_beat(osc::ReceivedMessageArgumentStream args)
{
    osc::int32 beat;
    args >> beat;

    qDebug() << beat;
    //nextBeat((int)beat);
}

void Application::handle__box_play(osc::ReceivedMessageArgumentStream args){
    beatsTimer.restart();
    osc::int32 tempo;
    args >> tempo;
    tempo= (int)tempo;

    isPlaying= true;
    std::thread (&Application::playBeats, this, tempo).detach();
}

void Application::handle__box_titre(osc::ReceivedMessageArgumentStream args)
{
    const char *titre;
    args >> titre;
    send_titre(titre);
}

void Application::handle__box_liste(osc::ReceivedMessageArgumentStream args)
{
    const char *liste;
    args >> liste;
    send_liste(liste);
}

void Application::handle__numb_track(osc::ReceivedMessageArgumentStream args)
{
    osc::int32 totaltrack;
    args >> totaltrack;
    numb_track(QString::number(totaltrack));
}

void Application::handle__ready_to_go(osc::ReceivedMessageArgumentStream args)
{
    bool go;
    args >> go;
    ready_to_go(go);
}

void Application::nextBeat(int beat){
    beatsTimer.restart();
    if(beat >= 0)
        currentBeat= beat;

    emit update_beat(++currentBeat);
    qDebug() << currentBeat;
    if(currentBeat >= 32) currentBeat= 0;
}

void Application::playBeats(int tempo){
    qDebug() << tempo;
    double intervalBeats= 60/(double)tempo*1000; //ms
    double timeLeftToNext;

    nextBeat(0);
    while(isPlaying){
        timeLeftToNext= intervalBeats - beatsTimer.elapsed();
        if(timeLeftToNext <= 0){
            nextBeat(-1);
            beatsTimer.addMSecs(-timeLeftToNext);
        }else
            if(timeLeftToNext > 10)
                std::this_thread::sleep_for(std::chrono::milliseconds((int)timeLeftToNext*99/100));
    }
    update_beat(0);
}

void Application::decimal2binaireInBool(int val, bool res[], int taille){
    int p;
    for(int i= taille; i>0; i--){
        res[i]= false;
        p= (int)pow(2,i);

        if(p <= val){
            res[i]= true;
            val-= p;
        }
    }
    if(val == 1)
        res[0]= true;
    else
        res[0]= false;
}

void Application::sync_box(int val){
    //Récupération des valeurs de la UDOO
    int taille= 8;
    bool enables[taille];
    decimal2binaireInBool(val, enables, taille);

    //Transfert vers la tablette
    for(int i= 0; i < taille; i++){
        if(enables[i])
            check_box(i);
        else
            uncheck_box(i);
    }
}
