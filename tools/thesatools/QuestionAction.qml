//this file is part of Tessa
//author Numael Garay
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15
import "messages.js" as MessageLib

Dialog {
    id: dialog
    //anchors.centerIn: parent
    x: (parent.width - width) / 2
    y: (parent.height - (height))/ 2
    //    title: qsTr("Question")

    width: 300
    property string mtext: "..."
    property bool inputText: false
    property bool inputOptional: true //text required
    property bool isNotAction: false
    property bool isButtonCancel: true
    property bool isButtonNot: true
    property bool isCheckAlways: false
    property var dataCheckAlways: ({})
    property int pixelsizefont: 16
    property bool verifyPassword: false
    property string textlabel1: ""
    property string textlabel2: ""
    property string textNotMatch: ""
    property string mtitle: ""
    property bool visibleCheckAlways: false
//    property bool requiredText: true
    modal: true
    focus: true
    //standardButtons: inputText?Dialog.Close|Dialog.Apply:Dialog.Ok|Dialog.Cancel
    closePolicy: Dialog.CloseOnEscape
    Component.onCompleted: {
        if(inputText==false){
            baccaply.forceActiveFocus();
        }
    }
    header: ToolBar{
        implicitHeight: 35
        Material.foreground: Qt.darker(mainroot.Material.accent)
        Item{
            id:mh
            anchors.fill: parent
            implicitHeight: 35
            Label{
                text:mtitle//qsTr("Pregunta")
                height: 25
                anchors.centerIn: parent
                font.pixelSize: 20
                font.bold: true
                verticalAlignment: Label.AlignVCenter
                horizontalAlignment: Label.AlignHCenter
            }

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
        if(isCheckAlways){
            var dch = Object.assign(JSON.parse(JSON.stringify(dataCheckAlways)),{"check":checka.checked})
            emitActionCheck(dch);
        }
        tcloseAll.start()
    }
    signal emitAction()
    signal emitActionInput(string text)
    signal emitActionCheck(var dataCheck)
    signal emitNotAction()

    onRejected: {tcloseAll.restart()}
    function activePassword(){
        mfield.echoMode = TextInput.Password;
        mfield2.echoMode = TextInput.Password;
    }
    function acc_app(){
        if(inputText==true){
            if(mfield2.visible){
                if(mfield2.text == mfield.text){
                    dialog.applied();
                }else{
                    MessageLib.showMessage(textNotMatch, mainroot);
                    mfield.forceActiveFocus();
                }
            }else{
                dialog.applied();
            }
        }else{
            dialog.accept();
        }
    }
    function setCheckAlways(){
        checka.checked=false;
    }

    Timer{
        id:tcloseAll
        interval: 600
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
                id:bcandcanc
                text: qsTr("Cancel")
                font.bold: true
                implicitHeight: 34
                visible: isButtonCancel
                onClicked: {
                    dialog.reject();

                }
                contentItem: Text {
                    text: bcandcanc.text
                    font: bcandcanc.font

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
                id:bcandcli
                text: qsTr("No")
                font.bold: true
                implicitHeight: 34
                visible: isButtonNot
                onClicked: {
                    if(isNotAction){
                        emitNotAction();
                    }
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
                        if(isNotAction){
                            emitNotAction();
                        }
                        dialog.reject();
                    }
                    if (event.key === Qt.Key_Enter ) {
                        event.accepted = true;
                        if(isNotAction){
                            emitNotAction();
                        }
                        dialog.reject();
                    }
                }
            }

            ToolButton {
                id:baccaply

                text: qsTr("Ok")
                highlighted: true
                implicitHeight: 34
                font.bold: true
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
            visible: mtext!=""
            font.pixelSize: pixelsizefont
            wrapMode: Text.WordWrap
            maximumLineCount: 10
            font.bold: true
            padding: 4
            elide: Label.ElideRight
            //anchors.centerIn: parent
            horizontalAlignment: Text.AlignJustify
        }
        Label{
            visible: textlabel1!=""
            text: textlabel1
            font.bold: true
            color: mainroot.Material.accent
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
        }
        TextField{
            id:mfield
            //width: parent.width
            Layout.fillWidth: true
            visible: inputText
            focus: true
            onAccepted: {
                if(verifyPassword){
                    mfield2.forceActiveFocus()
                }else{
                    dialog.applied();
                }
            }
        }
        Label{
            visible: textlabel2!=""
            text: textlabel2
            font.bold: true
            color: mainroot.Material.accent
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
        }
        TextField{
            id:mfield2
            //width: parent.width
            Layout.fillWidth: true
            visible: inputText && verifyPassword
            //            focus: true
            onAccepted: {
                if(mfield.text.trim().length>0){
                    if(mfield2.text == mfield.text){
                        dialog.applied();
                    }else{
                        MessageLib.showMessage(textNotMatch, mainroot);
                        mfield.forceActiveFocus();
                    }
                }else{
                    mfield.forceActiveFocus();
                }
            }
        }
        RowLayout{
            visible: visibleCheckAlways
            CheckBox{
                id:checka
                Layout.fillWidth: true
            }
            Label{
                id:labela
                text:"Siempre Ignorar esto"
                Layout.fillWidth: true
            }
        }
    }
}
