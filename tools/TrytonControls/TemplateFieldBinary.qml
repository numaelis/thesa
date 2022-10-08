//this file is part the thesa: tryton client based PySide2(qml2)
// template field date
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

Control{
    id:control
    property bool tryton: true
    property string fieldName: ""
    property string type: "binary"
    property string labelAlias: ""
    property bool required: false
    property bool readOnly: false
    enabled: !readOnly
    //    property alias item_field: tfield
    property bool isChange: false
    property var itemParent: -1
    //    property bool dateInit: true
    property var field_source: null
    property string fileName: ""
    property string filePath: ""
    property string fileSize: "0 Bytes"
    property bool visibleFileName: false
    property bool visibleSize: true
    property int version: 0
    property var itemFileName: null
    property string fileDialogCaption: ""
    property string fileDialogFilters: ""
    property bool asyncOpenFile: true
    signal change(var data)

    padding: 0

    function _forceActiveFocus(){
        bsearch.forceActiveFocus();
    }

    function slotOpenFile(pid, result){
        if(pid== control.objectName){
            if(result.fullname!=""){
                field_source = result.base64;
                fileName = result.name;
                fileSize = getSizeMB(result.size);
                if(itemFileName!=null){
                    itemFileName.setValue(fileName);
                    itemFileName.changeToParent(itemFileName.fieldName, fileName);
                }

                isChange=true;
                change(getValue());
                changeToParent(fieldName,getValue());
            }
        }
        tdesconect.start();
    }

    Timer{
        id:tdesconect
        interval: 100
        onTriggered: {
            Tools.signalResponseOpenFile.disconnect(slotOpenFile);
        }
    }

    function _base64ToArrayBuffer(base64) { //not working in qml
        //from stackoverflow 21797299/convert-base64-string-to-arraybuffer
        var binary_string = Qt.atob(base64);
        var len = binary_string.length;
        var bytes = new Uint8Array(len);
        for (var i = 0; i < len; i++) {
            bytes[i] = binary_string.charCodeAt(i);
        }
        return bytes.buffer;
    }

    function getValue(){
        if(field_source!=null){
            if(version==0){
                if(field_source.hasOwnProperty("base64")){
                    if(field_source["base64"]==""){
                        return null;
                    }
                }
                return field_source;
            }else{
                return {"__class__":"bytes",
                    "base64":field_source}
            }
        }
        return null;

    }
    Timer{
        id:timerSize
        interval: 200
        onTriggered: {
            fileSize = getFileSize(field_source);
        }
    }

    function getFileSize(data){
        if(data!=null && data!=""){
            var msize = Tools.getBase64Size(data);
            return getSizeMB(msize);
        }
        return "0 Bytes";
    }

    function setValue(value){
        if(value==null){
            field_source=null;
            fileSize= "0 Bytes";
            fileName="";
        }else{
            if(value.hasOwnProperty("base64")){
                if(value["base64"]!=""){
                    field_source=value["base64"];
                    if(visibleSize==true){
                        timerSize.restart();
//                        fileSize = getFileSize(field_source);
                    }
                }else{
                    field_source=null;
                    fileSize = "0 Bytes";
                }
            }else{
                if(field_source!=null){
                    field_source = value;
                    if(visibleSize==true){
                        timerSize.restart();
//                        fileSize = getFileSize(field_source);
                    }
                }else{
                    field_source=null;
                    fileSize= "0 Bytes";
                }
            }

            if(itemFileName!=null){
                fileName = itemFileName.getValue();
            }
        }
        isChange=false;
    }

    function clearValue(){
        field_source=null;
        fileSize= "0 Bytes";
        fileName="";
        isChange=false;
    }

    function changeOff(){
        isChange=false;
    }

    function changeToParent(name, value){
        if(itemParent!=-1){
            if(itemParent.type=="one2many"){
                itemParent.changeField(name, value);
            }
        }
    }

    Component.onCompleted: {
        control.objectName="tryton_"+fieldName+"_"+_getNewNumber();
    }
    function getSizeMB(size){
        if(size == 0){
            return "0 Bytes"
        }
        if(size >= 1024 && size < 1048576){
            return parseInt((size/1024)).toString() + " KB"
        }
        if(size >= 1048576){
            return parseInt((size/1048576)).toString() + " MB"
        }

        return " - Bytes";
    }

    LabelCube{
        id:labelcube
        anchors.fill: parent
        label: labelAlias
        labelcolor:"grey"
        boolBack:false
        RowLayout{
            Label{
                id:lvisorFileName
                text:fileName
                visible: visibleFileName
                Layout.fillWidth: true
                font.bold: true
                font.pixelSize: 16
                elide: Label.ElideRight
                color: mainroot.Material.accent
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
            }
            Label{
                id:lvisorSize
                text:fileSize
                visible: visibleSize
                Layout.fillWidth: true
                font.bold: true
                font.pixelSize: 16
                elide: Label.ElideRight
                color: mainroot.Material.accent
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
            }
            ButtonAwesome{
                id:bsearch
                text: "\uf002"
                textToolTip: qsTr("Search")
                visible: field_source==null
                Layout.preferredWidth: 30
                Layout.preferredHeight: 35
                Material.foreground: mainroot.Material.accent
                font.pixelSize: 18
                onClicked: {
                    if(asyncOpenFile==false){
                        var path = Tools.getFilePath(fileDialogCaption,fileDialogFilters)
                        if(path.fullname!=""){
                            field_source = Tools.getFileBase64(path.fullname);
                            fileName = path.name;
                            fileSize = getSizeMB(path.size);
                            if(itemFileName!=null){
                                itemFileName.setValue(fileName);
                                itemFileName.changeToParent(itemFileName.fieldName, fileName);
                            }

                            isChange=true;
                            change(getValue());
                            changeToParent(fieldName,getValue());
                        }
                    }else{
                        Tools.signalResponseOpenFile.connect(slotOpenFile);
                        Tools.getOpenFileBase64(control.objectName, fileDialogCaption,fileDialogFilters);
                    }
                }
            }

            ButtonAwesome{
                id:bopen
                text: "\uf35d"
                textToolTip: qsTr("Download")
                visible: field_source!=null
                Layout.preferredWidth: 30
                Layout.preferredHeight: 35
                Material.foreground: mainroot.Material.accent
                font.pixelSize: 18
                onClicked: {
                    var name = fileName;
                    if(name==""){
                        name = "document";
                    }
                    //if full path add, Tools.openFile(name, field_source, path);
                    Tools.openFile(name, field_source);
                }
            }
            ButtonAwesome{
                id:bdel
                text: "\uf2ed"
                textToolTip: qsTr("Remove")
                visible: field_source!=null
                Layout.preferredWidth: 30
                Layout.preferredHeight: 35
                Material.foreground: mainroot.Material.accent
                font.pixelSize: 18
                onClicked: {
                    field_source=null;
                    fileSize= "0 Bytes";
                    fileName=""
                    if(itemFileName!=null){
                        itemFileName.setValue(fileName);
                        itemFileName.changeToParent(itemFileName.fieldName, fileName);
                    }
                    isChange=true;
                    change(getValue());
                    changeToParent(fieldName,getValue());
                }
            }
        }
    }
}
