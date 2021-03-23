import QtQuick 2.3
import QtQuick.Controls.Material 2.3

Text{
    id:mflata
    height: 30
    width: 30
    font.family:fawesome.name
    font.bold: false
    font.italic: false
    font.pixelSize:height-2
    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignHCenter
    color: marea.pressed?mainroot.Material.accent:mainroot.Material.foreground
    signal clicked()
    Rectangle{
        id:rech
        anchors.fill: parent
        opacity: 0.5
        color: "gray"
        radius: width/2
        visible: false
    }

    MouseArea{
        id:marea
        hoverEnabled: true
        anchors.fill: parent
        onEntered: rech.visible=true
        onExited: rech.visible=false
        onClicked: {
           parent.clicked();
        }
    }
}
