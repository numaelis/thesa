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
    title: qsTr("Message")

    width: 380
    height: 380
    property string mtext: "..."
    modal: true
    focus: true
    standardButtons: Dialog.Ok
    closePolicy: Dialog.NoAutoClose
    onAccepted: {tcloseAll.start()}
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
            ScrollBar.vertical.policy: ScrollBar.AlwaysOn
            anchors.fill: parent
            TextArea {
                id: areaText
                //clip:true
                text: mtext
                readOnly: true
                selectByMouse: true//!boolMovil
                wrapMode: Text.Wrap
                font.bold: true
                padding: 4
            }
        }
    }

}
