//this file is part of Thesa
//author Numael Garay
import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3

Dialog {
    id: dialog
    x: (mainroot.width - width) / 2
    y: (mainroot.height - (height))/ 2
//    title: qsTr("Message")
    width: 400
    height: 380
    property string mtext: "..."
    modal: true
    focus: true
    standardButtons: Dialog.Ok
    closePolicy: Dialog.CloseOnEscape
    onAccepted: {tcloseAll.start()}
    onRejected: {tcloseAll.start()}

    header: ToolBar{
        implicitHeight: 35
        Material.foreground: Qt.darker(mainroot.Material.accent)
        Item{
            id:mh
            anchors.fill: parent
            implicitHeight: 35
            Label{
                text:qsTr("Message")
                height: 25
                anchors.centerIn: parent
                font.pixelSize: 20
                font.bold: true
                verticalAlignment: Label.AlignVCenter
                horizontalAlignment: Label.AlignHCenter
            }

        }

    }

    Timer{
        id:tcloseAll
        interval: 800
        onTriggered: {destroy(0);}
    }
    contentItem: Pane{
        id:mp
        background: Rectangle {
            width: mp.width
            height: mp.height
            color: "transparent"
            border.color: mp.Material.background
            border.width: 1
            radius: miradius
        }

        ScrollView{
            clip:true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: contentHeight > height?ScrollBar.AlwaysOn:ScrollBar.AlwaysOff
            anchors.fill: parent
            TextArea {
                id: areaText
                //clip:true
                text: mtext
                readOnly: true
                //selectByMouse: !isMobile
                wrapMode: Text.Wrap
                font.bold: true
                padding: 4
            }
        }
    }

}
