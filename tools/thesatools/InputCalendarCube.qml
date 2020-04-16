//this file is part the thesa: tryton client based PySide2(qml2)
//__author__ = "Numael Garay"
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2

Rectangle {
    id: ien
    width: tf1.width + (2*padding)
    height: tf1.height+heightLabel + (1*padding)//dpis*18
    property real padding: 4*1.4
    property real heightLabel: 4*3.5
    //property real heightContent: height - heightLabel -(2*padding)
    property alias label: label1.text
    property alias title: tf1.tituloCalendario
    property alias fontSize: tf1.pixelFont
    color: mainroot.Material.background
    radius: miradius
    function setDate(data){
        tf1.setDate(data);
    }

    function getDateFechaSola(){
        return tf1.getDateFechaSola();
    }
    function getDateFechaHoraNow(){
        return tf1.getDateFechaHoraNow();
    }
    Label{
        id:label1
        text: ":"
        width: parent.width - (2*ien.padding)
        font.bold: true
        font.italic: true
        //font.pixelSize: dpis*3
        height: heightLabel
        anchors{horizontalCenter: parent.horizontalCenter;top: parent.top;topMargin: ien.padding}
        verticalAlignment: Label.AlignVCenter
    }
    FieldCalendar{
        id:tf1
        anchors{horizontalCenter: parent.horizontalCenter;bottom: parent.bottom; bottomMargin: 0}//ien.padding
    }

}
