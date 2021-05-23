//this file is part the thesa: tryton client based PySide2(qml2)
// filters with format
//__author__ = "Numael Garay"
//__copyright__ = "Copyright 2020 2021"
//__license__ = "GPL"
//__version__ = "1.8.0"
//__maintainer__ = "Numael Garay"
//__email__ = "mantrixsoft@gmail.com"

import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import "../thesatools"
//TODO add filter datetime, ...
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
    property var _defaultFilterRecName: ["rec_name","ilike","%value%"]
    property alias placeholderText: tffilters.placeholderText
    function clear(){
        tffilters.text="";
    }
    //expand rec_name from client
    function remplaceValue(filters){
        var tempo={"obj":filters};
        var strobj = JSON.stringify(tempo);
        while(strobj.indexOf("value")>-1){
            strobj= strobj.replace("value", tffilters.text);
        }
        return JSON.parse(strobj).obj;
    }

    function _getData(){
        if(listValuesTag.length==0){
            var text = tffilters.text
            var listData=[];
            if(text===""){
                //listData.push([]);
            }else{
                listData.push(remplaceValue(_defaultFilterRecName));
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
            executeFind(_getData());
        }
    }

    RowLayout{
        anchors.fill: parent
        ButtonAwesome{
            text:"\uf0b0"
            Layout.preferredWidth: 40
            Layout.fillHeight: true
            ToolTip.visible: false
            height: parent.height
            onClicked: {
                popup.open();
                popuplist.forceActiveFocus();
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

                listValuesTag = listValues;
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
            Layout.fillHeight: true
            Layout.preferredWidth: 40
            text: "\uf01e"
            ToolTip.visible: false
            visible: buttonRestart
            onClicked: {
                listValuesTag=[];
                filterTagActive=false;
                filtertag.clear();
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
                popup.close();
                dcreatetag.newfiltre = {"field":field,"fieldalias":fieldalias,"type":type};
                dcreatetag.open();

            }
            Keys.onPressed: {
                if (event.key === Qt.Key_Return ) {
                    event.accepted = true;
                    popup.close();
                    dcreatetag.newfiltre = {"field":field,"fieldalias":fieldalias,"type":type};
                    dcreatetag.open();
                }
                if (event.key === Qt.Key_Enter ) {
                    event.accepted = true;
                    popup.close();
                    dcreatetag.newfiltre = {"field":field,"fieldalias":fieldalias,"type":type};
                    dcreatetag.open();
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
        title: qsTr("Add Filter")
        closePolicy: Dialog.CloseOnEscape
        focus: true
        //anchors.centerIn: parent
      //  y:parent.height +200
        x: (parent.width-width)/2
        property var newfiltre: ({})
        property bool isNumeric: false
        property bool isText: false
        property bool isDate: false
        property bool isDateTime: false
        property bool isSelection: false

        onAccepted: {
            if(newfiltre.type==="numeric"){
                var valueNumeric = fieldvalue.text.toString();
                if(valueNumeric!=""){
                    var valueEnd = fieldvalue.text;
                    if(valueNumeric.indexOf(".")!=-1){
                        valueEnd = parseFloat(fieldvalue.text);
                    }
                    filtertag.addTag({"name":newfiltre.fieldalias+" "+cboperator.currentText+" "+fieldvalue.text,"value":JSON.stringify([newfiltre.field,cboperator.currentText,valueEnd])})
                }
            }
            if(newfiltre.type==="text"){
                filtertag.addTag({"name":newfiltre.fieldalias+" : "+fieldvalue.text,"value":JSON.stringify([newfiltre.field,"ilike","%"+fieldvalue.text+"%"])})
            }
            if(newfiltre.type==="date"){
                filtertag.addTag({"name":"("+newfiltre.fieldalias+" : >= "+fvdatefrom.getDate().toLocaleDateString("en-US")+ "  " + newfiltre.fieldalias+" :<= "+fvdateto.getDate().toLocaleDateString("en-US")+")",
                                     "value":JSON.stringify([[newfiltre.field,">=",dateSchemaFromDate(fvdatefrom.getDate())],
                                                             [newfiltre.field,"<=",dateSchemaFromDate(fvdateto.getDate())]
                                                            ])});
            }
            isNumeric= false;
            isText= false;
            isDateTime= false;
            isDate=false;
            isSelection=false;
        }

        onRejected: {
            isNumeric= false;
            isText= false;
            isDateTime= false;
            isDate=false;
            isSelection=false;
            fieldvalue.text="";
            newfiltre={}
        }

        modal: true
        onVisibleChanged: {
            if(visible){
                if(newfiltre.type=="numeric"){
                    isNumeric=true;
                    fieldvalue.validator = Qt.createQmlObject('import QtQuick 2.5;RegExpValidator { regExp:/^(0|[1-9][0-9]*|0\\.([1-9][0-9]|[0-9][0-9]|[0-9])|[1-9][0-9]*\\.([0-9][0-9]|[0-9]))$/ }', fieldvalue, "dynamicSnippet1");
                    cboperator.currentIndex=0;
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
                if(newfiltre.type=="date"){
                    isDate=true;
                    namefield.text=newfiltre.fieldalias+":"
                    fvdatefrom.reset();
                    fvdateto.reset();
                }
            }
        }
        contentItem: Pane{
            background: Rectangle{
                opacity: 0
            }
            ColumnLayout{
                anchors.fill: parent
                RowLayout{
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignRight
                    Label{
                        text: qsTr("Operator: ")
                        visible: dcreatetag.isNumeric
                    }

                    ComboBox{
                        id:cboperator
                        Layout.alignment: Qt.AlignRight
                        visible: dcreatetag.isNumeric
                        model:["=",">","<"]
                        onCurrentIndexChanged: {
                            if(currentIndex!=-1){
                                fieldvalue.forceActiveFocus();
                            }
                        }
                    }
                }

                RowLayout{
                    spacing: 8
                    Layout.alignment: Qt.AlignVCenter
                    //                Layout.fillHeight: true
                    Layout.fillWidth: true
                    Label{
                        id:namefield
                        Layout.preferredWidth: paintedWidth
                        Layout.preferredHeight: 60
                        verticalAlignment: Qt.AlignVCenter
                        font.pixelSize: 20
                    }

                    TextField{
                        id:fieldvalue
                        visible: dcreatetag.isNumeric==true || dcreatetag.isText==true?true:false
                        Layout.fillWidth: true
                        Layout.preferredHeight: 60
                        font.pixelSize: 20
                        onAccepted: {
                            dcreatetag.accept();
                        }
                    }
                    ColumnLayout{
                        Layout.fillWidth: true
                        LabelCube{
                            label: qsTr("From:")
                            visible: dcreatetag.isDate==true
                            height:60
                            Layout.fillHeight: true
                            Layout.minimumWidth: 135
                            Layout.preferredWidth: 135
                            boolBack:false
                            FieldCalendar{
                                id:fvdatefrom
                            }
                        }
                        LabelCube{
                            label: qsTr("To:")
                            visible: dcreatetag.isDate==true
                            height:60
                            Layout.fillHeight: true
                            Layout.minimumWidth: 135
                            Layout.preferredWidth: 135
                            boolBack:false
                            FieldCalendar{
                                id:fvdateto
                            }
                        }
                    }

                }

            }
        }
    }


}
