//this file is part the thesa: tryton client based PySide2(qml2)
//__author__ = "Numael Garay"
import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.3

Rectangle {
    id: ien
    implicitWidth:  240
    height: 80
    property real padding: 4*1.4
    property real heightLabel: 4*3.5
    property alias label: label1.text
    property alias text: tf1.text
    property alias fontSize: tf1.font.pixelSize
    color: mainroot.Material.background
    radius: miradius
    property bool boolOnDesk: false
    Component.onCompleted: {
        if(boolOnDesk){
            onDesk();
        }
    }

    function onDesk(){
        ien.border.width= 1
        radius= miradius+2
        ien.border.color= Qt.darker(mainroot.Material.foreground)
        ien.color= "transparent"
    }

    Label{
        id:label1
        text: ":"
        width: parent.width - (2*ien.padding)
        font.bold: true
        font.italic: true
        height: heightLabel
        anchors{horizontalCenter: parent.horizontalCenter;top: parent.top;topMargin: ien.padding}
        verticalAlignment: Label.AlignVCenter
    }
    ScrollView {
        width: parent.width - (2*ien.padding)
        height: parent.height - label1.height - (1*padding)
        anchors{horizontalCenter: parent.horizontalCenter;bottom: parent.bottom; bottomMargin: 0}
        clip: true
        focus: true
        ScrollBar.vertical.policy: isMobile?ScrollBar.AlwaysOn:ScrollBar.AlwaysOff
        TextArea{
            id:tf1
            clip: true
            text: ""
            wrapMode: TextArea.WordWrap
            selectByMouse: !isMobile
            font.pixelSize: 20
        }
    }

}
