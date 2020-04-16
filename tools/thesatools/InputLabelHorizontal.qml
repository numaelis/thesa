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
    property real widthLabel: dpis*20
    property bool boolAutoWidth: true
    //property real heightContent: height - heightLabel -(2*padding)
    property alias label: label1.text
    property alias text: tf1.text
    property alias fontSize: tf1.font.pixelSize
    color: mainroot.Material.background
    radius: radiusPlus

    Label{
        id:label1
        text: ""
        width: !boolAutoWidth?widthLabel:paintedWidth+(2*ien.padding)
        height: tf1.height
        font.bold: true
        font.italic: true
        //font.pixelSize: dpis*3
        anchors{left: parent.left; leftMargin: ien.padding; verticalCenter: parent.verticalCenter}
        verticalAlignment: Label.AlignVCenter
    }
    TextField{
        id:tf1
        width: parent.width- label1.width - (3*ien.padding)
        selectByMouse: !boolMovil
        font.pixelSize: 14

        anchors{right: parent.right;rightMargin: ien.padding; verticalCenter: parent.verticalCenter}

    }

}
