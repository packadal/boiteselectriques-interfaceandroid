import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1

Column{
    width:100; height: 510
    spacing: 10

    //Bouton actif
    Rectangle {
        width:100; height: 70
        color: "transparent"
        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            id: mainButton
            signal ifclicked (int chan)
            objectName: "MainButton"
            width: 150
            height: 50
            checkable: true
            onClicked: mainButton.ifclicked(parentNumber())
            Component.onCompleted: mainButton.style=bt_out
            onCheckedChanged: mainButton.checked ? mainButton.style=bt_in : mainButton.style=bt_out
            Text {
                id: nomPiste
                anchors.centerIn: parent
                width: parent.width - 3
                horizontalAlignment: Text.AlignHCenter
                wrapMode : Text.WordWrap
            }
        }
    }

    //Volume Slider
    Rectangle {
        width: 100; height: 350
        color: "transparent"
        Slider {
            anchors.horizontalCenter: parent.horizontalCenter
            focus: false
            id: volumeSlider
            signal volumeChanged (int val,int chan)
            objectName: "VolumeSlider"
            orientation: Qt.Vertical
            smooth: true
            Layout.minimumHeight: 350
            minimumValue: 0
            maximumValue: 100
            value: 50
            property bool resetValue: false //Empêche le curseur de bouger (à cause du doigt qui glisse) après un reset (double clic)
            style: touchStyle
            onValueChanged: volumeSlider.volumeChanged(volumeSlider.value,parentNumber())
        }
        MouseArea{
            id: volumeSliderMouse
            anchors.fill: parent
            onPressed: {volumeSlider.value= -float2int(mouseY/volumeSlider.height*100) + 100; volumeSlider.resetValue= false}
            onPositionChanged: if(volumeSlider.resetValue == false)
                    volumeSlider.value= -float2int(mouseY/volumeSlider.height*100) + 100
            onDoubleClicked: {volumeSlider.value= 50; volumeSlider.resetValue= true}
        }
    }

    //Pan Slider
    Rectangle {
        width: 100; height: 30
        color: "transparent"
        Slider {
            anchors.horizontalCenter: parent.horizontalCenter
            focus: true
            id: panSlider
            signal panChanged (int val,int chan)
            objectName: "PanSlider"
            orientation: Qt.Horizontal
            smooth: true
            Layout.minimumHeight: 100
            minimumValue: -100
            maximumValue: 100
            value: 0
            property bool resetValue: false //Empêche le curseur de bouger (à cause du doigt qui glisse) après un reset (double clic)
            style: panStyle
            onValueChanged: panSlider.panChanged(panSlider.value,parentNumber())
        }
        MouseArea{
            id: panSliderMouse
            anchors.fill: parent
            onPressed: {panSlider.value= float2int(mouseX/panSlider.width*200) - 100; panSlider.resetValue= false}
            onPositionChanged: if(panSlider.resetValue == false)
                                   panSlider.value= float2int(mouseX/panSlider.width*200) - 100
            onDoubleClicked: {panSlider.value= 0; panSlider.resetValue= true}
        }
    }

    //Mute & Solo Buttons
    Rectangle{
        width: 100; height: 30
        color: "transparent"
        //Mute
        Button{
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            x:0
            id: muteButton
            signal ifclicked (int chan, bool etat)
            objectName: "MuteButton"
            width: 50
            height: 30
            checkable: true
            style: muteStyle
            onClicked: muteButton.ifclicked(parentNumber(),muteButton.checked);
        }
        //Solo
        Button{
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            x: 50
            id: soloButton
            signal ifclicked (int chan, bool etat)
            objectName: "SoloButton"
            width: 50
            height: 30
            checkable: true
            style: soloStyle
            onClicked: soloButton.ifclicked(parentNumber(),soloButton.checked)
            onCheckedChanged: solo(parentNumber())
        }
    }

    function enable(){
        mainButton.enabled=true
        mainButton.opacity=1
        volumeSlider.enabled=true
        volumeSlider.opacity=1
        volumeSlider.style=touchStyle
        panSlider.enabled=true
        panSlider.opacity=1
        muteButton.enabled=true
        muteButton.opacity=1
        soloButton.enabled=true
        soloButton.opacity=1
    }
    function disable(){
        mainButton.enabled=false
        mainButton.opacity=0.1
        mainButton.text=""
        volumeSlider.enabled=false
        volumeSlider.opacity=0.1
        volumeSlider.style=touchStyle_disabled
        panSlider.enabled=false
        panSlider.opacity=0.1
        muteButton.enabled=false
        muteButton.opacity=0.1
        soloButton.enabled=false
        soloButton.opacity=0.1
    }

    function parentNumber(){
        switch(objectName){
        case "Piste0":
            return 0
        case "Piste1":
            return 1
        case "Piste2":
            return 2
        case "Piste3":
            return 3
        case "Piste4":
            return 4
        case "Piste5":
            return 5
        case "Piste6":
            return 6
        case "Piste7":
            return 7
        }
    }

    function getChecked(){ return mainButton.checked}
    function getMute(){ return muteButton.checked}
    function getMuteEnabled(){ return muteButton.enabled}
    function getSolo(){ return soloButton.checked}

    function setChecked(){ mainButton.checked= true }
    function setUnchecked(){ mainButton.checked= false }
    function changeActive(){ mainButton.checked= !mainButton.checked }
    function changeMute(){ muteButton.checked= !muteButton.checked }
    function changeMuteEnabled(){ muteButton.enabled= !muteButton.enabled}
    function changeSolo(){
        if(getSolo()){
            mainButton.checked= true
            muteButton.checked= false
            muteButton.enabled= false
            volumeSlider.style=touchStyle_solo
        }else{
            muteButton.enabled= true
            volumeSlider.style=touchStyle
        }
    }
    function changeVolume(val){ volumeSlider.value= val }
    function changePan(val){ panSlider.value= val }
    function changeText(txt){ nomPiste.text= txt }

    function resetPiste(){
        mainButton.checked= false
        muteButton.checked= false
        muteButton.enabled= true
        soloButton.checked= false
        volumeSlider.style=touchStyle
        changeVolume(50)
        changePan(0)
    }
}
