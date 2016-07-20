import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.2
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.0

ApplicationWindow {
	visible: true
    width: 1280
    height: 800
    title: qsTr("Les Boîtes Electriques")
    color: "#212126"

    property int nbPistesTotal: 8

    /************************************************/
    /*                                              */
    /*                   Fonctions                  */
    /*                                              */
    /************************************************/
    //Fonctions de chargement
    function showLoading(){
        item_preload.visible=true
        mixwindow.visible=false
    }
    function endLoading(){
        item_preload.visible=false
        mixwindow.visible=true
    }

    //Renvoie l'id de la piste i
    function idPiste(i){
        switch(i){
        case 0:
            return piste0
        case 1:
            return piste1
        case 2:
            return piste2
        case 3:
            return piste3
        case 4:
            return piste4
        case 5:
            return piste5
        case 6:
            return piste6
        case 7:
            return piste7
        }
    }

    //Si appuie sur solo
    function solo(i) {
        var t;

        idPiste(i).changeSolo()

        //Pour toutes les pistes
        for (t=0;t<nbPistesTotal;t++){
            //Si la piste n'est pas en solo, on scelle le mute
            if(!idPiste(t).getSolo()){
                if(!idPiste(t).getMute())
                    idPiste(t).changeMute()
                if( idPiste(t).getMuteEnabled())
                    idPiste(t).changeMuteEnabled()
            }
        }//end for

        //Si aucune piste est en solo, on démute tout
        t= 0
        while(t<nbPistesTotal && !idPiste(t).getSolo())
            t++
        if(t>nbPistesTotal-1)
            for (t=0;t<nbPistesTotal;t++){
                if( idPiste(t).getMute())
                    idPiste(t).changeMute()
                if(!idPiste(t).getMuteEnabled())
                    idPiste(t).changeMuteEnabled()
            }
    }

    //Si appuie sur stop
    function disable_play() {
        play.checked = false
        play.enabled = true

        for(var i=0;i<32;i++)
            barre_mesure.itemAt(i).color="transparent"
    }

    //Si appuie sur reset
    function doReset() {
        disable_play()
        reset.ifclicked()
        volumeMasterSlider.value= 50
        for (var i=0;i<nbPistesTotal;i++)
            idPiste(i).resetPiste()
    }

    //Désactive les pistes en trop
    function totaltrack(nmb){
        for (var i=0;i<nbPistesTotal;i++){
            if(i < nmb)
                idPiste(i).enable()
            else
                idPiste(i).disable()
        }
        endLoading()
    }

    //Affiche le nom des pistes
    function aff_liste_track(liste){
        if (liste!=""){
            var aff = liste.split("|");
            for (var i=0;i<aff.length;i++)
                idPiste(i).changeText( qsTr(aff[i]) )
            for (;i<nbPistesTotal;i++)
                idPiste(i).changeText( "" )
        }
    }


    function float2int(value) { return value | 0 }

    /************************************************/
    MessageDialog {
        id: refreshsong
        signal ifclicked ()
        objectName: "Refresh"
        title: "A propos"
        text: "Copyright Rock & Chanson 2015\nVersion: b3.0"
        Component.onCompleted: visible = true
        onAccepted: {
            refreshsong.ifclicked();
            select_titre.visible=true;
            select_titre.activeFocusOnPress=true;
        }
     }

    ColumnLayout {

        /************************************************/
        /*                                              */
        /*                    Le menu                   */
        /*                                              */
        /************************************************/
        Item {
            width: 1280; height: 60
            id: menu
            Rectangle {
                anchors.fill: parent
                color:"black"
                border.color: "darkred"
                border.width: 1

                //Logo
                Rectangle {
                    color: "transparent"
                    width:56;height: 56;x: 30;y:1
                    Image {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        source: "qrc:///images/logo_80.png"
                        smooth: true
                        sourceSize.width: 56
                        sourceSize.height: 56
                    }
                }

                //Titre :
                Rectangle {
                    color: "transparent"
                    width:300;height: 60;x: 350
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        text: qsTr("Titre :")
                        color:"white"
                    }
                }

                //Les Boîtes Electriques
                Rectangle {
                    width:200;height: 60;x: 90
                    color:"transparent"
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        id: appname
                        text: qsTr("Les Boîtes Electriques")
                        color: "white"
                    }
                }

                //Liste chansons
                Rectangle {
                    id: rliste
                    objectName: "Liste"
                    color: "transparent"
                    width:300;height: 56;x: 500;y:1
                    ComboBox {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        id:select_titre
                        signal ifselect(string song)
                        objectName: "Select_song"
                        visible: false
                        focus: true
                        width: 250
                        height:56
                        style: style_combobox
                        model: ListModel {
                           id: cbitems
                           ListElement {text:"Choisir un titre"; link:""}
                        }
                        onCurrentIndexChanged:{
                            if (cbitems.get(currentIndex).link != ""){
                                showLoading()
                                doReset();
                                select_titre.ifselect( cbitems.get(currentIndex).link );
                            }
                        }
                    }
                    function aff_liste(liste){
                        doReset();
                        cbitems.clear();
                        cbitems.append({"text":"Choisir un titre", "link":""});
                        var aff = liste.split("|");
                        for (var i=0;i<aff.length;i++){
                            var aff2 = aff[i].split(".song");
                            cbitems.append({"text":aff2[0] ,"link":aff[i]});
                        }
                    }
                }

                //Sensibilité
                Rectangle {
                    id: threshold
                    objectName: "threshold"
                    color:"transparent"
                    width:200;height: 60;x: 850
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        id: threshold_value
                        text: qsTr("Sensibilité :")
                        color: "white"
                    }
                    function aff_threshold(sensor){
                        var aff_t = sensor;
                        threshold_value.text = qsTr("Sensibilité: " + aff_t);
                        new_threshold.value = aff_t;
                    }
                    MouseArea{
                        anchors.fill:parent
                        onClicked: {item_threshold.visible=true}
                    }
                }

                //Quitter
                Rectangle {
                    color:"transparent"
                    width:200;height: 60;x: 1100
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        id: quit
                        text: qsTr("Quitter")
                        color: "white"
                    }
                    MouseArea{
                        anchors.fill:parent
                        onClicked: {doReset();Qt.quit();}
                    }
                }
            }
        }

        /************************************************/
        /*                                              */
        /*                  La console                  */
        /*                                              */
        /************************************************/
        //Chargement en cours...
        Item {
            width: 1280; height: 750
            id: item_preload
            visible: false
            Rectangle {
                color: "transparent"
                width:200;height: 100;
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Chargement en cours...")
                    color:"white"
                    ColorAnimation on color { from: "white"; to: "red"; duration: 3000 }
                }
            }
        }

        //Sensibilité
        Item {
            width: 1280; height: 750
            id: item_threshold
            visible: false

            //Texte
            Rectangle {
                id: rect1
                color: "transparent"
                width:690;height: 50;y:200
                anchors.horizontalCenter: parent.horizontalCenter
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Réglage de la sensibilité")
                    color:"white"
                }
            }

            //Barre de réglage
            Rectangle {
                id: rect2
                width: 610; height: 60
                color: "transparent"
                anchors.top: rect1.bottom
                anchors.topMargin: 5
                anchors.left: rect1.left
                Slider {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    focus: true
                    id: new_threshold
                    stepSize: 1
                    tickmarksEnabled: true
                    signal thresholdChanged (int val)
                    objectName: "New_threshold"
                    orientation: Qt.Horizontal
                    smooth: true
                    implicitHeight: 50
                    implicitWidth: 600
                    minimumValue: 0
                    maximumValue: 99
                    value: 0
                    style: touchStyle_threshold
                    onValueChanged: new_threshold.thresholdChanged(new_threshold.value)
                }
            }

            //Affiche valeur sensibilité
            Rectangle {
                id: rect3
                width: 60; height: 60
                color: "transparent"
                anchors.left: rect2.right
                anchors.leftMargin: 15
                anchors.top: rect1.bottom
                anchors.topMargin: 5
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: new_threshold.value
                    color:"white"
                }
            }

            //Bouton validé ?
            Rectangle {
                id: rect4
                width: 150; height: 60
                color: "transparent"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: rect3.bottom
                anchors.topMargin: 5
                Button {
                    checkable: true
                    onClicked: {item_threshold.visible = false; threshold_value.text = qsTr("Sensibilité: " + new_threshold.value);}
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Valider")
                }
            }
         }

        //Fenêtre principale
        Item {
            width: 1280; height: 750
            id: mixwindow
            visible: false

            //Piste Controllers
            Row{
                spacing: 60
                x: 50; y: 0
                id: pisteControllers
                objectName: "PisteControllers"

                PisteController{
                    id: piste0
                    objectName: "Piste0"
                }
                PisteController{
                    id: piste1
                    objectName: "Piste1"
                }
                PisteController{
                    id: piste2
                    objectName: "Piste2"
                }
                PisteController{
                    id: piste3
                    objectName: "Piste3"
                }
                PisteController{
                    id: piste4
                    objectName: "Piste4"
                }
                PisteController{
                    id: piste5
                    objectName: "Piste5"
                }
                PisteController{
                    id: piste6
                    objectName: "Piste6"
                }
                PisteController{
                    id: piste7
                    objectName: "Piste7"
                }
            }

            //Ligne Beat
            Row{
                spacing: 0
                x: 30; y: 555

                //Position :
                Rectangle {
                    id: rtitle
                    objectName: "Titre"
                    width: 130
                    height: 30
                    color: "transparent"
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        id: title
                        text: qsTr("Position :")
                        color:"white"
                    }
                    //function aff_titre(titre){
                        //title.text = titre
                    //}
                }

                //Barre
                Repeater{
                    id: barre_mesure
                    model:32
                    delegate: Rectangle{
                        width: 30
                        height: 30
                        radius: 3
                        border.color: "black"
                        border.width: 2
                        color: "transparent"
                    }
                }

                //Compteur
                Rectangle {
                    id: beat
                    objectName: "Beat"
                    width: 100
                    height: 30
                    color: "transparent"
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        id: name
                        text: qsTr("0/32")
                        color:"white"
                    }
                    function aff_beat(arg){
                        name.text=arg+"/32"

                        if ((arg-1) == 0){
                            barre_mesure.itemAt(0).color="black"
                            for(var i=1;i<32;i++){
                                barre_mesure.itemAt(i).color="transparent"
                            }
                        }
                        if (Math.floor((arg-1) % 4)){
                           barre_mesure.itemAt(arg-1).color="green"
                        }else{
                           barre_mesure.itemAt(arg-1).color="black"
                        }
                    }
                }
            }

            //Ligne Play/Stop/Master/Reset
            Row {
                spacing: 10
                x: 30; y: 600

                //Play
                Rectangle{
                    width: 100; height: 70
                    color: "transparent"
                    Button{
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        id: play
                        signal ifclicked ()
                        objectName: "Play"
                        width: 100
                        height: 60
                        checkable: true
                        onClicked: play.ifclicked()
                        style: style_play
                        onCheckedChanged: play.enabled = false
                    }
                }

                //Stop
                Rectangle{
                    width: 100; height: 70
                    color: "transparent"
                    Button{
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        id: stop
                        signal ifclicked ()
                        objectName: "Stop"
                        width: 100
                        height: 60
                        checkable: true
                        onClicked: stop.ifclicked()
                        style: style_stop
                        onPressedChanged: disable_play()
                    }
                }

                //Master
                Rectangle {
                    width: 900; height: 70
                    color: "transparent"
                    Slider {
                        anchors.verticalCenter: parent.verticalCenter
                        focus: true
                        id: volumeMasterSlider
                        signal volumeChanged (int val)
                        objectName: "VolumeMasterSlider"
                        orientation: Qt.Horizontal
                        smooth: true
                        Layout.minimumHeight: 800
                        minimumValue: 0
                        maximumValue: 100
                        value: 50
                        property bool resetValue: false //Empêche le curseur de bouger (à cause du doigt qui glisse) après un reset (double clic)
                        style: touchStyle_master
                        onValueChanged: volumeMasterSlider.volumeChanged(volumeMasterSlider.value)
                    }
                    MouseArea{
                        id: volumeMasterSliderMouse
                        anchors.fill: parent
                        onPressed: {volumeMasterSlider.value= float2int(mouseX/volumeMasterSlider.width*100);
                            volumeMasterSlider.resetValue= false}
                        onPositionChanged: if(volumeMasterSlider.resetValue == false)
                                               volumeMasterSlider.value= float2int(mouseX/volumeMasterSlider.width*100)
                        onDoubleClicked: {volumeMasterSlider.value= 50; volumeMasterSlider.resetValue= true}
                    }
                }

                //Reset
                Rectangle{
                    width: 100; height: 70
                    color: "transparent"
                    Button{
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        id: reset
                        signal ifclicked ()
                        objectName: "Reset"
                        width: 100
                        height: 60
                        checkable: true
                        onClicked: doReset()
                        style: style_reset
                    }
                }
            }
        }
    }

    /************************************************/
    /*                                              */
    /*                  StyleSheet                  */
    /*                                              */
    /************************************************/
    //styles toolbar
    Component {
        id: style_combobox
        ComboBoxStyle{
            background: Rectangle {
                color: "black"
                width: select_titre.width
                height: select_titre.height
            }
            label: Item {
                anchors.fill: parent
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.margins: 5
                    font.pointSize: 20
                    color: "darkgreen"
                    text: control.currentText
                }
            }

        }
    }
    //styles boutons enable
    Component {
        id: bt_in
        ButtonStyle{
            background:  Rectangle {
                radius: 3
                border.color: "black"
                border.width: 2
                color: "green"
            }
         }
    }
    //styles boutons disable
    Component {
        id: bt_out
        ButtonStyle{
            background:  Rectangle {
                radius: 3
                border.color: "black"
                border.width: 2
                color: "gray"
            }
         }
    }
    //style slider volume
    Component {
        id: touchStyle
        SliderStyle {
            handle: Rectangle {
                border.color: "black"
                border.width: 2
                width: 30
                height: 60
                radius: 3
                antialiasing: true
                color: "darkgray"
            }

            groove: Item {
                implicitHeight: 60
                implicitWidth: 350
                Rectangle {
                    height: 60
                    width: parent.width
                    anchors.verticalCenter: parent.verticalCenter
                    color: "darkslategray"
                    opacity: 0.8
                    radius: 3
                    border.color: "black"
                    border.width: 2
                    Rectangle {
                        antialiasing: true
                        radius: 3
                        border.color: "black"
                        border.width: 2
                        height: parent.height
                        width: parent.width * control.value / control.maximumValue
                        color: "darkgreen"
                    }
                }
            }
        }
    }
    //style slider volume_solo
    Component {
        id: touchStyle_solo
        SliderStyle {
            handle: Rectangle {
                border.color: "black"
                border.width: 2
                width: 30
                height: 60
                radius: 3
                antialiasing: true
                color: "darkgray"
            }

            groove: Item {
                implicitHeight: 60
                implicitWidth: 350
                Rectangle {
                    height: 60
                    width: parent.width
                    anchors.verticalCenter: parent.verticalCenter
                    color: "darkslategray"
                    opacity: 0.8
                    radius: 3
                    border.color: "black"
                    border.width: 2
                    Rectangle {
                        antialiasing: true
                        radius: 3
                        border.color: "black"
                        border.width: 2
                        height: parent.height
                        width: parent.width * control.value / control.maximumValue
                        color: "yellow"
                    }
                }
            }
        }
    }
    //style slider volume_disabled
    Component {
        id: touchStyle_disabled
        SliderStyle {
            handle: Rectangle {
                width: 30
                height: 60
                radius: 3
                antialiasing: true
                color: "darkslategray"
            }

            groove: Item {
                implicitHeight: 60
                implicitWidth: 350
                Rectangle {
                    height: 60
                    width: parent.width
                    anchors.verticalCenter: parent.verticalCenter
                    color: "darkslategray"
                    opacity: 0.1
                    radius: 3
                    border.color: "black"
                    border.width: 2
                    Rectangle {
                        antialiasing: true
                        radius: 3
                        border.color: "black"
                        border.width: 2
                        height: parent.height
                        width: parent.width * control.value / control.maximumValue
                        color: "darkgreen"
                    }
                }
            }
        }
    }
    //style slider panoramique
    Component {
        id: panStyle
        SliderStyle {
            groove: Rectangle {
                implicitWidth: 100
                implicitHeight: 30
                color: "darkslategray"
                border.color: "black"
                border.width: 2
                radius: 3
                Text{
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    text: "L      |      R"
                    color: "black"
                }
            }
            handle: Rectangle {
                anchors.centerIn: parent
                color: "darkgray"
                border.color: "black"
                border.width: 2
                width: 20
                height: 30
                radius: 3
            }
        }
    }
    //style mute/solo
    Component {
        id: muteStyle
        ButtonStyle{
            background:  Rectangle {
                id: bg
                color: control.checked ? "darkblue" : "darkgray"
                border.color: "black"
                border.width: 2
                radius: 3
                Text {
                    text: qsTr("M")
                    color:"black"
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
    //style solo
    Component {
        id: soloStyle
        ButtonStyle{
            background:  Rectangle {
                id: bg
                color: control.checked ? "yellow" : "darkgray"
                border.color: "black"
                border.width: 2
                radius: 3
                Text {
                    text: qsTr("S")
                    color:"black"
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
    //style master volume
    Component {
        id: touchStyle_master
        SliderStyle {
            handle: Rectangle {
                border.color: "black"
                border.width: 2
                width: 30
                height: 60
                radius: 3
                antialiasing: true
                color: "darkgray"
            }
            groove: Item {
                implicitHeight: 60
                implicitWidth: 900
                Rectangle {
                    height: 60
                    width: parent.width
                    anchors.verticalCenter: parent.verticalCenter
                    color: "darkslategray"
                    opacity: 0.8
                    radius: 3
                    border.color: "black"
                    border.width: 2
                    Rectangle {
                        id:testing
                        antialiasing: true
                        radius: 3
                        border.color: "black"
                        border.width: 2
                        height: parent.height
                        width: parent.width * control.value / control.maximumValue
                        color: "darkgreen"
                    }
                }
            }
        }
    }
    //style threshold volume
    Component {
        id: touchStyle_threshold
        SliderStyle {
            handle: Rectangle {
                border.color: "black"
                border.width: 2
                width: 30
                height: 40
                radius: 3
                antialiasing: true
                color: "darkgray"
            }
            groove: Item {
                implicitHeight: 40
                implicitWidth: 600
                Rectangle {
                    height: 40
                    width: parent.width
                    anchors.verticalCenter: parent.verticalCenter
                    color: "darkslategray"
                    opacity: 0.8
                    radius: 3
                    border.color: "black"
                    border.width: 2
                    Rectangle {
                        antialiasing: true
                        radius: 3
                        border.color: "black"
                        border.width: 2
                        height: parent.height
                        width: parent.width * control.value / control.maximumValue
                        color: "darkgreen"
                    }
                }
            }
        }
    }
    //styles boutons play
    Component {
        id: style_play
        ButtonStyle{
            background:  Rectangle {
                id: rect
                radius: 3
                border.color: "black"
                border.width: 2
                color: control.checked ? "blue" : "darkgray"
                Text {
                    text: qsTr("Play")
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                }
             }
         }
    }
    //styles boutons stop
    Component {
        id: style_stop
        ButtonStyle{
            background:  Rectangle {
                radius: 3
                border.color: "black"
                border.width: 2
                color: control.pressed ? "black" : "darkgray"
                Text {
                    text: qsTr("Stop")
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                }
             }
         }
    }
    //styles boutons reset
    Component {
        id: style_reset
        ButtonStyle{
            background:  Rectangle {
                radius: 3
                border.color: "black"
                border.width: 2
                color: control.pressed ? "black" : "darkgray"
                Text {
                    text: qsTr("Reset")
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                }
             }
         }
    }
}
