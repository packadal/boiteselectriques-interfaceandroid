import QtQuick 2.7
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2
import QtQuick.Controls.Material 2.1

import ElectricalBoxes 1.0

ApplicationWindow {
    id: root
    visible: true
    width: Screen.width
    height: Screen.height
    title: qsTr("Les Boîtes Electriques")

    Material.theme: Material.Dark
    Material.primary: Material.BlueGrey
    Material.accent: Material.color(Material.Green)

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
                    target: drawerMenu
                    interactive: false
                    position: 1
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
            },
            State {
                name: "loading"
                PropertyChanges {
                    target: drawerMenu
                    interactive: true
                    position: 0
                }
                PropertyChanges {
                    target: mixing_panel
                    visible: false
                }
                PropertyChanges {
                    target: loading_indicator
                    visible: true
                }
            },
            State {
                name: "mixing"
                PropertyChanges {
                    target: drawerMenu
                    interactive: true
                    position: 0
                }
                PropertyChanges {
                    target: mixing_panel
                    visible: true
                }
                PropertyChanges {
                    target: loading_indicator
                    visible: false
                }
            }
        ]
    }

    function float2int(value) {
        return value | 0
    }

    function loadingFinished(isFinished) {
        if (isFinished)
            windowStates.state = "mixing"
    }

    Component.onCompleted: {
        app.onUpdateReady.connect(root.loadingFinished)
    }

    /************************************************/
    /*                                              */
    /*                    Naviagtion bar            */
    /*                                              */
    /************************************************/
    ToolBar {
        id: menu
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 60

        Item {
            id: changeSong
            anchors.left: parent.left
            anchors.leftMargin: 32
            width: changeSongIcon.width + changeSongText.width + 8
            height: parent.height

            Image {
                id: changeSongIcon
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                height: 48
                fillMode: Image.PreserveAspectFit
                source: "qrc:///images/ic_menu_white_48dp.png"
            }
            Text {
                id: changeSongText
                anchors.left: changeSongIcon.right
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                text: app.currentSongTitle
            }
            MouseArea {
                anchors.fill: parent
                onClicked: drawerMenu.visible = true
            }
        }

        Item {
            anchors.centerIn: parent
            width: title.width + logo.width
            Image {
                id: logo
                anchors.left: parent.left
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
            }
        }

        Text {
            id: quit
            anchors.right: parent.right
            anchors.rightMargin: 32
            height: parent.height
            width:quitButtonMetrics.width * 2
            text: qsTr("Quitter")
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignRight

            TextMetrics {
                id: quitButtonMetrics
                text: quit.text
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
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
        anchors.right: masterVolumePane.left

        BusyIndicator {
            id: loading_indicator
            visible: false
            anchors.centerIn: parent
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
                anchors.bottom: bottomLine.top

                id: pisteControllers

                Repeater {
                    model: app.enabledTrackCount
                    delegate: PisteController {
                        track: app.tracks[index]
                    }
                }
            }

            //Ligne Play/Stop/Master/Reset
            Pane {
                id: bottomLine

                Material.elevation: 4

                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 100
                Button {
                    id: play
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    width: 100
                    height: 60
                    onClicked: app.playing ? app.stop() : app.play()
                    Image {
                        source: app.playing ? "qrc:///images/ic_stop_white_48dp.png" : "qrc:///images/ic_play_arrow_white_48dp.png"
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectFit
                    }
                }

                Row {
                    id: beatDisplay
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: play.right
                    anchors.leftMargin: 16
                    anchors.right: parent.right

                    Rectangle {
                        radius: 5
                        width: beatDisplay.width - beatDisplay.anchors.leftMargin
                        height: 30
                        color: Material.color(Material.Grey)
                        Rectangle {
                            radius: 5
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            height: parent.height
                            width:  app.beat * parent.width

                            color: Material.color(Material.Green)
                            Rectangle {
                                id: mask
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                anchors.left: parent.horizontalCenter
                                anchors.right: parent.right

                                width: parent.radius
                                color: parent.color
                            }
                        }
                    }
                }
            }
        }
    }

    Pane {
        id: masterVolumePane
        anchors.right: parent.right
        anchors.top: menu.bottom
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 32
        anchors.margins: 16
        width: 100

        Material.elevation: 4

        Slider {
            id: masterVolumeSlider
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: reset.top
            anchors.bottomMargin: 16

            focus: true
            orientation: Qt.Vertical
            smooth: true
            Layout.minimumHeight: 800
            from: 0
            to: 100
            snapMode: Slider.SnapAlways
            stepSize: 10
            value: app.masterVolume
            onValueChanged: app.updateMasterVolume(masterVolumeSlider.value)
        }

        Button {
            id: reset
            flat: true
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 60
            onClicked: app.reset()
            Image {
                source: "images/ic_refresh_white_48dp.png"
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
            }
        }
    }

    Drawer {
        id: drawerMenu
        height: parent.height
        width: 500
        edge: Qt.LeftEdge
        Column {
            anchors.fill: parent
            spacing: 4
            Label {
                width: parent.width
                text: "Sensibilite du capteur"
                font.pointSize: 18
            }
            Item {
                height: mediumSensitivityButton.height//thresholdSlider.implicitHeight + thresholdIndicator.height
                width: parent.width
                id: thresholdItem

                ButtonGroup {
                    buttons: sensitivityButtons.children
                }

                RowLayout {
                    anchors.centerIn: parent
                    id: sensitivityButtons
                    spacing: 50
                    RadioButton {
                        text: "Faible"
                        checked: app.threshold === 80
                        onCheckedChanged: {
                            if(checked)
                                app.updateThreshold(80)
                        }
                    }
                    RadioButton {
                        id: mediumSensitivityButton
                        text: "Moyenne"
                        checked: app.threshold === 40
                        onCheckedChanged: {
                            if(checked)
                                app.updateThreshold(40)
                        }
                    }
                    RadioButton {
                        text: "Haute"
                        checked: app.threshold === 0
                        onCheckedChanged: {
                            if(checked)
                                app.updateThreshold(0)
                        }
                    }
                }
            }

            // TODO this is a WIP separator
            Rectangle {
                width: parent.width
                height: 1
                color: Material.color(Material.Grey)
            }

            Label {
                width: parent.width
                height: implicitHeight
                text: "Liste des chansons"
                font.pointSize: 18

                Button {
                    visible: songListView.hasSelectedSongs
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    width: height
                    height: 24
                    flat: true
                    Image {
                        source: "qrc:///images/ic_delete_forever_white_48dp.png"
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectFit
                    }
                    onClicked: deletionConfirmation.visible = true
                }
            }

            ScrollView {
                clip: true
                width: parent.width
                height: parent.height - thresholdItem.height

                ListView {
                    // since lists in QML do not trigger events when elements are updated
                    // and using a model seems overkill, let's use another boolean property
                    property bool hasSelectedSongs: false
                    property var selectedSongs: []
                    id: songListView
                    model: app.songList
                    delegate: Button {
                        id: songButton
                        // use the 'highlighted' property to track selected items
                        property alias selected: songButton.highlighted
                        Material.accent: Material.color(Material.BlueGrey)
                        Component.onCompleted: contentItem.alignment = Qt.AlignLeft
                        text: modelData
                        flat: !highlighted
                        width: parent.width
                        height: 60
                        onClicked: {
                            windowStates.state = "loading"
                            app.selectSong(modelData)
                        }
                        onPressAndHold: {
                            var index = songListView.selectedSongs.indexOf(
                                        modelData)
                            if (index >= 0) {
                                songListView.selectedSongs.splice(index, 1)
                            } else {
                                songListView.selectedSongs.push(modelData)
                            }

                            songListView.hasSelectedSongs = songListView.selectedSongs.length > 0
                            songButton.highlighted = !songButton.highlighted
                        }
                    }
                }
            }
        }
    }
    Item {
        anchors.centerIn: parent
        width: deletionConfirmation.width
        height: deletionConfirmation.height

        Dialog {
            id: deletionConfirmation
            modal: true
            standardButtons: Dialog.Ok | Dialog.Cancel

            title: "Voulez vous vraiment supprimer ces chansons ?"
            onAccepted: {
                for (var i = 0; i < songListView.selectedSongs.length; ++i) {
                    app.deleteSong(songListView.selectedSongs[i])
                }
            }
        }
    }
    Item {
        anchors.centerIn: parent
        width: connectionErrorMessage.width
        height: connectionErrorMessage.height

        Dialog {
            TextMetrics {
                id: textMetrics
                text: connectionErrorMessage.title
                elide: Text.ElideNone
            }

            id: connectionErrorMessage
            visible: app.connectionError
            modal: true
            standardButtons: Dialog.Retry
            title: "Erreur de connection au serveur"
            contentWidth: textMetrics.boundingRect.width
            onAccepted: {
                app.checkConnection()
            }
        }
    }
}
