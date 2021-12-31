//this file is part the thesa: tryton client based PySide2(qml2)
// template dialog edit
//__author__ = "Numael Garay"
//__copyright__ = "Copyright 2020-2021"
//__license__ = "GPL"
//__version__ = "1.0.0b"
//__maintainer__ = "Numael Garay"
//__email__ = "mantrixsoft@gmail.com"

import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.12
import thesatools 1.0
import TrytonControls 1.0

Dialog {
    id:dialogTedit
    //standardButtons: Dialog.Ok|Dialog.Cancel
    width: maxWidthDialog//boolShortWidth135?maxWidthDialog-20:500
    //anchors.centerIn: parent
    x: (parent.width - width) / 2
    y: (parent.height - (height))/ 2
    property string type: "dialogedit"
    property int idRecord: -1
    property string modelName: ""
    property bool actionOK: true
    property bool actionCancel: true
    property var myForm: -1
    property string _title: ""
    property alias contentItemForm: templateForm.contentItem
    property alias paramsPlusCreate: templateForm.paramsPlusCreate
    property QtObject dialogSearch
    title: idRecord!=-1?qsTr("Edit")+" "+_title:qsTr("New")+" "+_title
    closePolicy: Dialog.CloseOnEscape

    signal updated(var fields)
    signal created(var fields)

    signal emitActionCancel()
    signal emitActionOk()

    Component.onCompleted: {
        if(isMobile){
            padding=8;
        }
    }

    function updateTreeView(fields){
        if (dialogSearch!=null){
            dialogSearch.updateRecords([fields.id]);
        }
        updated([fields.id]);
    }
    function acceptDialogSearch(fields){
        if (dialogSearch!=null){
            dialogSearch.actionSelect(fields.id, fields);
            dialogSearch.accept();
        }
    }

    function clearValues(){
        myForm.clearValues();
    }

    onEmitActionCancel:{
        dialogTedit.reject();
    }

    onEmitActionOk:{
        if(idRecord==-1){
            myForm._preCreate();
        }else{
            myForm._preUpdate();
        }

    }

    onAccepted: {

    }

    onRejected: {
        clearValues();
    }

    modal: true
    focus: true

    onOpened: {
        myForm = contentItem;
        myForm.modelName = dialogTedit.modelName;
        myForm.idRecord = dialogTedit.idRecord;
        myForm.myParent = dialogTedit;
        myForm._initFields();
        if(idRecord!=-1){
            myForm._reload();
        }else{
            myForm.clearValues();
            myForm._forceActiveFocus();
        }
    }

    function checkRequired(){
        return true;

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
                text: isMobile?"\uf05e":qsTr("Cancel")
                Component.onCompleted: {if(isMobile){font.family=fawesome.name;font.pixelSize=20}}
                implicitHeight: 34
                visible: dialogTedit.actionCancel
                onClicked: {
                    dialogTedit.emitActionCancel();
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
                        dialogTedit.emitActionCancel();
                    }
                    if (event.key === Qt.Key_Enter ) {
                        event.accepted = true;
                        dialogTedit.emitActionCancel();
                    }
                }
            }
            ToolButton {
                id:bokdcli
                text: isMobile?"\uf00c":qsTr("Ok")
                Component.onCompleted: {if(isMobile){font.family=fawesome.name;font.pixelSize=20}}
                visible:dialogTedit.actionOK
                implicitHeight: 34
                onClicked: {
                    forceActiveFocus();
                    timerActionOk.start();
//                    dialogTedit.emitActionOk();

                }
                contentItem: Text {
                    text: bokdcli.text
                    font: bokdcli.font
                    opacity: enabled ? 1.0 : 0.3
                    color: mainroot.Material.accent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
                Keys.onPressed: {
                    if (event.key === Qt.Key_Return ) {
                        event.accepted = true;
                        forceActiveFocus();
                        timerActionOk.start();
//                        dialogTedit.emitActionOk();
                    }
                    if (event.key === Qt.Key_Enter ) {
                        event.accepted = true;
                        forceActiveFocus();
                        timerActionOk.start();
//                        dialogTedit.emitActionOk();
                    }
                }
            }
        }
    }

    Timer{
        id:timerActionOk
        interval: 100
        onTriggered: {
            dialogTedit.emitActionOk();
        }
    }

    contentItem:TemplateFormEdit{
        id:templateForm
    }
}

