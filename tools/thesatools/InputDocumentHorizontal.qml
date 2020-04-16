//this file is part the thesa: tryton client based PySide2(qml2)
//__author__ = "Numael Garay"
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2

Rectangle {
    id: ien
    implicitWidth:  dpis*70
    height: tf1.height// + (1*padding)//dpis*18
    property real padding: dpis*1.4
    property real widthLabel: dpis*30
    //property real heightContent: height - heightLabel -(2*padding)
    property alias label: label1.text
    //property alias text: tf1.text
    property alias fontSize: tf1.pixelFont
    property string tipeDocument: "DNI"// DNI CUIT PASS
    color: mainroot.Material.background
    property bool boolAutoWidth: true
    property alias avalue: tf1.value // ojo solo para listViewsss
    property alias aboolAuto: tf1.boolAuto // ojo solo para listView
    radius: radiusPlus
    function getValue(){
        return tf1.getValue();
    }
    function setValue(data){
        tf1.setValue(data);
    }
    Label{
        id:label1
        text: ""
        width: !boolAutoWidth?widthLabel:paintedWidth+(2*ien.padding)
        height: tf1.height
        font.bold: true
        font.italic: true
        font.pixelSize: fontSize
        anchors{left: parent.left; leftMargin: ien.padding; verticalCenter: parent.verticalCenter}
        verticalAlignment: Label.AlignVCenter
    }
    FieldDocument{
        id:tf1
        width: parent.width- label1.width - (3*ien.padding)
        tipeDocument: ien.tipeDocument
        pixelFont: 14
        anchors{right: parent.right;rightMargin: ien.padding; verticalCenter: parent.verticalCenter}

    }

}
