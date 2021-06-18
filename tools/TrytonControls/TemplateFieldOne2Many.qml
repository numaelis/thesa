//this file is part the thesa: tryton client based PySide2(qml2)
// template One2Many
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
//TODO mode tree, menu tools
Pane{
    id:templateO2M
    property bool tryton: true
    property string labelAlias: ""
    property string fieldName: ""
    property string fieldOne2Many: ""
    property string type: "one2many"
    property string modelName: ""
    property string title: ""
    property bool required: false
    property bool readOnly: false
    enabled: !readOnly
    property bool isChange: false
    property alias contentItemForm: pform.contentItem
    signal change(var lines)
    property int idRecordParent: -1
    property var myParent: -1
    property var itemsField:[]
    property var mapFieldItem: ({})

    property bool oneItemDefault: false
    property bool activeMenu: false

    property var listRecords: []// lines json
    //    property real heightField: 60
    property var listHead: []
    property int currentItem: -1
    property int maxItem: -1

    property bool isSequence: false
    property string fieldSequence: "sequence"
    property bool autoRecord: true
    property string mode: "form" //tree
    property var paramsPlusCreate: ({})
    padding: 0

    ListModel{
        id:modelLines
    }

    contentItem: ColumnLayout{
        RowLayout{
            Label{
                text:title
                visible: title==""?false:true
                Layout.preferredHeight: 15
                font.bold: true
                font.italic: true
                color: "grey"
            }
            Item {//TODO MENU
                id: itoolmenu
                visible: activeMenu
            }
        }
        Item{
            //treeview
            visible: mode=="tree"?true:false
        }
        Pane{
            id:pform
            padding: 0
            Layout.fillHeight: true
            Layout.fillWidth: true
            visible: mode=="form"?true:false
        }
    }


    Component.onCompleted: {
        templateO2M.objectName="tryton_"+fieldName+"_"+_getNewNumber();
        _initFields();
        clearValues();
    }

    function _initFields(){
        itemsField = finditemsField(templateO2M.contentItem.children);
        _initMapFields();
        setItemParent();
        setRequired();
    }

    function setItemParent(){
        for(var i = 0, len=itemsField.length;i<len;i++){
            itemsField[i].itemParent = templateO2M;
        }
    }

    function setRequired(){
        for(var i = 0, len=itemsField.length;i<len;i++){
           if(itemsField[i].required == true){
               required=true;
               break;
           }
        }
    }

    function changeField(field, value){
        listRecords[currentItem][field]=value;
        listRecords[currentItem]["change"][field]=field;
        listRecords[currentItem]["action"]="write";
        isChange = true;
        change(listRecords);
    }

    function clearValue(){
        clearValues();
    }

    function clearValues(){
        listRecords=[];
        modelLines.clear();
        for(var i=0,len=itemsField.length;i<len;i++){
            itemsField[i].clearValue();
        }
        if(oneItemDefault){
            addRecordBlank(false);
        }else{
            isChange=false;
            if(mode=="form"){
                enabledFields(false);
            }
        }
    }

    function enabledFields(active){
        for(var i=0,len=itemsField.length;i<len;i++){
            itemsField[i].enabled=active;
        }
    }

    function addRecordBlank(echange){
        var values = getFieldsValues(false);
        values["id"]=-1;
        if(isSequence){
            values["sequence"]=null;
        }
        values["action"]="";
        values["change"]={};
        values = Object.assign(values, paramsPlusCreate)
        addRecord(values, echange);
    }

    function addRecord(values, echange){
        listRecords.push(values);
        modelLines.append(values);
        currentItem=listRecords.length-1;
        setCurrentItemForm();
        isChange = true;
        if(echange){
            change(listRecords);
        }
    }

    function deleteRecord(){
        listRecords[currentItem]["action"]="delete";
        isChange = true;
        change(listRecords);
    }

    function changeToParent(field){
        isChange = true;
        change(listRecords);
    }

    function setValueTryton40(ids){
        if(ids.length>0){
            _read(ids);
        }else{
            setValue([]);
        }
    }

    function _read(ids){
        var params = getFieldsNamesTryton40();
        openBusy();
        var data = QJsonNetworkQml.recursiveCall("sread","model."+modelName+".read",
                                                 [
                                                    ids,
                                                     params,
                                                     preferences
                                                 ]);
        closeBusy();
        if(data.data!=="error"){
            if(data.data.result.length>0){
                var obj = data.data.result;
                setValue(obj);
            }
        }
    }

    function setValue(values){//TODO order
        listRecords=[];
        modelLines.clear();
        currentItem = -1;
        if(isSequence){
            //order list values
        }
        for(var i = 0, len=values.length;i<len;i++){
            var data = values[i];
            data["action"]="ready";
            data["change"]={};
            data = Object.assign(data, paramsPlusCreate)
            listRecords.push(data);
            modelLines.append(data);
        }

        if(listRecords.length>0){
            currentItem = 0;
            if(mode=="form"){
                setCurrentItemForm();
            }else{
                //TODO tree
            }
            isChange=false;
        }else{
            if(oneItemDefault){
                addRecordBlank(false);
            }else{
                if(mode=="form"){
                    enabledFields(false);
                }
            }
        }

    }

    function setCurrentItemForm(){
        var dataCurrentItem = listRecords[currentItem];
        for(var i = 0, len=itemsField.length;i<len;i++){
            if(itemsField[i].type==="many2one"){
                if(dataCurrentItem[itemsField[i].fieldName]!==null){
                    if(setting.typelogin==0){//Tryton 4
                        itemsField[i].setValue({"id":dataCurrentItem[itemsField[i].fieldName],"name":dataCurrentItem[itemsField[i].fieldName+".rec_name"]});
                    }else{
                        itemsField[i].setValue({"id":dataCurrentItem[itemsField[i].fieldName+"."]["id"],"name":dataCurrentItem[itemsField[i].fieldName+"."]["rec_name"]});
                    }
                }else{
                    itemsField[i].setValue({"id":-1,"name":""})
                }

            }else{
                if(itemsField[i].fieldName.indexOf(".")===-1){
                    itemsField[i].setValue(dataCurrentItem[itemsField[i].fieldName]);
                }else{
                    //TODO
                }
            }
        }
    }

    function getValue(){
        var lines =[];
        var add = [];
        var deleteItem = [];
        var create = [];
        var write = [];
        //        var indexDelete=[];
        for(var i=0,len=listRecords.length;i<len;i++){
            var record = JSON.parse(JSON.stringify(listRecords[i]));
            var data = JSON.parse(JSON.stringify(listRecords[i]));
            if(data.id==-1){
                delete record.action;
                delete record.id;
                delete record.change;
                if(isSequence){
                //    delete record.sequence;
                }
                create.push(record);
            }else{
                if(data.action==='delete'){
                    deleteItem.push(record.id);
                }else{
                    if(data.action==='write'){
                        add.push(record.id);
                        write.push([record.id]);
                        var fis = Object.keys(record.change);
                        var paramw={}
                        for(var ii=0,lenf=fis.length;ii<lenf;ii++){
                            paramw[fis[ii]]=record[fis[ii]];
                        }

                        write.push(paramw);
                    }
                }
            }
        }
        if(add.length>0){
            lines.push(["add",add]);
        }
        if(create.length>0){
            lines.push(["create", create]);
        }
        if(write.length>0){
            var rwrite=["write"];
            for(var iw=0,lenw=write.length;iw<lenw;iw++){
                rwrite.push(write[iw]);
            }

            lines.push(rwrite);
        }
        if(deleteItem.length>0){
            lines.push(["delete", deleteItem]);
        }
       // setChangeOff();
        return lines;
    }



    function finditemsField(ite){
        var result=[];
        for(var i = 0, len=ite.length;i<len;i++){
            var result2 = [];
            if(typeof ite[i].objectName !== "undefined"){
                if(ite[i].objectName.indexOf("tryton")>-1){
                    if(ite[i].tryton == true){
                        result.push(ite[i]);
                    }
                }
            }
            if(ite[i].children.length>0){
                if(typeof ite[i].objectName !== "undefined"){
                    if(ite[i].objectName.indexOf("tryton")>-1){
                        if(ite[i].type!=="one2many"){
                            result2 = finditemsField(ite[i].children);
                            result=result.concat(result2);
                        }
                    }else{
                        result2 = finditemsField(ite[i].children);
                        result=result.concat(result2);
                    }
                }else{
                    result2 = finditemsField(ite[i].children);
                    result=result.concat(result2);
                }
            }
        }
        return result;
    }

    function _initMapFields(){
        for(var i = 0, len=itemsField.length;i<len;i++){
            mapFieldItem[itemsField[i].fieldName]=itemsField[i];
        }
    }

    function setChangeOff(){
        for(var i=0,len=itemsField.length;i<len;i++){
            itemsField[i].clearValue();
        }
    }

    function getFieldsValues(onlyChange){
        var params={};
        for(var i=0,len=itemsField.length;i<len;i++){
            if(onlyChange==true){
                if(itemsField[i].isChange){
                    params[itemsField[i].fieldName]=itemsField[i].getValue();
                }
            }else{
                params[itemsField[i].fieldName]=itemsField[i].getValue();
            }
        }
        return params;
    }


    function _preValidRequired(){
        for(var i=0,len=itemsField.length;i<len;i++){
            if(itemsField[i].required === true){
                for(var j=0,lenj=listRecords.length;j<lenj;j++){
                    var value = listRecords[j][itemsField[i].fieldName]
                    if(value === "" || value === -1 || value === null){
                        MessageLib.showMessage(itemsField[i].labelAlias+ " "+qsTr("required"), mainroot);
                        return false;
                    }
                }
            }
        }
        return true;
    }


//    function _reload(){//TODO reload cuando no dialog
//        var params = getFieldsNames();
//        openBusy();
//        var data = QJsonNetworkQml.recursiveCall("sread","model."+modelName+".search_read",
//                                                 [
//                                                     [['id','=',idRecord]],
//                                                     0,2,[],params,
//                                                     preferences
//                                                 ]);
//        closeBusy();
//        if(data.data!=="error"){
//            if(data.data.result.length>0){
//                var obj = data.data.result[0];
//                setValues(obj);
//            }
//        }
//    }

    function getFieldsNames(){
        var params=[];
        for(var i=0,len=itemsField.length;i<len;i++){
            params.push(fieldName+"."+itemsField[i].fieldName)
            if(itemsField[i].type=="many2one"){
                params.push(fieldName+"."+itemsField[i].fieldName+".rec_name");
            }
        }
        params.push(fieldName+"."+"id");
        if(isSequence){
            params.push(fieldName+"."+fieldSequence);
        }
        return params;
    }

    function getFieldsNamesTryton40(){
        var params=[];
        for(var i=0,len=itemsField.length;i<len;i++){
            params.push(itemsField[i].fieldName)
            if(itemsField[i].type=="many2one"){
                params.push(itemsField[i].fieldName+".rec_name");
            }
        }
        params.push("id");
        return params;
    }

    function getFieldsNamesO2M(){
        var listParentNames = [];
        var listNames = getFieldsNames();
        for(var i=0,len=listNames.length;i<len;i++){
            listParentNames.push(fieldName+"."+listNames[i]);
        }
        return listParentNames;
    }


    function setValues(values){
        for(var i=0,len=itemsField.length;i<len;i++){
            itemsField[i].setValue(values[itemsField[i].fieldName]);
        }
    }
}
