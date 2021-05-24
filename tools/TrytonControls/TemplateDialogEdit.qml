//this file is part the thesa: tryton client based PySide2(qml2)
// template dialog edit
//__author__ = "Numael Garay"
//__copyright__ = "Copyright 2020"
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
    width: 500
    anchors.centerIn: parent
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


    function updateTreeView(fields){
        if (dialogSearch!=null){
            dialogSearch.updateRecords([fields.id]);
        }
    }
    function acceptDialogSearch(fields){
        if (dialogSearch!=null){
            dialogSearch.actionSelect(fields.id, fields);
            dialogSearch.accept();
        }
    }

    onEmitActionCancel:{
        myForm.clearValues();
        dialogTedit.reject();
    }

    onEmitActionOk:{
        if(idRecord==-1){
            myForm._preCreate();
        }else{
            myForm._preUpdate();
        }
    }

    Component.onCompleted: {

    }

    onAccepted: {

    }

    onRejected: {

    }

    modal: true

    onOpened: {
        myForm = contentItem;
        myForm.modelName = dialogTedit.modelName;
        myForm.idRecord = dialogTedit.idRecord;
        myForm.myParent = dialogTedit;
        myForm._initFields();
        if(idRecord!=-1){
            myForm._reload();
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
                text: qsTr("Cancel")
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
            }
            ToolButton {
                id:bokdcli
                text: qsTr("Ok")
                visible:dialogTedit.actionOK
                implicitHeight: 34
                onClicked: {
                    dialogTedit.emitActionOk();

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
            }
        }
    }

    contentItem:TemplateFormEdit{
        id:templateForm
    }
}

