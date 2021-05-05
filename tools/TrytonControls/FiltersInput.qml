//this file is part the thesa: tryton client based PySide2(qml2)
// filters with format
//__author__ = "Numael Garay"
//__copyright__ = "Copyright 2020"
//__license__ = "GPL"
//__version__ = "1.8.0"
//__maintainer__ = "Numael Garay"
//__email__ = "mantrixsoft@gmail.com"

import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import "../thesatools"
//TODO add filter dialog and parser
//
Control{
    id:control
    property bool filterTagActive: false
    property var listValuesTag: []
    signal executeFind(var domain)
    signal down()
    signal executeRestart()
    property bool buttonRestart: true
    property real popupWidth: 150
    function clear(){
        tffilters.text="";
    }

    function _getData(){
        var d=1;
        console.log(JSON.stringify(listValuesTag));
        if(listValuesTag.length==0){
        //if(d==1){
            var text = tffilters.text
            //si texto no tiene : usar rec_name si hay espacios varios rec_name
            var listData=[];
            if(text===""){
                //listData.push([]);
            }else{
                listData.push(["rec_name","ilike","%"+text+"%"]);
            }

            return listData;
        }else{
            return _getListFilterTag();//listValuesTag;
        }
    }

    function _getListFilterTag(){
        var dom = [];
        if(listValuesTag.length==0){
            return dom;
        }
        if(listValuesTag.length==1){
            return [listValuesTag[0].value];
        }
        dom=['AND']
        for(var i=0, len=listValuesTag.length;i<len;i++){
            dom.push(listValuesTag[i].value);
        }
        return dom;
    }
    Timer{
        id:texecute
        interval:100
        onTriggered: {
            //console.log(JSON.stringify(_getData()));
            executeFind(_getData());
        }
    }

    RowLayout{
        anchors.fill: parent
        ButtonAwesome{
            text:"\uf0b0"
            //            font.pixelSize: 16
            Layout.preferredWidth: 40
            Layout.fillHeight: true
            ToolTip.visible: false
            height: parent.height
            onClicked: {
                popup.open();
            }
        }
        TextField{
            id:tffilters
            Layout.fillWidth: true
            Layout.fillHeight: true
            selectByMouse: !boolMovil
            visible: !filterTagActive
            Keys.onPressed: {
                if (event.key === Qt.Key_Down ) {
                    event.accepted = true;
                    down();
                }
                if (event.key === Qt.Key_Return ) {
                    event.accepted = true;
                    executeFind(_getData());
                }
                if (event.key === Qt.Key_Enter ) {
                    event.accepted = true;
                    executeFind(_getData());
                }
            }
        }
        FilterTagList{
            id:filtertag
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: filterTagActive
            onChangeValues: {
                var listValues= values;
                if(listValues.length>0){
                    filterTagActive = true;
                    tffilters.text="";
                }else{
                    filterTagActive = false
                }

                listValuesTag = listValues;//_getListFilterTag(listValues);
                texecute.start();
            }
        }

        ButtonAwesome{
            Layout.preferredWidth: 40
            Layout.fillHeight: true
            text: "\uf002"
            ToolTip.visible: false
            onClicked: {
                executeFind(_getData());
            }
        }
        ButtonAwesome{
            //            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 40
            text: "\uf01e"
            ToolTip.visible: false
            visible: buttonRestart
            onClicked: {
                executeRestart();
            }
        }

    }
    function setFilters(filters){
        fmodel.clear();
        for(var i=0, len=filters.length;i<len;i++){
            fmodel.append(filters[i]);
        }
    }

    ListModel{
        id:fmodel
    }
    //{"field":"id","fieldalias":"ID,"type":"numeric"}

    Component{
        id:fdelegate
        ItemDelegate {
            width: popupWidth
            height: control.height
            contentItem: Item{
                RowLayout{
                    anchors.fill: parent
                    Label {
                        id:textItem
                        text: fieldalias
                        Layout.fillWidth: true
                        color: mainroot.Material.foreground
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 10
                    }
                }
            }
            highlighted: ListView.isCurrentItem
            onClicked: {
               // filtertag.addTag({"name":"wer > 23","value":["","=",""]})
                //filtertag.addTag({"name":"werdddddddd > 23","value":""})
                popup.close();
                console.log(JSON.stringify({"field":field,"fieldalias":fieldalias,"type":type}))
                dcreatetag.newfiltre = {"field":field,"fieldalias":fieldalias,"type":type};
                dcreatetag.open();

            }
            Keys.onPressed: {
                if (event.key === Qt.Key_Return ) {
                    event.accepted = true;
                    popup.close();
                }
                if (event.key === Qt.Key_Enter ) {
                    event.accepted = true;
                    popup.close();
                }
            }
        }
    }


    Popup{
        id: popup
        y: control.height - 1
        width: popupWidth
        implicitHeight:popuplist.implicitHeight
        padding: 0
        // modal: true
        //focus: true
        onClosed: {
        }
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
        contentItem: ListView {
            id:popuplist
            clip: true
            implicitHeight: contentHeight
            model: fmodel
            delegate: fdelegate
            ScrollBar.vertical: ScrollBar {policy: popuplist.contentHeight > height?ScrollBar.AlwaysOn:ScrollBar.AlwaysOff}
        }
    }

    Dialog {
        id:dcreatetag
        standardButtons: Dialog.Ok|Dialog.Cancel
        width: 360
        //height: 200
        title: qsTr("add Filter")
        closePolicy: Dialog.CloseOnEscape
        //anchors.centerIn: parent
        y:parent.height +200
        x: (parent.width-width)/2
        property var newfiltre: ({})
        property bool isNumeric: false
        property bool isText: false
        property bool isDateTime: false

        onAccepted: {
            if(newfiltre.type=="numeric"){
                filtertag.addTag({"name":newfiltre.fieldalias+" = "+fieldvalue.text,"value1":newfiltre.field,"value2":"=","value3":fieldvalue.text})
            }
            if(newfiltre.type=="text"){
                filtertag.addTag({"name":newfiltre.fieldalias+" : "+fieldvalue.text,"value1":newfiltre.field,"value2":"ilike","value3":"%"+fieldvalue.text+"%"})
            }
            isNumeric= false;
            isText= false;
            isDateTime= false;
            //fieldvalue.text="";
            //newfiltre={};
        }
        onRejected: {
            isNumeric= false;
            isText= false;
            isDateTime= false;
            fieldvalue.text="";
            newfiltre={}
        }

        modal: true
        onVisibleChanged: {
            if(visible){
                if(newfiltre.type=="numeric"){
                    isNumeric=true;
                    fieldvalue.validator= Qt.createQmlObject('import QtQuick 2.9;RegExpValidator { regExp:/^(0|[1-9][0-9]*)$/}', fieldvalue, "dynamicSnippet1");
                }
                if(newfiltre.type=="text"){
                    isText=true;
                    fieldvalue.validator= Qt.createQmlObject('import QtQuick 2.9;RegExpValidator { regExp:/^(.*)$/}', fieldvalue, "dynamicSnippet1");
                }
                if(newfiltre.type=="numeric" || newfiltre.type=="text"){
                    namefield.text=newfiltre.fieldalias+":"
                    fieldvalue.text="";
                    fieldvalue.forceActiveFocus();
                }
            }
        }
        contentItem: RowLayout{
                spacing: 8
                Label{
                    id:namefield
                    visible: dcreatetag.isNumeric==true || dcreatetag.isText==true?true:false
                    Layout.preferredWidth: paintedWidth
                    Layout.fillHeight: true
                    verticalAlignment: Qt.AlignVCenter
                    font.pixelSize: 20
                }

                TextField{
                    id:fieldvalue
                    visible: dcreatetag.isNumeric==true || dcreatetag.isText==true?true:false
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    font.pixelSize: 20
                    onAccepted: {
                        dcreatetag.accept();
                    }
                }

        }
    }


}
