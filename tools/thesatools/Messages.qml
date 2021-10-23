//this file is part of Tessa
//author Numael Garay
import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.12

Dialog {
    id: dialog
    x: (mainroot.width - width) / 2
    y: (mainroot.height - (height))/ 2
    title: qsTr("Message")

    width: 300
    property string mtext: "..."
    modal: true
    focus: true
    //    standardButtons: Dialog.Ok
    closePolicy: Dialog.CloseOnEscape
    onAccepted: {tcloseAll.start()}
    onRejected: {tcloseAll.start()}
    Component.onCompleted: {
        baccaply.forceActiveFocus();
    }

    footer: ToolBar {
        implicitHeight: 42
        background: Rectangle {
            color: "transparent"
        }
        RowLayout {
            anchors{right: parent.right;rightMargin: 8}
            spacing: 8

            ToolButton {
                id:baccaply
                text: qsTr("Ok")
//                highlighted: true
                implicitHeight: 34

                onClicked: {
                    dialog.accept();
                }
                contentItem: Text {
                    text: baccaply.text
                    font: baccaply.font
                    opacity: enabled ? 1.0 : 0.3
                    color: mainroot.Material.accent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
                Keys.onPressed: {
                    if (event.key === Qt.Key_Return ) {
                        event.accepted = true;
                        dialog.accept();
                    }
                    if (event.key === Qt.Key_Enter ) {
                        event.accepted = true;
                        dialog.accept();
                    }
                }
            }
        }
    }

    Timer{
        id:tcloseAll
        interval: 800
        onTriggered: {destroy(0);}
    }
    Label {
        id: headerText
        width: parent.width
        text: mtext
        wrapMode: Text.WordWrap
        maximumLineCount: 10
        font.bold: true
        padding: 4
        elide: Label.ElideRight
        anchors.centerIn: parent
        horizontalAlignment: Text.AlignJustify
    }
}
