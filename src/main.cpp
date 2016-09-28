#include "Application.h"

#include <QApplication>
#include <QQmlApplicationEngine>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    Application monapp;
    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:///main.qml")));

    //Récupération des controlleurs de piste
    QObject* pisteControllers[8];
    for (int i=0;i<8;i++)
        pisteControllers[i]= engine.rootObjects().first()->findChild<QObject*>( "Piste"+QString::number(i) );

    //De la tablette vers le udoo
    for (int i=0;i<8;i++){
        QObject::connect(pisteControllers[i]->findChild<QObject*>("MainButton"), SIGNAL(ifclicked(int)),
                         &monapp, SLOT(button(int)));
        QObject::connect(pisteControllers[i]->findChild<QObject*>("VolumeSlider"), SIGNAL(volumeChanged(int,int)),
                         &monapp, SLOT(volume(int,int)));
        QObject::connect(pisteControllers[i]->findChild<QObject*>("PanSlider"), SIGNAL(panChanged(int,int)),
                         &monapp, SLOT(pan(int,int)));
        QObject::connect(pisteControllers[i]->findChild<QObject*>("MuteButton"), SIGNAL(ifclicked(int,bool)),
                         &monapp, SLOT(mute(int,bool)));
        QObject::connect(pisteControllers[i]->findChild<QObject*>("SoloButton"), SIGNAL(ifclicked(int,bool)),
                         &monapp, SLOT(solo(int,bool)));
    }
    QObject::connect(engine.rootObjects().first()->findChild<QObject*>("New_threshold"), SIGNAL(thresholdChanged(int)),
                     &monapp, SLOT(updateThreshold(int)));
    QObject::connect(engine.rootObjects().first()->findChild<QObject*>("Play"), SIGNAL(ifclicked()),
                     &monapp, SLOT(play()));
    QObject::connect(engine.rootObjects().first()->findChild<QObject*>("Stop"), SIGNAL(ifclicked()),
                     &monapp, SLOT(stop()));
    QObject::connect(engine.rootObjects().first()->findChild<QObject*>("VolumeMasterSlider"), SIGNAL(volumeChanged(int)),
                     &monapp, SLOT(masterVolume(int)));
    QObject::connect(engine.rootObjects().first()->findChild<QObject*>("Reset"), SIGNAL(click()),
                     &monapp, SLOT(reset()));
    QObject::connect(engine.rootObjects().first()->findChild<QObject*>("Reset"), SIGNAL(click()),
                     &monapp, SLOT(resetThreshold()));
    QObject::connect(engine.rootObjects().first()->findChild<QObject*>("Reset"), SIGNAL(click()),
                     &monapp, SLOT(refreshSong())   );
    QObject::connect(engine.rootObjects().first()->findChild<QObject*>("Reload"), SIGNAL(ifclicked()),
                     &monapp, SLOT(sync()));
    QObject::connect(engine.rootObjects().first()->findChild<QObject*>("About"), SIGNAL(ifclicked()),
                     &monapp, SLOT(refreshSong()));
    QObject::connect(engine.rootObjects().first()->findChild<QObject*>("Select_song"), SIGNAL(ifselect(QString)),
                     &monapp, SLOT(selectSong(QString)));

    //Du udoo vers la tablette
        //changeActive
    QObject::connect(&monapp, SIGNAL(channel0()),
                     pisteControllers[0], SLOT(changeActive()));
    QObject::connect(&monapp, SIGNAL(channel1()),
                     pisteControllers[1], SLOT(changeActive()));
    QObject::connect(&monapp, SIGNAL(channel2()),
                     pisteControllers[2], SLOT(changeActive()));
    QObject::connect(&monapp, SIGNAL(channel3()),
                     pisteControllers[3], SLOT(changeActive()));
    QObject::connect(&monapp, SIGNAL(channel4()),
                     pisteControllers[4], SLOT(changeActive()));
    QObject::connect(&monapp, SIGNAL(channel5()),
                     pisteControllers[5], SLOT(changeActive()));
    QObject::connect(&monapp, SIGNAL(channel6()),
                     pisteControllers[6], SLOT(changeActive()));
    QObject::connect(&monapp, SIGNAL(channel7()),
                     pisteControllers[7], SLOT(changeActive()));

        //check
    QObject::connect(&monapp, SIGNAL(check0()),
                     pisteControllers[0], SLOT(setChecked()));
    QObject::connect(&monapp, SIGNAL(check1()),
                     pisteControllers[1], SLOT(setChecked()));
    QObject::connect(&monapp, SIGNAL(check2()),
                     pisteControllers[2], SLOT(setChecked()));
    QObject::connect(&monapp, SIGNAL(check3()),
                     pisteControllers[3], SLOT(setChecked()));
    QObject::connect(&monapp, SIGNAL(check4()),
                     pisteControllers[4], SLOT(setChecked()));
    QObject::connect(&monapp, SIGNAL(check5()),
                     pisteControllers[5], SLOT(setChecked()));
    QObject::connect(&monapp, SIGNAL(check6()),
                     pisteControllers[6], SLOT(setChecked()));
    QObject::connect(&monapp, SIGNAL(check7()),
                     pisteControllers[7], SLOT(setChecked()));

        //uncheck
    QObject::connect(&monapp, SIGNAL(uncheck0()),
                     pisteControllers[0], SLOT(setUnchecked()));
    QObject::connect(&monapp, SIGNAL(uncheck1()),
                     pisteControllers[1], SLOT(setUnchecked()));
    QObject::connect(&monapp, SIGNAL(uncheck2()),
                     pisteControllers[2], SLOT(setUnchecked()));
    QObject::connect(&monapp, SIGNAL(uncheck3()),
                     pisteControllers[3], SLOT(setUnchecked()));
    QObject::connect(&monapp, SIGNAL(uncheck4()),
                     pisteControllers[4], SLOT(setUnchecked()));
    QObject::connect(&monapp, SIGNAL(uncheck5()),
                     pisteControllers[5], SLOT(setUnchecked()));
    QObject::connect(&monapp, SIGNAL(uncheck6()),
                     pisteControllers[6], SLOT(setUnchecked()));
    QObject::connect(&monapp, SIGNAL(uncheck7()),
                     pisteControllers[7], SLOT(setUnchecked()));


    QObject::connect(&monapp, SIGNAL(thresholdReceive(QVariant)),
                     engine.rootObjects().first()->findChild<QObject*>("threshold"), SLOT(aff_threshold(QVariant)));
    QObject::connect(&monapp, SIGNAL(updateBeat(QVariant)),
                     engine.rootObjects().first()->findChild<QObject*>("Beat"), SLOT(aff_beat(QVariant)));
    //QObject::connect(&monapp, SIGNAL(updateTitle(QVariant)),
      //               engine.rootObjects().first()->findChild<QObject*>("Titre"), SLOT(aff_titre(QVariant)));
    QObject::connect(&monapp, SIGNAL(updateList(QVariant)),
                     engine.rootObjects().first()->findChild<QObject*>("Liste"), SLOT(aff_liste(QVariant)));
    QObject::connect(&monapp, SIGNAL(updateTotalTrack(QVariant)),
                     engine.rootObjects().first(), SLOT(totaltrack(QVariant)));
    //QObject::connect(&monapp, SIGNAL(updateReady(bool)),
      //               engine.rootObjects().first()->findChild<QObject*>("Ready"), SLOT(is_ready(bool)));
    QObject::connect(&monapp, SIGNAL(updateTrackList(QVariant)),
                     engine.rootObjects().first(), SLOT(aff_liste_track(QVariant)));

    return app.exec();
}
