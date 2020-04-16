//this file is part the thesa: tryton client based PySide2(qml2)
//__author__ = "Numael Garay"
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2

Rectangle {
    id: ien
    implicitWidth:  240
    height: tf1.height+heightLabel + (1*padding)//dpis*18
    property real padding: 4*1.4
    property real heightLabel: 4*3.5
    //property real heightContent: height - heightLabel -(2*padding)
    property alias label: label1.text
    property alias text: tf1.text
    property alias fontSize: tf1.font.pixelSize
    property alias readOnly: tf1.readOnly
    property alias echoMode: tf1.echoMode
    //property alias heightInput: tf1.height
    color: mainroot.Material.background
    radius: miradius
    signal accepted()
    property bool boolOnDesk: false
    Component.onCompleted: {
        if(boolOnDesk){
            onDesk();
        }
    }
    onBoolOnDeskChanged: {
        if(boolOnDesk){
            onDesk();
        }else{
            onDialog();
        }
    }

    function onDesk(){
        ien.border.width= 1
        radius= miradius+2
        ien.border.color= Qt.darker(mainroot.Material.foreground)
        ien.color= "transparent"
    }
    function onDialog(){
        ien.border.width= 0
        radius= miradius
        ien.color= mainroot.Material.background
    }

    function forcefocus(){
        tf1.forceActiveFocus();
    }

    Label{
        id:label1
        text: "hello:"
        //visible: false
        width: parent.width - (2*ien.padding)
        font.bold: true
        font.italic: true
        //font.pixelSize: dpis*3
        height: heightLabel
        anchors{horizontalCenter: parent.horizontalCenter;top: parent.top;topMargin: ien.padding}
        verticalAlignment: Label.AlignVCenter
    }
    TextField{
        id:tf1
        width: parent.width - (2*ien.padding)
        //height: 30
        //height: parent.height - heightLabel - (2*ien.padding)//heightContent
        selectByMouse: !boolMovil
        onAccepted: {
            ien.accepted();
        }

        //mouseSelectionMode:
        font.pixelSize: 16
        //onTextChanged: console.log(contentHeight, height, font.pixelSize, tf1.bottomPadding, tf1.topPadding)

        anchors{horizontalCenter: parent.horizontalCenter;bottom: parent.bottom; bottomMargin: 0}//ien.padding

    }

}
