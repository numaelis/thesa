//this file is part of Tessa
//author Numael Garay
import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2

Dialog {
    id: dialog
    x: (mainroot.width - width) / 2
    y: (mainroot.height - (height))/ 2
    title: qsTr("Message")

    width: 300
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
