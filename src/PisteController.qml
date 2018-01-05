import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1

Item {
    id: trackController
    width: 150
    anchors.top: parent.top
    anchors.bottom: parent.bottom

    property int trackID: -1

    property alias checked: mainButton.checked

    signal volumeChanged(int volume, int channel)
    signal panChanged(int pan, int channel)
    signal mute(int channel, bool muted)
    signal solo(int channel, bool solo)
    signal toggle(int channel)

    Component.onCompleted: {
        volumeChanged.connect(app.volume)
        panChanged.connect(app.pan)
        mute.connect(app.mute)
        solo.connect(app.solo)
        toggle.connect(app.button)
    }

    //Bouton actif
    Button {
        id: mainButton
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        objectName: "MainButton"
        width: 150
        height: 50
        checkable: true
        onClicked: trackController.toggle(trackController.trackID)
        Component.onCompleted: mainButton.style = bt_out
        onCheckedChanged: mainButton.checked ? mainButton.style = bt_in : mainButton.style = bt_out
        Text {
            id: nomPiste
            anchors.centerIn: parent
            width: parent.width - 3
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
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
        value: 50
        property bool resetValue: false //Empêche le curseur de bouger (à cause du doigt qui glisse) après un reset (double clic)
        style: touchStyle
        onValueChanged: trackController.volumeChanged(volumeSlider.value,
                                                      trackController.trackID)
        MouseArea {
            id: volumeSliderMouse
            anchors.fill: parent
            onPressed: {
                volumeSlider.value = -float2int(
                            mouseY / volumeSlider.height * 100) + 100
                volumeSlider.resetValue = false
            }
            onPositionChanged: if (volumeSlider.resetValue == false)
                                   volumeSlider.value = -float2int(
                                               mouseY / volumeSlider.height * 100) + 100
            onDoubleClicked: {
                volumeSlider.value = 50
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
        value: 0
        property bool resetValue: false //Empêche le curseur de bouger (à cause du doigt qui glisse) après un reset (double clic)
        style: panStyle
        onValueChanged: trackController.panChanged(panSlider.value,
                                                   trackController.trackID)
        MouseArea {
            id: panSliderMouse
            anchors.fill: parent
            onPressed: {
                panSlider.value = float2int(
                            mouseX / panSlider.width * 200) - 100
                panSlider.resetValue = false
            }
            onPositionChanged: if (panSlider.resetValue == false)
                                   panSlider.value = float2int(
                                               mouseX / panSlider.width * 200) - 100
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
        height: 30
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        //Mute
        Button {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            x: 0
            id: muteButton
            objectName: "MuteButton"
            width: 50
            height: 30
            checkable: true
            style: muteStyle
            onClicked: trackController.mute(trackController.trackID,
                                            muteButton.checked)
        }
        //Solo
        Button {
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            x: 50
            id: soloButton
            objectName: "SoloButton"
            width: 50
            height: 30
            checkable: true
            style: soloStyle
            onClicked: trackController.solo(trackController.trackID,
                                            soloButton.checked)
            onCheckedChanged: soloMode(trackController.trackID)
        }
    }

    function enable() {
        mainButton.enabled = true
        mainButton.opacity = 1
        volumeSlider.enabled = true
        volumeSlider.opacity = 1
        volumeSlider.style = touchStyle
        panSlider.enabled = true
        panSlider.opacity = 1
        muteButton.enabled = true
        muteButton.opacity = 1
        soloButton.enabled = true
        soloButton.opacity = 1
    }
    function disable() {
        mainButton.enabled = false
        mainButton.opacity = 0.1
        mainButton.text = ""
        volumeSlider.enabled = false
        volumeSlider.opacity = 0.1
        volumeSlider.style = touchStyle_disabled
        panSlider.enabled = false
        panSlider.opacity = 0.1
        muteButton.enabled = false
        muteButton.opacity = 0.1
        soloButton.enabled = false
        soloButton.opacity = 0.1
    }

    function getChecked() {
        return mainButton.checked
    }
    function getMute() {
        return muteButton.checked
    }
    function getMuteEnabled() {
        return muteButton.enabled
    }
    function getSolo() {
        return soloButton.checked
    }

    function changeActive() {
        mainButton.checked = !mainButton.checked
    }
    function changeMute() {
        muteButton.checked = !muteButton.checked
    }
    function changeMuteEnabled() {
        muteButton.enabled = !muteButton.enabled
    }
    function changeSolo() {
        if (getSolo()) {
            mainButton.checked = true
            muteButton.checked = false
            muteButton.enabled = false
            volumeSlider.style = touchStyle_solo
        } else {
            muteButton.enabled = true
            volumeSlider.style = touchStyle
        }
    }
    function changeVolume(val) {
        volumeSlider.value = val
    }
    function changePan(val) {
        panSlider.value = val
    }
    function changeText(txt) {
        nomPiste.text = txt
    }

    function resetPiste() {
        mainButton.checked = false
        muteButton.checked = false
        muteButton.enabled = true
        soloButton.checked = false
        volumeSlider.style = touchStyle
        changeVolume(50)
        changePan(0)
    }
}
