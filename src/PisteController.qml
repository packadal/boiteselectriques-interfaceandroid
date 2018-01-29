import QtQuick 2.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.1
import QtQuick.Controls.Material 2.1

import ElectricalBoxes 1.0

Item {
    id: trackController
    width: 120
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
            }
            PropertyChanges {
                target: panDial
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
            }
            PropertyChanges {
                target: panDial
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

        Material.theme: Material.Light
        Material.accent: trackController.track.muted ? Material.DeepOrange : Material.Green

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        height: 50
        width: 120
        checkable: true
        checked: trackController.track.activated
        text: track.name
        MultiPointTouchArea {
            onPressed: track.updateActivated(!mainButton.checked)
            anchors.fill: parent
            mouseEnabled: true
            touchPoints: TouchPoint {
                id: tp1
            }
        }
    }

    Button {
        Material.theme: Material.Light

        anchors.horizontalCenter: mainButton.horizontalCenter
        anchors.top: mainButton.bottom
        id: soloButton
        checkable: true
        Item {
            anchors.fill: parent
            anchors.margins: 8

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

    //Volume Slider
    Slider {
        id: volumeSlider
        anchors.top: soloButton.bottom
        anchors.topMargin: 32
        anchors.bottom: panDial.top
        anchors.bottomMargin: 16
        anchors.horizontalCenter: parent.horizontalCenter
        width: trackController.width

        orientation: Qt.Vertical
        smooth: true
        from: 0
        to: 100
        value: track.volume
        onValueChanged: trackController.track.updateVolume(volumeSlider.value)
        snapMode: Slider.SnapAlways
        stepSize: 10
    }

    Dial {
        id: panDial
            anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8

        width: 50
        snapMode: Dial.SnapAlways
        stepSize: 25
        from: -100
        to: 100
        value: track.pan
        onValueChanged: track.updatePan(panDial.value)
        property bool resetValue: false //Empêche le curseur de bouger (à cause du doigt qui glisse) après un reset (double clic)
    }
}
