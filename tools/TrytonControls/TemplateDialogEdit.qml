//this file is part the thesa: tryton client based PySide2(qml2)
// template dialog edit
//__author__ = "Numael Garay"
//__copyright__ = "Copyright 2020-2021"
//__license__ = "GPL"
//__version__ = "1.0.0b"
//__maintainer__ = "Numael Garay"
//__email__ = "mantrixsoft@gmail.com"

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15
import "../thesatools"
import "../TrytonControls"
import "../thesatools/messages.js" as MessageLib

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
    property var fields_default: []
    property QtObject dialogSearch
    property var context: ({})
    property bool closeCreate: true
    property bool closeUpdate: true
//    title: idRecord!=-1?qsTr("Edit")+" "+_title:qsTr("New")+" "+_title
    closePolicy: Dialog.NoAutoClose
    Shortcut {
            sequence: "Esc"
            onActivated: {
                _preClose();
            }
        }
    signal updated(var fields)
    signal updatedTreeView(var ids)
    signal created(var fields)

    signal signalAfter()
    signal emitActionCancel()
    signal emitActionOk()
    signal signalToolButtonNew()
    signal signalAfterOpen()
    Component.onCompleted: {
        if(isMobile){
            padding=8;
        }
    }

    function updateTreeView(fields){
        if (dialogSearch!=null){
            dialogSearch.updateRecords([fields.id]);
        }
        updatedTreeView([fields.id]);
    }
    function acceptDialogSearch(fields){
        if (dialogSearch!=null){
            dialogSearch.actionSelect(fields.id, fields);
            dialogSearch.accept();
        }
    }

    function clearValues(){
        if(myForm!=-1){
            myForm.clearValues();
        }
    }

    function isChanged(){
        if(myForm!=-1){
            return myForm.isChanged();
        }
        //qrc:/TrytonControlsIn/TemplateDialogEdit.qml:80: TypeError: Property 'isChanged' of object -1 is not a function
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
//        console.log("clear")
    }

    modal: true
    focus: true
    function deactiveReadAfterAction(){
        myForm.readAfterAction=false;
    }
    function activeReadAfterAction(){
        myForm.readAfterAction=true;
    }
    onOpened: {
        myForm = contentItem;
        myForm.modelName = dialogTedit.modelName;
        myForm.idRecord = dialogTedit.idRecord;
        myForm.myParent = dialogTedit;
        myForm._initFields();
        myForm.context = dialogTedit.context;
        if(idRecord!=-1){
            myForm._reload();
        }else{
            myForm.clearValues();
            myForm._forceActiveFocus();
            if(fields_default.length>0){
                myForm._default(fields_default);
            }
        }
        signalAfterOpen();
    }

    function formReload(){
        if(idRecord!=-1){
            myForm._reload();
        }
    }

    property bool isCloseAfter: false
    function closeAfter(){
        isCloseAfter=true;
        timerActionOk.start();
    }
    property bool isPreNewAfter: false
    function preNewAfter(){
        isPreNewAfter=true;
        timerActionOk.start();
    }

    onSignalAfter: {
        if(isCloseAfter){
            isCloseAfter=false;
            dialogTedit.emitActionCancel();
        }
        if(isPreNewAfter){
            isPreNewAfter=false;
            dialogTedit.preNew();
        }
    }

    function formDefault(){
        tdefault.start();
    }
    Timer{
        id:tdefault
        interval: 200
        onTriggered: {
            myForm._default();
        }
    }

    function checkRequired(){
        return true;

    }

    function get_timestamp(){
        return myForm._timestamp;
    }

    function context_timestamp(){
        return myForm.context_timestamp();
    }

    function _preClose(){
        if(dialogTedit.visible==true){
            if(dialogTedit.isChanged()){
                MessageLib.showQuestionAndNotAction(qsTr("Record modified,\n¿save?"),mainroot,"dialogTedit.closeAfter()","dialogTedit.emitActionCancel()");
            }else{
                dialogTedit.emitActionCancel();
            }
        }
    }

    function _preNew(){
        if(dialogTedit.isChanged()){
            MessageLib.showQuestionAndNotAction(qsTr("Record modified,\n¿save?"),mainroot,"dialogTedit.preNewAfter()","dialogTedit.preNew()");
        }else{
            preNew();
        }
    }

    function preNew(){
        dialogTedit.idRecord =-1;
        myForm.idRecord = dialogTedit.idRecord;
//        clearValues();

        myForm._initFields();

        myForm.clearValues();
        myForm._forceActiveFocus();
        if(fields_default.length>0){
            myForm._default(fields_default);
        }
        signalToolButtonNew();

    }

    header: ToolBar{
        Material.foreground: Qt.darker(mainroot.Material.accent)
        Item{
//            id:mh
            anchors.fill: parent
            implicitHeight: 30
            FlatAwesome{
                id:breload
                height: 24
                width: height
                color: Qt.darker(mainroot.Material.accent)
                anchors{left: parent.left;leftMargin: 8;verticalCenter: parent.verticalCenter}
                text: "\uf01e"
                onClicked: {
                    forceActiveFocus();
                    if(dialogTedit.isChanged()){
                        MessageLib.showQuestionAndNotAction(qsTr("Record modified\n¿save?"),mainroot,"timerActionOk.start()","dialogTedit.formReload()");
                    }else{
                        dialogTedit.formReload();
                    }
                }
            }
            //"\uf067"
            FlatAwesome{
                height: 24
                width: height
                color: Qt.darker(mainroot.Material.accent)
                anchors{left: breload.right;leftMargin: 8;verticalCenter: parent.verticalCenter}
                text: "\uf067"
                onClicked: {
                    forceActiveFocus();
                    dialogTedit._preNew();
                    signalAfterOpen();
                }
            }
            Label{
                text:idRecord!=-1?qsTr("Edit")+" "+_title:qsTr("New")+" "+_title
                elide: Label.ElideRight
                width: parent.width-100
                height: 30
                anchors.centerIn: parent
                font.pixelSize: 20
                font.bold: true
                verticalAlignment: Label.AlignVCenter
                horizontalAlignment: Label.AlignHCenter
            }
            FlatAwesome{
                height: 24
                width: height
                color: Qt.darker(mainroot.Material.accent)
                anchors{right: parent.right;rightMargin: 8;verticalCenter: parent.verticalCenter}
                text:"\uf00d"
                onClicked: {
                    forceActiveFocus();
                    dialogTedit._preClose();
                }
            }
        }
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
            Button {
                id:bokdcli
                text: isMobile?"\uf00c":qsTr("Ok")
                Component.onCompleted: {if(isMobile){font.family=fawesome.name;font.pixelSize=20}}
                visible:dialogTedit.actionOK
                implicitHeight: 42
                Material.background: setting.accent
                onClicked: {
                    forceActiveFocus();
                    timerActionOk.start();
//                    dialogTedit.emitActionOk();

                }
                contentItem: Text {
                    text: bokdcli.text
                    font: bokdcli.font
                    opacity: enabled ? 1.0 : 0.3
                    color: Qt.darker(mainroot.Material.accent)
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

