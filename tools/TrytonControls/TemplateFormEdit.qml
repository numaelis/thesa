//this file is part the thesa: tryton client based PySide2(qml2)
// template form edit
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
//TODO more type fields, onChange,
Pane{
    id:templateForm
    property bool tryton: true
    property string type: "form"
    property string modelName: ""
    property bool readOnly: false
    property int idRecord: -1
    property var myParent: -1
    property var paramsPlusCreate: ({})
    property var paramsPlusUpdate: ({})

    signal updated(var fields)
    signal created(var fields)

    onUpdated: {
        if(myParent!=-1){
            myParent.updated(fields)
            myParent.updateTreeView(fields)
        }
    }

    onCreated: {
        if(myParent!=-1){
            myParent.created(fields)
            myParent.acceptDialogSearch(fields);
        }
    }

    property var itemsField:[]
    property var mapFieldItem: ({})

    Component.onCompleted: {
        _initFields();
        clearValues();
    }

    function _initFields(){
        itemsField = finditemsField(templateForm.contentItem.children);
        _initMapFields();
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
//            if(ite[i].children.length>0){
//                result2 = finditemsField(ite[i].children);
//                result=result.concat(result2);
//            }
        }
        return result;
    }

    function _initMapFields(){
        for(var i = 0, len=itemsField.length;i<len;i++){
            mapFieldItem[itemsField[i].fieldName]=itemsField[i];
        }
    }

    function clearValues(){
        for(var i=0,len=itemsField.length;i<len;i++){
            itemsField[i].clearValue();
        }
        idRecord=-1;
        if(myParent!=-1){
            myParent.idRecord = -1;
        }
    }

    function _updateRPC(params){
        openBusy();
        var data = QJsonNetworkQml.recursiveCall("update..","model."+modelName+".write",
                                                 [
                                                     [idRecord],
                                                         params,
                                                     preferences
                                                 ]);
        closeBusy();
        if(data.data!=="error"){
            params["id"]=idRecord;
            updated(params);
            return true;
        }
        return false;
    }

    function getFieldsValues(onlyChange){
        var params={};
        for(var i=0,len=itemsField.length;i<len;i++){
            if(onlyChange==true){
                if(itemsField[i].isChange){
                    params[itemsField[i].fieldName]=itemsField[i].getValue();
                }
            }else{
                if(itemsField[i].readOnly==false){
                    params[itemsField[i].fieldName]=itemsField[i].getValue();
                }
            }
        }
        return params;
    }

    function _preUpdate(){
        if(_preValidRequired()==true){
            var paramsf = getFieldsValues(true);
            if(Object.keys(paramsf).length>0){
                var params = Object.assign(paramsf,paramsPlusUpdate)
                if(_updateRPC(params)==true){
                    if(myParent!=-1){
                        myParent.accept();
                        clearValues();
                    }else{

                    }

                    //MessageLib.showMessage(qsTr("Updated"), mainroot);
                    MessageLib.showToolTip(qsTr("Updated"),16,3000,"white","green", mainroot);
                    return true;
                }else{
                   // MessageLib.showMessage(qsTr("No Updated"), mainroot);
                    MessageLib.showToolTip(qsTr("No Updated"),16,3000,"white","red", mainroot);
                    return false;
                }
            }else{
                if(myParent!=-1){
                    myParent.accept();
                    clearValues();
                }
                return true;
            }
        }else{
            return false;
        }
    }

    function _preValidRequired(){
        for(var i=0,len=itemsField.length;i<len;i++){
            var value =itemsField[i].getValue();
            if(itemsField[i].required === true){
                if(itemsField[i].type=="one2many"){
                    var bres = itemsField[i]._preValidRequired();
                    if(bres==false){
                        return false;
                    }
                }else{
                    if(value === "" || value === -1 || value === null){
                        MessageLib.showMessage(itemsField[i].labelAlias+ " "+qsTr("required"), mainroot);
                        itemsField[i]._forceActiveFocus();
                        return false;
                    }
                }
            }
        }
        return true;
    }

    function _save(){
        if(idRecord==-1){
            return _preCreate();
        }else{
            return _preUpdate();
        }
    }

    function _preCreate(){
        if(_preValidRequired()==true){
            var paramsf = getFieldsValues(false);
            if(Object.keys(paramsf).length>=0){
                var params = Object.assign(paramsf,paramsPlusCreate)
                if(_createRPC(params)==true){
                    if(myParent!=-1){
                        myParent.accept();
                        clearValues();
                    }else{

                    }
                    //MessageLib.showMessage(qsTr("Created"), mainroot);
                    MessageLib.showToolTip(qsTr("Created"),16,3000,"white","green", mainroot);
                    return true;
                }else{
                    MessageLib.showToolTip(qsTr("No Created"),16,3000,"white","red", mainroot);
                    //MessageLib.showMessage(qsTr("No Created"), mainroot);
                    return false;
                }
            }
            //return true;
        }else{
            return false;
        }
    }

    function _createRPC(params){
        openBusy();
        var data = QJsonNetworkQml.recursiveCall("crearin","model."+modelName+".create",
                                                 [
                                                     [ params
                                                     ],
                                                     preferences
                                                 ]);
        closeBusy();
        if(data.data!=="error"){
            var idResult = data.data.result[0];
            params["id"]=idResult;
            idRecord = idResult;
            created(params);
            return true
        }

        return false;
    }

    function _reload(){
        var params = getFieldsNames();
        openBusy();
        var data = QJsonNetworkQml.recursiveCall("sread","model."+modelName+".search_read",
                                                 [
                                                     [['id','=',idRecord]],
                                                     0,2,[],params,
                                                     preferences
                                                 ]);
        closeBusy();
        if(data.data!=="error"){
            if(data.data.result.length>0){
                var obj = data.data.result[0];
                setValues(obj);
            }
        }else{
            clearValues();
            if(myParent!=-1){
                if(myParent.type == "dialogedit"){
                    myParent.emitActionCancel();
                }
            }
        }
    }

    function getFieldsNames(){
        var params=[];
        for(var i=0,len=itemsField.length;i<len;i++){
                params.push(itemsField[i].fieldName)
            if(itemsField[i].type=="many2one"){
                params.push(itemsField[i].fieldName+".rec_name");
            }
            if(itemsField[i].type=="one2many"){
                var _po2m = itemsField[i].getFieldsNames();
               // params = Object.assign(params,_po2m)
                params=params.concat(_po2m);
            }

        }
        return params;
    }

    function setValues(values){
        for(var i=0,len=itemsField.length;i<len;i++){
            if(itemsField[i].type=="many2one"){
                if(values[itemsField[i].fieldName]!=null){
                    if(setting.typelogin==0){//Tryton 4
                        itemsField[i].setValue({"id":values[itemsField[i].fieldName],"name":values[itemsField[i].fieldName+".rec_name"]});
                    }else{
                        itemsField[i].setValue({"id":values[itemsField[i].fieldName+"."]["id"],"name":values[itemsField[i].fieldName+"."]["rec_name"]});
                    }
                }else{
                    itemsField[i].setValue({"id":-1,"name":""})
                }
            }else{
                if(itemsField[i].type=="one2many"){
                    if(setting.typelogin==0){//Tryton 4
                        itemsField[i].setValueTryton40(values[itemsField[i].fieldName]);
                    }else{
                        itemsField[i].setValue(values[itemsField[i].fieldName+"."]);
                    }
                }else{
                    itemsField[i].setValue(values[itemsField[i].fieldName]);
                }
            }
        }
    }

    function _forceActiveFocus(){
        for(var i=0,len=itemsField.length;i<len;i++){
            if(itemsField[i].readOnly==false){
               itemsField[i]._forceActiveFocus();
                break;
            }
        }
    }
}
