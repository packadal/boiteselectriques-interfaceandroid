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
    signal showImage(string imageName)

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

        Material.accent: Material.color(track.muted ? Material.DeepOrange : Material.Green)

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        height: 50
        width: 120
        checkable: true
        checked: track.activated
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
        id: soloButton
        anchors.horizontalCenter: mainButton.horizontalCenter
        anchors.top: mainButton.bottom
        checkable: true
        checked: track.solo

        Item {
            anchors.fill: parent
            anchors.margins: 8

            Image {
                anchors.fill: parent
                source: "images/ic_hearing_white_48dp.png"
                fillMode: Image.PreserveAspectFit
            }
        }

        MultiPointTouchArea {
            onPressed: track.updateSolo(!soloButton.checked)
            anchors.fill: parent
            mouseEnabled: true
            touchPoints: TouchPoint {
                id: tp2
            }
        }
    }
    //Bouton image
    Button {
        id: imageButton

        anchors.horizontalCenter: mainButton.horizontalCenter
        anchors.top: soloButton.bottom

        Item {
            anchors.fill: parent
            anchors.margins: 8

            Image {
                anchors.fill: parent
                source: "images/ic_image_white_48dp.png"
                fillMode: Image.PreserveAspectFit
            }
        }


        MultiPointTouchArea {
            onPressed: showImage(track.name)
            anchors.fill: parent
            mouseEnabled: true
            touchPoints: TouchPoint {
                id: tp3
            }
        }
    }

    //Volume Slider
    Slider {
        id: volumeSlider
        anchors.top: imageButton.bottom
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
        onValueChanged: track.updateVolume(volumeSlider.value)
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
