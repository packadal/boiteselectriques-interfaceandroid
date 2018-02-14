import QtQuick 2.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.3
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
        app.sync()
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
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("Quitter")
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
                    // here we consider the maximum beatCount to be 96
                    // given that 96/8 = 12, we want the spacing to be 4 in the minimal case
                    // and to grow when there are less beats
                    spacing: 4 * (13 - app.beatCount / 8)

                    Repeater {
                        model: app.beatCount / 4
                        delegate: Row {
                            id: groupRow
                            property int groupIndex: index
                            spacing: 2

                            Repeater {
                                model: 4
                                delegate: Rectangle {
                                    id: indicator
                                    property bool isLeftBorder: index === 0
                                    property bool isRightBorder: index === 3
                                    // resize the beat indicators depending on the total beat count
                                    // leave some space for the spacing every 4 indicators
                                    width: ((beatDisplay.width - beatDisplay.anchors.leftMargin
                                             - beatDisplay.spacing * (app.beatCount / 4 - 1))
                                            / app.beatCount) - groupRow.spacing * 3 / 4
                                    height: 30
                                    radius: (indicator.isLeftBorder
                                             || indicator.isRightBorder) ? 3 : 0
                                    color: Material.color(
                                               (groupRow.groupIndex * 4 + index)
                                               < app.beat ? Material.Green : Material.Grey)

                                    antialiasing: true
                                    // this rectangle masks the rounded borders to make the blocks look more unified
                                    Rectangle {
                                        id: mask
                                        anchors.top: parent.top
                                        anchors.bottom: parent.bottom
                                        anchors.left: indicator.isRightBorder ? parent.left : parent.horizontalCenter
                                        anchors.right: indicator.isLeftBorder ? parent.right : parent.horizontalCenter

                                        width: parent.radius
                                        color: parent.color
                                    }
                                }
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
            Item {
                height: thresholdSlider.implicitHeight + thresholdIndicator.height
                width: parent.width
                id: thresholdItem

                Slider {
                    focus: true
                    id: thresholdSlider
                    stepSize: 1
                    snapMode: Slider.NoSnap
                    orientation: Qt.Horizontal
                    smooth: true
                    height: 50
                    width: 300
                    from: 0
                    to: 99
                    value: app.threshold
                    onValueChanged: app.updateThreshold(thresholdSlider.value)
                    Text {
                        id: thresholdIndicator
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.bottom
                        text: "sensibilite du capteur: %1%".arg(
                                  thresholdSlider.value)
                    }
                }
            }

            // TODO this is a WIP separator
            Rectangle {
                width: parent.width
                height: 1
                color: Material.color(Material.Grey)
            }

            ScrollView {
                clip: true
                width: parent.width
                height: parent.height - thresholdItem.height

                ListView {
                    model: app.songList
                    delegate: Button {
                        Component.onCompleted: contentItem.alignment = Qt.AlignLeft

                        text: modelData
                        flat: true
                        width: parent.width
                        onClicked: {
                            windowStates.state = "loading"
                            app.selectSong(modelData)
                        }
                        onPressAndHold: app.deleteSong(modelData)
                    }
                }
            }
        }
    }
}
