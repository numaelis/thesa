//this file is part of Tessa
//author Numael Garay
import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.12

Dialog {
    id: dialog
    anchors.centerIn: parent
    title: qsTr("Question")

    width: 300
    property string mtext: "..."
    property bool inputText: false
    property bool inputOptional: true
    modal: true
    focus: true
    //standardButtons: inputText?Dialog.Close|Dialog.Apply:Dialog.Ok|Dialog.Cancel
    closePolicy: Dialog.CloseOnEscape
    Component.onCompleted: {
        if(inputText==false){
            baccaply.forceActiveFocus();
        }
    }
    onApplied: {
        if(inputOptional==false){
            if(mfield.text.trim().length>0){
                accept();
            }else{
                mfield.forceActiveFocus();
            }
        }else{
            accept();
        }
    }

    onAccepted: {
        emitAction();
        if(inputText==true){
            emitActionInput(mfield.text)
        }
        tcloseAll.start()
    }
    signal emitAction()
    signal emitActionInput(string text)
    onRejected: {tcloseAll.restart()}
    function activePassword(){
            mfield.echoMode = TextInput.Password;
    }
    function acc_app(){
        if(inputText==true){
            dialog.applied();
        }else{
            dialog.accept();
        }
    }
    Timer{
        id:tcloseAll
        interval: 800
        onTriggered: {destroy(0);}
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
                id:bcandcli
                text: qsTr("Cancel")
                implicitHeight: 34

                onClicked: {
                    dialog.reject();
                }
                contentItem: Text {
                    text: bcandcli.text
                    font: bcandcli.font
                    opacity: enabled ? 1.0 : 0.3
                    color: mainroot.Material.accent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
                Keys.onPressed: {
                    if (event.key === Qt.Key_Return ) {
                        event.accepted = true;
                        dialog.reject();
                    }
                    if (event.key === Qt.Key_Enter ) {
                        event.accepted = true;
                        dialog.reject();
                    }
                }
            }
            ToolButton {
                id:baccaply
                text: qsTr("Ok")
                highlighted: true
                implicitHeight: 34

                onClicked: {
                    dialog.acc_app();
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
                        dialog.acc_app();
                    }
                    if (event.key === Qt.Key_Enter ) {
                        event.accepted = true;
                        dialog.acc_app();
                    }
                }
            }
        }
    }

    ColumnLayout{
        anchors.fill:parent
        Label {
            id: headerText
            //width: parent.width
            Layout.fillWidth: true
            text: mtext
            wrapMode: Text.WordWrap
            maximumLineCount: 10
            font.bold: true
            padding: 4
            elide: Label.ElideRight
            //anchors.centerIn: parent
            horizontalAlignment: Text.AlignJustify
        }
        TextField{
            id:mfield
            //width: parent.width
            Layout.fillWidth: true
            visible: inputText
            focus: true
            onAccepted: {
                dialog.applied();
            }
        }
    }
}
