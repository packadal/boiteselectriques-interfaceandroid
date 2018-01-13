import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.4

import ElectricalBoxes 1.0

Item {
    id: trackController
    width: 150
    anchors.top: parent.top
    anchors.bottom: parent.bottom

    property var track

    state: track.enabled ? "enabled" : "disabled"
    states: [
        State {
            name: "enabled"
            PropertyChanges {
                target: mainButton
                enabled: true
                opacity: 1
            }
            PropertyChanges {
                target: volumeSlider
                enabled: true
                opacity: 1
                style: touchStyle
            }
            PropertyChanges {
                target: panSlider
                enabled: true
                opacity: 1
            }
            PropertyChanges {
                target: muteButton
                enabled: true
                opacity: 1
            }
            PropertyChanges {
                target: soloButton
                enabled: true
                opacity: 1
            }
        },
        State {
            name: "disabled"
            PropertyChanges {
                target: mainButton
                enabled: false
                opacity: 0.1
            }
            PropertyChanges {
                target: volumeSlider
                enabled: false
                opacity: 0.1
                style: touchStyle_disabled
            }
            PropertyChanges {
                target: panSlider
                enabled: false
                opacity: 0.1
            }
            PropertyChanges {
                target: muteButton
                enabled: false
                opacity: 0.1
            }
            PropertyChanges {
                target: soloButton
                enabled: false
                opacity: 0.1
            }
        }
    ]

    //Bouton actif
    Button {
        id: mainButton
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        objectName: "MainButton"
        width: 150
        height: 50
        checkable: true
        checked: trackController.track.activated
        Component.onCompleted: mainButton.style = bt_out
        onCheckedChanged: mainButton.checked ? mainButton.style = bt_in : mainButton.style = bt_out
        MultiPointTouchArea {
            onPressed: track.updateActivated(!mainButton.checked)
            anchors.fill: parent
            mouseEnabled: true
            touchPoints: TouchPoint {
                id: tp1
            }
        }
        Text {
            id: nomPiste
            anchors.centerIn: parent
            width: parent.width - 3
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            text: track.name
        }
    }

    //Volume Slider
    Slider {
        id: volumeSlider
        anchors.top: mainButton.bottom
        anchors.topMargin: 32
        anchors.bottom: panSlider.top
        anchors.bottomMargin: 16
        anchors.horizontalCenter: parent.horizontalCenter
        focus: false
        objectName: "VolumeSlider"
        orientation: Qt.Vertical
        smooth: true
        Layout.minimumHeight: 350
        minimumValue: 0
        maximumValue: 100
        value: track.volume
        Binding {
            target: track
            property: "volume"
            value: volumeSlider.value
        }

        property bool resetValue: false //Empêche le curseur de bouger (à cause du doigt qui glisse) après un reset (double clic)
        style: touchStyle
        //        onValueChanged: track.updateVolume(volumeSlider.value)
        MouseArea {
            id: volumeSliderMouse
            anchors.fill: parent
            onPressed: {
                track.updateVolume(
                            -float2int(
                                mouseY / volumeSlider.height * 100) + 100)
                volumeSlider.resetValue = false
            }
            onPositionChanged: if (volumeSlider.resetValue == false)
                                   track.updateVolume(
                                               -float2int(
                                                   mouseY / volumeSlider.height * 100) + 100)
            onDoubleClicked: {
                track.updateVolume(50)
                volumeSlider.resetValue = true
            }
        }
    }

    //Pan Slider
    Slider {
        id: panSlider
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: buttons.top
        anchors.bottomMargin: 8
        focus: true
        objectName: "PanSlider"
        orientation: Qt.Horizontal
        smooth: true
        Layout.minimumHeight: 100
        minimumValue: -100
        maximumValue: 100
        value: track.pan
        //        onValueChanged: track.updatePan(panSlider.value)
        style: panStyle
        property bool resetValue: false //Empêche le curseur de bouger (à cause du doigt qui glisse) après un reset (double clic)
        MouseArea {
            id: panSliderMouse
            anchors.fill: parent
            onPressed: {
                track.updatePan(float2int(mouseX / panSlider.width * 200) - 100)
                panSlider.resetValue = false
            }
            onPositionChanged: if (panSlider.resetValue == false)
                                   track.updatePan(
                                               float2int(
                                                   mouseX / panSlider.width * 200) - 100)
            onDoubleClicked: {
                panSlider.value = 0
                panSlider.resetValue = true
            }
        }
    }

    //Mute & Solo Buttons
    Item {
        id: buttons
        width: 100
        height: 40
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        //Mute
        Button {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            x: 0
            id: muteButton
            objectName: "MuteButton"
            width: parent.width / 2
            height: parent.height
            checkable: true
            style: muteStyle
            checked: track.muted
            MouseArea {
                anchors.fill: parent
                onClicked: track.updateMuted(!muteButton.checked)
            }
        }
        //Solo
        Button {
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            id: soloButton
            objectName: "SoloButton"
            width: parent.width / 2
            height: parent.height
            checkable: true
            style: soloStyle
            Item {
                anchors.fill: parent
                anchors.margins: 4

                Image {
                    anchors.fill: parent
                    source: "images/ic_hearing_white_48dp.png"
                    fillMode: Image.PreserveAspectFit
                }
            }

            checked: track.solo
            MouseArea {
                anchors.fill: parent
                onClicked: track.updateSolo(!soloButton.checked)
            }
        }
    }

    /************************************************/
    /*                                              */
    /*                  StyleSheet                  */
    /*                                              */
    /************************************************/

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
            }
        }
    }
}
