//this file is part of Tessa
//author Numael Garay
import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3

Dialog {
    id: dialog
    anchors.centerIn: parent
    title: qsTr("Question")

    width: 300
    property string mtext: "..."
    property bool inputText: false
    modal: true
    focus: true
    standardButtons: inputText?Dialog.Close|Dialog.Apply:Dialog.Ok|Dialog.Cancel
    closePolicy: Dialog.CloseOnEscape
    onApplied: {
        if(mfield.text.trim().length>0){
            accept();
        }else{
            mfield.forceActiveFocus();
        }
    }
    onAccepted: {
        emitAction();
        if(inputText==true){
            emitActionInput(mfield.text)
        }
        tcloseAll.start()}
    signal emitAction()
    signal emitActionInput(string text)
    onRejected: {tcloseAll.start()}

    function activePassword(){
            mfield.echoMode = TextInput.Password;
    }

    Timer{
        id:tcloseAll
        interval: 800
        onTriggered: {destroy(0);}
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
                dialog.accept();
            }
        }
    }
}
