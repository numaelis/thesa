//this file is part the thesa: tryton client based PySide2(qml2)
//__author__ = "Numael Garay"
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2

Rectangle {
    id: ien
    implicitWidth:  240
    height: 70
    property real padding: 4*1.4
    property real heightLabel: 4*3.5
    property alias label: label1.text
    property alias labelcolor: label1.color
    color:mainroot.Material.background
    radius: miradius
    signal accepted()
    property bool boolOnDesk: false
    property bool boolBack: true
    onWidthChanged: {
        if(children[1]){
            var childrenRect = children[1];
            childrenRect.implicitHeight = height - (heightLabel + (1*padding))
            childrenRect.width = width - (2*ien.padding);
        }
    }
    onHeightChanged: {
        if(children[1]){
            var childrenRect = children[1];
            childrenRect.implicitHeight = height - (heightLabel + (1*padding))
            childrenRect.width = width - (2*ien.padding);
        }
    }

    Component.onCompleted: {
        if(children[1]){
            var childrenRect = children[1];
            childrenRect.implicitHeight = height - (heightLabel + (1*padding))
            childrenRect.width = width - (2*ien.padding);
            childrenRect.anchors.bottom = ien.bottom;
            childrenRect.anchors.horizontalCenter = ien.horizontalCenter;
        }

        if(boolOnDesk){
            onDesk();
        }
        if(!boolBack){
            ien.color= "transparent";
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
        ien.border.width= 1;
        radius = miradius+2;
        ien.border.color= Qt.darker(mainroot.Material.foreground);
        ien.color = "transparent";
    }
    function onDialog(){
        ien.border.width = 0;
        radius = miradius;
        ien.color = mainroot.Material.background;
    }

    Label{
        id:label1
        text: "label:"
        width: parent.width - (2*ien.padding)
        font.bold: true
        font.italic: true
        height: heightLabel
        elide: Label.ElideRight
        anchors{horizontalCenter: parent.horizontalCenter;top: parent.top;topMargin: ien.padding}
        verticalAlignment: Label.AlignVCenter
    }

}
