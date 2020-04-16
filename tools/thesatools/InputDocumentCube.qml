//this file is part the thesa: tryton client based PySide2(qml2)
//__author__ = "Numael Garay"
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2

Rectangle {
    id: ien
    implicitWidth: 240
    height: tf1.height+heightLabel + (1*padding)//dpis*18
    property real padding: 4*1.4
    property real heightLabel: 4*3.5
    //property real heightContent: height - heightLabel -(2*padding)
    property alias label: label1.text
    //property alias text: tf1.text
    property alias fontSize: tf1.pixelFont
    property string tipeDocument: "DNI"// DNI CUIT PASS
    property bool boolOnDesk: true

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

    color: mainroot.Material.background
    radius: miradius

    function getValue(){
        return tf1.getValue();
    }
    function setValue(data){
        tf1.setValue(data);
    }

    Label{
        id:label1
        text: "hola:"
        width: parent.width - (2*ien.padding)
        font.bold: true
        font.italic: true
        //font.pixelSize: dpis*3
        height: heightLabel
        anchors{horizontalCenter: parent.horizontalCenter;top: parent.top;topMargin: ien.padding}
        verticalAlignment: Label.AlignVCenter
    }
    FieldDocument{
        id:tf1
        width: parent.width - (2*ien.padding) -6
        tipeDocument: ien.tipeDocument
        anchors{horizontalCenter: parent.horizontalCenter;bottom: parent.bottom; bottomMargin: 0}//ien.padding

    }

}
