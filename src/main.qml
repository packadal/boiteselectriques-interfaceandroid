import QtQuick 2.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.3
import QtQuick.Window 2.2
import QtQuick.Controls.Material 2.1

ApplicationWindow {
    id: root
    visible: true
    width: 1440
    height: 1024
    title: qsTr("Les Boîtes Electriques")
    color: "#212126"

    Material.accent: Material.Green

    property int nbPistesTotal: 8

    /************************************************/
    /*                                              */
    /*                   Fonctions                  */
    /*                                              */
    /************************************************/

    StateGroup {
        id: windowStates
        state: "selecting"
        states: [
            State {
                name: "selecting"
                PropertyChanges {
                    target: songSelector
                    visible: true
                }
                PropertyChanges {
                    target: mixing_panel
                    visible: false
                }
                PropertyChanges {
                    target: loading_indicator
                    visible: false
                }
                PropertyChanges {
                    target: sensitivity_threshold
                    visible: false
                }
            },
            State {
                name: "editing_threshold"
                PropertyChanges {
                    target: songSelector
                    visible: false
                }
                PropertyChanges {
                    target: mixing_panel
                    visible: false
                }
                PropertyChanges {
                    target: loading_indicator
                    visible: false
                }
                PropertyChanges {
                    target: sensitivity_threshold
                    visible: true
                }
            },
            State {
                name: "loading"
                PropertyChanges {
                    target: songSelector
                    visible: false
                }
                PropertyChanges {
                    target: mixing_panel
                    visible: false
                }
                PropertyChanges {
                    target: loading_indicator
                    visible: true
                }
                PropertyChanges {
                    target: sensitivity_threshold
                    visible: false
                }
            },
            State {
                name: "mixing"
                PropertyChanges {
                    target: songSelector
                    visible: false
                }
                PropertyChanges {
                    target: mixing_panel
                    visible: true
                }
                PropertyChanges {
                    target: loading_indicator
                    visible: false
                }
                PropertyChanges {
                    target: sensitivity_threshold
                    visible: false
                }
            }
        ]
    }

    //Renvoie l'id de la piste i
    function idPiste(i) {
        switch (i) {
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
    function soloMode(i) {
        var t

        idPiste(i).changeSolo()

        //Pour toutes les pistes
        for (t = 0; t < nbPistesTotal; t++) {
            //Si la piste n'est pas en solo, on scelle le mute
            if (!idPiste(t).getSolo()) {
                if (!idPiste(t).getMute())
                    idPiste(t).changeMute()
                if (idPiste(t).getMuteEnabled())
                    idPiste(t).changeMuteEnabled()
            }
        } //end for

        //Si aucune piste est en solo, on démute tout
        t = 0
        while (t < nbPistesTotal && !idPiste(t).getSolo())
            t++
        if (t > nbPistesTotal - 1)
            for (t = 0; t < nbPistesTotal; t++) {
                if (idPiste(t).getMute())
                    idPiste(t).changeMute()
                if (!idPiste(t).getMuteEnabled())
                    idPiste(t).changeMuteEnabled()
            }
    }
    //Si appuie sur reset
    function doReset() {
        app.reset()
        app.resetThreshold()
        masterVolumeSlider.value = 50
        for (var i = 0; i < nbPistesTotal; i++)
            idPiste(i).resetPiste()
    }

    function float2int(value) {
        return value | 0
    }

    function loadingFinished(isFinished) {
        if (isFinished)
            windowStates.state = "mixing"
    }

    Component.onCompleted: {
        app.sync()

        app.onUpdateReady.connect(root.loadingFinished)
    }

    /************************************************/
    /*                                              */
    /*                    Le menu                   */
    /*                                              */
    /************************************************/
    Rectangle {
        id: menu
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 60
        color: "black"

        Image {
            id: logo
            anchors.left: parent.left
            anchors.leftMargin: 32
            anchors.verticalCenter: parent.verticalCenter
            source: "qrc:///images/logo_80.png"
            smooth: true
            sourceSize.width: 56
            sourceSize.height: 56
        }

        Text {
            id: title
            anchors.left: logo.right
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("Les Boîtes Electriques")
            color: "white"
        }

        // Reset
        Button {
            id: reload
            anchors.left: title.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            onClicked: app.sync()
            width: reloadIcon.implicitWidth
            focusPolicy: Qt.NoFocus
            Image {
                id: reloadIcon
                anchors.fill: parent
                source: "images/ic_refresh_white_48dp.png"
            }

            flat: true
            display: AbstractButton.TextBesideIcon

            background: Rectangle {
                radius: 3
                border.color: "black"
                border.width: 2
                implicitWidth: 80
                implicitHeight: 50
                color: reload.pressed ? "darkgray" : "black"
            }
        }

        Item {
            id: changeSong
            anchors.centerIn: parent
            width: changeSongIcon.width + changeSongText.width + 8
            height: parent.height
            property alias text: changeSongText.text

            Image {
                id: changeSongIcon
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:///images/ic_library_music_white_24dp.png"
            }
            Text {
                id: changeSongText
                anchors.left: changeSongIcon.right
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                text: app.currentSongTitle
                color: "white"
            }
            MouseArea {
                anchors.fill: parent
                onClicked: windowStates.state = "selecting"
            }
        }

        Text {
            id: threshold_value

            anchors.right: quit.left
            anchors.rightMargin: 32

            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("Sensibilité: ") + app.threshold
            color: "white"

            MouseArea {
                anchors.fill: parent
                onClicked: windowStates.state = "editing_threshold"
            }
        }

        Text {
            id: quit
            anchors.right: parent.right
            anchors.rightMargin: 32
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("Quitter")
            color: "white"
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    doReset()
                    Qt.quit()
                }
            }
        }
    }

    /************************************************/
    /*                                              */
    /*                  La console                  */
    /*                                              */
    /************************************************/
    Item {
        anchors.top: menu.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        Text {
            id: loading_indicator
            visible: false
            anchors.centerIn: parent
            text: qsTr("Chargement en cours...")
            color: "white"
            SequentialAnimation on color {
                loops: Animation.Infinite
                ColorAnimation {
                    from: "white"
                    to: "red"
                    duration: 1000
                }
                ColorAnimation {
                    from: "red"
                    to: "white"
                    duration: 1000
                }
            }
        }

        Item {
            id: songSelector
            anchors.fill: parent
            visible: true

            Flow {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 8

                Repeater {
                    model: app.songList
                    delegate: Button {
                        text: modelData
                        onClicked: {
                            doReset()
                            changeSong.text = modelData
                            windowStates.state = "loading"
                            app.selectSong(modelData)
                        }
                        onPressAndHold: app.deleteSong(modelData)
                    }
                }
            }

            Button {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 16
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Cancel"
                onClicked: windowStates.state = "mixing"
            }
        }

        Item {
            id: sensitivity_threshold
            anchors.fill: parent
            visible: false

            ColumnLayout {
                spacing: 32
                anchors.centerIn: parent
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Réglage de la sensibilité")
                    color: "white"
                }

                //Barre de réglage
                Slider {
                    focus: true
                    id: new_threshold
                    stepSize: 1
                    snapMode: Slider.NoSnap
                    orientation: Qt.Horizontal
                    smooth: true
                    implicitHeight: 50
                    implicitWidth: 600
                    from: 0
                    to: 99
                    value: app.threshold
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.bottom
                        text: new_threshold.value
                        color: "white"
                    }
                }

                Button {
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {
                        app.updateThreshold(new_threshold.value)
                        windowStates.state = "mixing"
                    }
                    text: qsTr("Valider")
                }
            }
        }

        Item {
            id: mixing_panel
            anchors.fill: parent
            anchors.margins: 32
            visible: false

            //Piste Controllers
            RowLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: beatLine.top
                anchors.bottomMargin: 32

                id: pisteControllers

                PisteController {
                    id: piste0
                    trackID: 0
                    checked: app.channel0
                }
                PisteController {
                    id: piste1
                    trackID: 1
                    checked: app.channel1
                }
                PisteController {
                    id: piste2
                    trackID: 2
                    checked: app.channel2
                }
                PisteController {
                    id: piste3
                    trackID: 3
                    checked: app.channel3
                }
                PisteController {
                    id: piste4
                    trackID: 4
                    checked: app.channel4
                }
                PisteController {
                    id: piste5
                    trackID: 5
                    checked: app.channel5
                }
                PisteController {
                    id: piste6
                    trackID: 6
                    checked: app.channel6
                }
                PisteController {
                    id: piste7
                    trackID: 7
                    checked: app.channel7
                }
            }

            //Ligne Beat
            Item {
                id: beatLine

                anchors.bottom: bottomLine.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 50

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: beatDisplay.left
                    anchors.rightMargin: 32
                    id: position
                    text: qsTr("Position :")
                    color: "white"
                }

                //Barre
                Row {
                    id: beatDisplay
                    anchors.centerIn: parent
                    Repeater {
                        model: 32
                        delegate: Rectangle {
                            width: 30
                            height: 30
                            radius: 3
                            border.color: "black"
                            border.width: 2
                            color: (index < app.beat) ? ((index % 4
                                                          == 0) ? "black" : "green") : "transparent"
                        }
                    }
                }

                Text {
                    id: name
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: beatDisplay.right
                    anchors.leftMargin: 32
                    text: app.beat + "/32"
                    color: "white"
                }
            }

            //Ligne Play/Stop/Master/Reset
            Item {
                id: bottomLine

                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 100

                Button {
                    id: play
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: 100
                    height: 60
                    flat: true
                    onClicked: app.playing ? app.stop() : app.play()
                    Image {
                        source: app.playing ? "qrc:///images/ic_stop_white_48dp.png" : "qrc:///images/ic_play_arrow_white_48dp.png"
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectFit
                    }
                }

                //Master
                Slider {
                    id: masterVolumeSlider
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: play.right
                    anchors.leftMargin: 32
                    anchors.right: reset.left
                    anchors.rightMargin: 32
                    focus: true
                    orientation: Qt.Horizontal
                    smooth: true
                    Layout.minimumHeight: 800
                    from: 0
                    to: 100
                    value: app.masterVolume
                    property bool resetValue: false //Empêche le curseur de bouger (à cause du doigt qui glisse) après un reset (double clic)
                    onValueChanged: app.updateMasterVolume(masterVolumeSlider.value)
                    MouseArea {
                        id: masterVolumeSliderMouse
                        anchors.fill: parent
                        onPressed: {
                            masterVolumeSlider.value = float2int(
                                        mouseX / masterVolumeSlider.width * 100)
                            masterVolumeSlider.resetValue = false
                        }
                        onPositionChanged: if (masterVolumeSlider.resetValue == false)
                                               masterVolumeSlider.value = float2int(
                                                           mouseX / masterVolumeSlider.width * 100)
                        onDoubleClicked: {
                            masterVolumeSlider.value = 50
                            masterVolumeSlider.resetValue = true
                        }
                    }
                }

                Button {
                    id: reset
                    flat: true
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    width: 100
                    height: 60
                    onClicked: root.doReset()
                    Image {
                        source: "images/ic_refresh_white_48dp.png"
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectFit
                    }
                }
            }
        }
    }
}
