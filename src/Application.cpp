#include "Application.h"

#include <cmath>

Application::Application(QObject *parent) :
	QObject(parent)
{
    m_oscReceiver.addHandler("/box/sensor",
                            std::bind(&Application::handle__box_sensor,
                                      this, std::placeholders::_1));
    m_oscReceiver.addHandler("/box/enable_out",
                            std::bind(&Application::handle__box_enableOut,
                                      this, std::placeholders::_1));
    m_oscReceiver.addHandler("/box/enable_sync",
                            std::bind(&Application::handle__box_enableSync,
                                      this, std::placeholders::_1));
    m_oscReceiver.addHandler("/box/beat",
                            std::bind(&Application::handle__box_beat,
                                      this, std::placeholders::_1));
    m_oscReceiver.addHandler("/box/play",
                            std::bind(&Application::handle__box_play,
                                      this, std::placeholders::_1));
    m_oscReceiver.addHandler("/box/title",
                            std::bind(&Application::handle__box_title,
                                      this, std::placeholders::_1));
    m_oscReceiver.addHandler("/box/songs_list",
                            std::bind(&Application::handle__box_songsList,
                                      this, std::placeholders::_1));
    m_oscReceiver.addHandler("/box/tracks_count",
                            std::bind(&Application::handle__box_tracksCount,
                                      this, std::placeholders::_1));
    m_oscReceiver.addHandler("/box/ready",
                            std::bind(&Application::handle__box_ready,
                                      this, std::placeholders::_1));
    m_oscReceiver.addHandler("/box/tracks_list",
                            std::bind(&Application::handle__box_tracksList,
                                      this, std::placeholders::_1));

    m_oscReceiver.run();

    m_beatsTimer.start();
}

void Application::handle__box_sensor(osc::ReceivedMessageArgumentStream args)
{
    osc::int32 threshold_in;
    args >> threshold_in;
    sendThreshold(QString::number(threshold_in));
}

void Application::handle__box_tracksList(osc::ReceivedMessageArgumentStream args)
{
    const char *listeT;
    args >> listeT;
    sendTracksList(listeT);
}

void Application::handle__box_enableOut(osc::ReceivedMessageArgumentStream args)
{
    osc::int32 box;
    args >> box;
    activeBox(box);
}

void Application::handle__box_enableSync(osc::ReceivedMessageArgumentStream args)
{
    osc::int32 val;
    args >> val;
    syncBox(val);
}

void Application::handle__box_beat(osc::ReceivedMessageArgumentStream args)
{
    osc::int32 beat;
    args >> beat;

    qDebug() << beat;
    //nextBeat((int)beat);
}

void Application::handle__box_play(osc::ReceivedMessageArgumentStream args){
    m_beatsTimer.restart();
    osc::int32 tempo;
    args >> tempo;
    tempo= (int)tempo;

    m_isPlaying= true;
    std::thread (&Application::playBeats, this, tempo).detach();
}

void Application::handle__box_title(osc::ReceivedMessageArgumentStream args)
{
    const char *titre;
    args >> titre;
    sendTitle(titre);
}

void Application::handle__box_songsList(osc::ReceivedMessageArgumentStream args)
{
    const char *liste;
    args >> liste;
    sendList(liste);
}

void Application::handle__box_tracksCount(osc::ReceivedMessageArgumentStream args)
{
    osc::int32 totaltrack;
    args >> totaltrack;
    tracksCount(QString::number(totaltrack));
}

void Application::handle__box_ready(osc::ReceivedMessageArgumentStream args)
{
    bool go;
    args >> go;
    ready(go);
}

void Application::nextBeat(int beat){
    m_beatsTimer.restart();
    if(beat >= 0)
        m_currentBeat= beat;

    emit updateBeat(++m_currentBeat);
    qDebug() << m_currentBeat;
    if(m_currentBeat >= 32) m_currentBeat= 0;
}

void Application::playBeats(int tempo){
    qDebug() << tempo;
    double intervalBeats= 60/(double)tempo*1000; //ms
    double timeLeftToNext;

    nextBeat(0);
    while(m_isPlaying){
        timeLeftToNext= intervalBeats - m_beatsTimer.elapsed();
        if(timeLeftToNext <= 0){
            nextBeat(-1);
            m_beatsTimer.addMSecs(-timeLeftToNext);
        }else
            if(timeLeftToNext > 10)
                std::this_thread::sleep_for(
                            std::chrono::milliseconds(
                                (int)timeLeftToNext*99/100));
    }
    updateBeat(0);
}

void Application::decimal2BinaryInBool(int val, bool res[], int size){
    int p;
    for(int i= size; i>0; i--){
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

void Application::syncBox(int val){
    //Récupération des valeurs de la UDOO
    int taille= 8;
    bool enables[taille];
    decimal2BinaryInBool(val, enables, taille);

    //Transfert vers la tablette
    for(int i= 0; i < taille; i++){
        if(enables[i])
            checkBox(i);
        else
            uncheckBox(i);
    }
}
QString Application::song() const
{
    return m_song;
}

void Application::updateThreshold(int thresh)
{ m_sender.send(osc::MessageGenerator()("/box/update_threshold", thresh));}

void Application::button(int chan)
{ m_sender.send(osc::MessageGenerator()("/box/enable", chan));}

void Application::volume(int vol, int chan)
{ m_sender.send(osc::MessageGenerator()("/box/volume", chan, vol)); }

void Application::pan(int vol, int chan)
{ m_sender.send(osc::MessageGenerator()("/box/pan", chan, vol)); }

void Application::mute(int chan, bool state)
{ m_sender.send(osc::MessageGenerator()("/box/mute", chan, state)); }

void Application::solo(int chan, bool state)
{ m_sender.send(osc::MessageGenerator()("/box/solo", chan, state)); }

void Application::play()
{ m_sender.send(osc::MessageGenerator()("/box/play", true)); }

void Application::stop(){
    m_sender.send(osc::MessageGenerator()("/box/stop", true));
    m_isPlaying= false;
    m_currentBeat= 0;
}

void Application::masterVolume(int vol)
{ m_sender.send(osc::MessageGenerator()("/box/master", vol)); }

void Application::reset(){
    m_sender.send(osc::MessageGenerator()("/box/reset", true));
    m_isPlaying= false;
    m_currentBeat= 0;
}

void Application::resetThreshold()
{ m_sender.send(osc::MessageGenerator()("/box/reset_threshold", true)); }

void Application::refreshSong()
{ m_sender.send(osc::MessageGenerator()("/box/refresh_song", true)); }

void Application::selectSong(QString song)
{
    m_song = song;
    QByteArray so = song.toLatin1();
    const char *c_song = so.data();
    m_sender.send(osc::MessageGenerator()("/box/select_song", c_song));
}

void Application::reloadSong()
{ selectSong(m_song);}

void Application::sync()
{ m_sender.send(osc::MessageGenerator()("/box/sync", true)); }

void Application::activeBox(int chan)
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

void Application::checkBox(int chan)
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

void Application::uncheckBox(int chan)
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

void Application::sendThreshold(QVariant thresholdIn){
    emit thresholdReceive(thresholdIn);
}

void Application::sendTitle(QVariant title){
    emit updateTitle(title);
}

void Application::sendList(QVariant list){
    emit updateList(list);
}

void Application::sendTracksList(QVariant trackList){
    emit updateTrackList(trackList);
}

void Application::tracksCount(QVariant totalTrack){
    emit updateTotalTrack(totalTrack);
}

void Application::ready(bool go){
    emit updateReady(go);
}
