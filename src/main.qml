import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.2
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.2

ApplicationWindow {
    id: root
    visible: true
    width: 1440
    height: 1024
    title: qsTr("Les Boîtes Electriques")
    color: "#212126"

    property int nbPistesTotal: 8

    /************************************************/
    /*                                              */
    /*                   Fonctions                  */
    /*                                              */
    /************************************************/
    //Fonctions de chargement
    function showLoading() {
        songSelector.visible = false
        loading_indicator.visible = true
        mixing_panel.visible = false
    }

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
        reset.doReset()
        volumeMasterSlider.value = 50
        for (var i = 0; i < nbPistesTotal; i++)
            idPiste(i).resetPiste()
    }

    function float2int(value) {
        return value | 0
    }

    function loadingFinished(isFinished)
    {
        if(isFinished)
            windowStates.state = "mixing";
    }

    Component.onCompleted: {
        app.sync();

        app.onUpdateReady.connect(root.loadingFinished)
    }

    /************************************************/
    /*                                              */
    /*                    Le menu                   */
    /*                                              */
    /************************************************/
    Rectangle {
        id: menu
        objectName: "Liste"
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
            objectName: "Reload"
            anchors.left: title.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            checkable: false
            onClicked: app.sync()
            style: style_reload
            iconSource: "qrc:///images/ic_refresh_white_48dp.png"
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
                onClicked: windowStates.state = "selecting";
            }
        }

        Text {
            objectName: "threshold"
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
                    delegate:
                        Button {
                        text: modelData
                        style: simpleButtonStyle
                        onClicked: {
                            doReset();
                            changeSong.text = modelData;
                            windowStates.state = "loading";
                            app.selectSong(modelData);
                        }
                        //TODO use long press to delete
                        // using MouseArea pressAndHold
                    }
                }
            }

            Button {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 16
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Cancel"
                onClicked: windowStates.state = "mixing";
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
                    tickmarksEnabled: true
                    objectName: "New_threshold"
                    orientation: Qt.Horizontal
                    smooth: true
                    implicitHeight: 50
                    implicitWidth: 600
                    minimumValue: 0
                    maximumValue: 99
                    value: app.threshold
                    onValueChanged: app.threshold = new_threshold.value
                    style: touchStyle_threshold
                    Text {
                        anchors.centerIn: parent
                        text: new_threshold.value
                        color: "white"
                    }
                }

                Button {
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: windowStates.state = "mixing"
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
                objectName: "PisteControllers"

                PisteController {
                    id: piste0
                    trackID: 0
                    checked: app.channel0
                    objectName: "Piste0"
                }
                PisteController {
                    id: piste1
                    trackID: 1
                    checked: app.channel1
                    objectName: "Piste1"
                }
                PisteController {
                    id: piste2
                    trackID: 2
                    checked: app.channel2
                    objectName: "Piste2"
                }
                PisteController {
                    id: piste3
                    trackID: 3
                    checked: app.channel3
                    objectName: "Piste3"
                }
                PisteController {
                    id: piste4
                    trackID: 4
                    checked: app.channel4
                    objectName: "Piste4"
                }
                PisteController {
                    id: piste5
                    trackID: 5
                    checked: app.channel5
                    objectName: "Piste5"
                }
                PisteController {
                    id: piste6
                    trackID: 6
                    checked: app.channel6
                    objectName: "Piste6"
                }
                PisteController {
                    id: piste7
                    trackID: 7
                    checked: app.channel7
                    objectName: "Piste7"
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
                    style: simpleButtonStyle
                    onClicked: app.playing ? app.stop() : app.play()
                    Image {
                        source: app.playing ? "qrc:///images/ic_stop_white_48dp.png" : "qrc:///images/ic_play_arrow_white_48dp.png"
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectFit
                    }
                }

                //Master
                Slider {
                    id: volumeMasterSlider
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: play.right
                    anchors.leftMargin: 32
                    anchors.right: reset.left
                    anchors.rightMargin: 32
                    focus: true
                    objectName: "VolumeMasterSlider"
                    orientation: Qt.Horizontal
                    smooth: true
                    Layout.minimumHeight: 800
                    minimumValue: 0
                    maximumValue: 100
                    value: 50
                    property bool resetValue: false //Empêche le curseur de bouger (à cause du doigt qui glisse) après un reset (double clic)
                    style: touchStyle_master
                    onValueChanged: app.masterVolume(volumeMasterSlider.value)
                    MouseArea {
                        id: volumeMasterSliderMouse
                        anchors.fill: parent
                        onPressed: {
                            volumeMasterSlider.value = float2int(
                                        mouseX / volumeMasterSlider.width * 100)
                            volumeMasterSlider.resetValue = false
                        }
                        onPositionChanged: if (volumeMasterSlider.resetValue == false)
                                               volumeMasterSlider.value = float2int(
                                                           mouseX / volumeMasterSlider.width * 100)
                        onDoubleClicked: {
                            volumeMasterSlider.value = 50
                            volumeMasterSlider.resetValue = true
                        }
                    }
                }

                Button {
                    id: reset

                    function doReset() {
                        app.reset()
                        app.resetThreshold()
                    }

                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right

                    objectName: "Reset"
                    text: "Reset"
                    width: 100
                    height: 60
                    checkable: true
                    onClicked: reset()

                    style: simpleButtonStyle
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
        ComboBoxStyle {
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
        ButtonStyle {
            background: Rectangle {
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
        ButtonStyle {
            background: Rectangle {
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
                Text {
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
        ButtonStyle {
            background: Rectangle {
                id: bg
                color: control.checked ? "darkblue" : "darkgray"
                border.color: "black"
                border.width: 2
                radius: 3
                Text {
                    text: qsTr("M")
                    color: "black"
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
    //style solo
    Component {
        id: soloStyle
        ButtonStyle {
            background: Rectangle {
                id: bg
                color: control.checked ? "yellow" : "darkgray"
                border.color: "black"
                border.width: 2
                radius: 3
                Text {
                    text: qsTr("S")
                    color: "black"
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
                        id: testing
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

    Component {
        id: style_reload
        ButtonStyle {
            background: Rectangle {
                radius: 3
                border.color: "black"
                border.width: 2
                color: control.pressed ? "darkgray" : "black"
            }
        }
    }
    //styles boutons reset
    Component {
        id: simpleButtonStyle
        ButtonStyle {
            background: Rectangle {
                radius: 3
                border.color: "black"
                border.width: 2
                color: control.pressed ? "black" : "darkgray"
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}
