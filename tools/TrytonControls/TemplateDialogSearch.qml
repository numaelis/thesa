//this file is part the thesa: tryton client based PySide2(qml2)
// template dialog search
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
    id:dialogTsearch
    width: maxWidthDialog//500
    //anchors.centerIn: parent
    x: (parent.width - width) / 2
    y: (parent.height - (height))/ 2
    property int idRecordSearch: -1
    property string modelName: ""
    property bool activeActionSelect: true
    property bool activeActionEdit: true
    property bool activeActionNew: true
    property bool activeActionCancel: true
    property bool activeActionRemove: false
    //property var myForm: -1
    property string _title: ""
    property var listHead: []
    property var domain: []
    property var order: []
    property var filters: []
    property string placeholderText: ""
    property var filtersRecName: []
    property alias treeViewItem: myTreeView
    property var modelStates: []
    property QtObject dialogEdit
    title: _title
    closePolicy: Dialog.CloseOnEscape
    signal actionSelect(int _id, var fields)
    signal actionEdit(int index)
    signal actionNew()
    modal: true
    focus: true
    Component.onCompleted: {
        if(isMobile){
            padding=8;
        }
    }

    onActionEdit:{
        if(dialogEdit != null){
            dialogEdit.idRecord = index;
            dialogEdit.dialogSearch = dialogTsearch;
            dialogEdit.open();
        }
    }

    onActionNew:{
        if(dialogEdit != null){
            dialogEdit.idRecord = -1;
            dialogEdit.dialogSearch = dialogTsearch;
            dialogEdit.open();
        }
    }
    onVisibleChanged: {
        if(visible){
            myTreeView._filterClear();
            myTreeView._restart();
            myTreeView.shadowOff();
        }
    }
//    onOpened: {
//        myTreeView._filterClear();
//        myTreeView._restart();
//    }

    function feditItem(){
        idRecordSearch = myTreeView.getId();
        if(idRecordSearch!=-1){
            dialogTsearch.actionEdit(idRecordSearch)
        }
    }

    function fselectitem(){
        idRecordSearch = myTreeView.getId();
        if(idRecordSearch!=-1){
            dialogTsearch.actionSelect(idRecordSearch, myTreeView.getObject())
        }
        dialogTsearch.accept();
    }

    footer: ToolBar {
        id:mtb
        implicitHeight: 42
        background: Rectangle {
            width: mtb.width
            height: mtb.height
            color: "transparent"
        }
        RowLayout {
            anchors{right: parent.right;rightMargin: 8}
            spacing: 8
            ToolButton {
                id:bclican
                text: isMobile?"\uf05e":qsTr("Cancel")
                Component.onCompleted: {if(isMobile){font.family=fawesome.name;font.pixelSize=20}}
                implicitHeight: 34
                visible: dialogTsearch.activeActionCancel
                onClicked: {
                    dialogTsearch.reject();
                }
                contentItem: Text {
                    text: bclican.text
                    font: bclican.font
                    opacity: enabled ? 1.0 : 0.3
                    color: mainroot.Material.accent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
                Keys.onPressed: {
                    if (event.key === Qt.Key_Return ) {
                        event.accepted = true;
                        dialogTsearch.reject();
                    }
                    if (event.key === Qt.Key_Enter ) {
                        event.accepted = true;
                        dialogTsearch.reject();
                    }
                }
            }
            ToolButton {
                id:bclirem
                text: isMobile?"\uf2ed":qsTr("Remove")
                Component.onCompleted: {if(isMobile){font.family=fawesome.name;font.pixelSize=20}}
                implicitHeight: 34
                visible: dialogTsearch.activeActionRemove
                onClicked: {
                     MessageLib.showQuestion(qsTr("¿Remove Items?"),myTreeView,"myTreeView.removeItems()");

                }
                contentItem: Text {
                    text: bclirem.text
                    font: bclirem.font
                    opacity: enabled ? 1.0 : 0.3
                    color: mainroot.Material.accent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
                Keys.onPressed: {
                    if (event.key === Qt.Key_Return ) {
                        event.accepted = true;
                         MessageLib.showQuestion(qsTr("¿Remove Items?"),myTreeView,"myTreeView.removeItems()");
                    }
                    if (event.key === Qt.Key_Enter ) {
                        event.accepted = true;
                        MessageLib.showQuestion(qsTr("¿Remove Items?"),myTreeView,"myTreeView.removeItems()");
                    }
                }
            }
            ToolButton {
                id:bcliedit
                text: isMobile?"\uf044":qsTr("Edit")
                Component.onCompleted: {if(isMobile){font.family=fawesome.name;font.pixelSize=20}}
                implicitHeight: 34
                visible: dialogTsearch.activeActionEdit
                enabled: idRecordSearch!==-1?true:false
                onClicked: {
                    dialogTsearch.feditItem();
                }
                contentItem: Text {
                    text: bcliedit.text
                    font: bcliedit.font
                    opacity: enabled ? 1.0 : 0.3
                    color: mainroot.Material.accent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
                Keys.onPressed: {
                    if (event.key === Qt.Key_Return ) {
                        event.accepted = true;
                        dialogTsearch.feditItem();
                    }
                    if (event.key === Qt.Key_Enter ) {
                        event.accepted = true;
                        dialogTsearch.feditItem();
                    }
                }
            }
            ToolButton {
                id:bclinew
                text: isMobile?"\uf067":qsTr("New")
                Component.onCompleted: {if(isMobile){font.family=fawesome.name;font.pixelSize=20}}
                implicitHeight: 34
                visible: dialogTsearch.activeActionNew
                onClicked: {
                    dialogTsearch.actionNew();
                }
                contentItem: Text {
                    text: bclinew.text
                    font: bclinew.font
                    opacity: enabled ? 1.0 : 0.3
                    color: mainroot.Material.accent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
                Keys.onPressed: {
                    if (event.key === Qt.Key_Return ) {
                        event.accepted = true;
                        dialogTsearch.actionNew();
                    }
                    if (event.key === Qt.Key_Enter ) {
                        event.accepted = true;
                        dialogTsearch.actionNew();
                    }
                }
            }
            ToolButton {
                id:bcliselect
                text: isMobile?"\uf00c":qsTr("Select")
                Component.onCompleted: {if(isMobile){font.family=fawesome.name;font.pixelSize=20}}
                implicitHeight: 34
                visible: dialogTsearch.activeActionSelect
                enabled: idRecordSearch!==-1?true:false
                onClicked: {
                    dialogTsearch.fselectitem();
                }
                contentItem: Text {
                    text: bcliselect.text
                    font: bcliselect.font
                    opacity: enabled ? 1.0 : 0.3
                    color: mainroot.Material.accent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
                Keys.onPressed: {
                    if (event.key === Qt.Key_Return ) {
                        event.accepted = true;
                        dialogTsearch.fselectitem();
                    }
                    if (event.key === Qt.Key_Enter ) {
                        event.accepted = true;
                        dialogTsearch.fselectitem();
                    }
                }
            }
        }
    }

    function updateRecords(ids){
        myTreeView.updateRecords(ids);
    }

    contentItem: ColumnLayout{
        TreeView{
            id:myTreeView
            property var objectFields: ({})
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredHeight: 400
            Layout.preferredWidth: contentWidth
            modelName:dialogTsearch.modelName
            limit: 50//step, step
            multiSelectItems:false
            domain:dialogTsearch.domain
            order:dialogTsearch.order
            filters: dialogTsearch.filters
            placeholderText: dialogTsearch.placeholderText
            filtersRecName: dialogTsearch.filtersRecName
            modelStates: dialogTsearch.modelStates
            verticalLine:true
            activeFilters: true
            activeStates: true
            widthStates:120
            heightStates: 30
            buttonRestart:true
            maximumLineCount:3
            onClicked:{
                var mid = getId();
                if (mid!=-1){
                    idRecordSearch = mid;
                    objectFields = getObject();
                }
            }
            onDoubleClick: {
                var mid = getId();
                if (mid!=-1){
                    idRecordSearch = mid;
                    objectFields = getObject();
                    dialogTsearch.actionSelect(idRecordSearch, objectFields);
                }
                dialogTsearch.accept();
            }

            listHead: dialogTsearch.listHead;
        }
    }
}

