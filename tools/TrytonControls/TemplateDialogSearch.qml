//this file is part the thesa: tryton client based PySide2(qml2)
// template dialog search
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
    id:dialogTsearch
    width: 500
    anchors.centerIn: parent
    property int idRecordSearch: -1
    property string modelName: ""
    property bool activeActionSelect: true
    property bool activeActionEdit: true
    property bool activeActionNew: true
    property bool activeActionCancel: true
    //property var myForm: -1
    property string _title: ""
    property var listHead: []
    property var domain: []
    property var order: []
    property var filters: []
    property string placeholderText: ""
    property var filtersRecName: []
    property alias treeViewItem: myTreeView
    property QtObject dialogEdit
    title: _title
    closePolicy: Dialog.CloseOnEscape
    signal actionSelect(int _id, var fields)
    signal actionEdit(int index)
    signal actionNew()

    modal: true

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

    onOpened: {
        myTreeView.find([]);
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
                text: qsTr("Cancel")
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
            }
            ToolButton {
                id:bcliedit
                text: qsTr("Edit")
                implicitHeight: 34
                visible: dialogTsearch.activeActionEdit
                enabled: idRecordSearch!==-1?true:false
                onClicked: {
                    dialogTsearch.actionEdit(idRecordSearch)
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
            }
            ToolButton {
                id:bclinew
                text: qsTr("New")
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
            }
            ToolButton {
                id:bcliselect
                text: qsTr("Select")
                implicitHeight: 34
                visible: dialogTsearch.activeActionSelect
                onClicked: {
                    dialogTsearch.actionSelect(idRecordSearch, myTreeView.getObject())
                    dialogTsearch.accept();
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
            verticalLine:true
            activeFilters: true
            //activeStates: true
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

