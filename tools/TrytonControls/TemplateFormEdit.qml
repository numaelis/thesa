//this file is part the thesa: tryton client based PySide2(qml2)
// template form edit
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
import "../thesatools/conections.js" as ConectionLib
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
    property var context: ({})
    property var _timestamp: null
    property bool readAfterAction: true
    onReadAfterActionChanged: {
//        console.log("ahora",readAfterAction)
    }

    property string beforeAction: ""
    signal updated(var fields)
    signal created(var fields)

    onUpdated: {
        if(myParent!=-1){
            myParent.updated(fields)
            myParent.updateTreeView(fields)
            myParent.signalAfter();
        }
    }

    onCreated: {
        if(myParent!=-1){
            myParent.created(fields)
            myParent.acceptDialogSearch(fields);
            myParent.signalAfter();
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
        _timestamp=null;
        beforeAction="";
        readAfterAction=true;
    }

    function getFields_context_timestamp(){
        var ocontext={};
        for(var i=0,len=itemsField.length;i<len;i++){//itemsField[i].isChange == true &&
            if(itemsField[i].type == "one2many"){
//                console.log(JSON.stringify(itemsField[i].get_context_timestamp()))
                ocontext = Object.assign(JSON.parse(JSON.stringify(ocontext)), itemsField[i].get_context_timestamp());
            }

//            if(onlyChange==true){
//                if(itemsField[i].isChange){
//                    params[itemsField[i].fieldName]=itemsField[i].getValue();
//                }
//            }else{
//                if(itemsField[i].readOnly==false){
//                    params[itemsField[i].fieldName]=itemsField[i].getValue();
//                }
//            }
        }
//        console.log("q",JSON.stringify(ocontext))
        return ocontext;
    }
    function isChanged(){
        var paramsf = getFieldsValues(true);
        if(Object.keys(paramsf).length>0){
            return true;
        }
        return false
    }

    function context_timestamp(){
//        var ocontext = JSON.parse('{"_timestamp":{"'+modelName+','+idRecord.toString()+'":"'+_timestamp+'"}}');
        var ocontext ={}
        if(_timestamp==null){//|| readAfterAction==false
            ocontext=JSON.parse('{"'+modelName+','+idRecord.toString()+'":'+null+'}');
        }else{
            ocontext=JSON.parse('{"'+modelName+','+idRecord.toString()+'":"'+_timestamp+'"}');

        }
        //add one2many timestamp
//        console.log(JSON.stringify(ocontext))

//        console.log(JSON.stringify(context),JSON.stringify(ocontext))
        ocontext = Object.assign(JSON.parse(JSON.stringify(ocontext)), getFields_context_timestamp());
//        console.log(JSON.stringify(ocontext));
        ocontext = {"_timestamp":ocontext};
        ocontext = Object.assign(JSON.parse(JSON.stringify(context)), ocontext);
        return ocontext;
    }
//    property bool reloadUpdate: value

    property var paramstempup:({})
    function _updateRPC(params){
        paramstempup=params;
        var r_params = prepareParamsLocal("model."+modelName+".write",
                                          [
                                              [idRecord],
                                                  params,
                                              contextPreferences(context_timestamp())
                                          ]);
        ConectionLib.jsonRpcAction(templateForm,r_params,context,
                                   "templateForm._updateRPCOk(response)",
                                   "templateForm._updateRPCCancel()",
                                   "templateForm._updateRPCError()");
    }
    function _updateRPCOk(response){
        paramstempup["id"]=idRecord;


        if(readAfterAction==false){
//                            console.log("aqui")
            updated(paramstempup);

            if(myParent!=-1){
                if(myParent.closeUpdate){
                    myParent.accept();
                    clearValues();
                }
            }else{

            }
            signalPreUpdate(true);
        }else{
            _tempParams=paramstempup;
            beforeAction="write"
            _reload();
        }

        //MessageLib.showMessage(qsTr("Updated"), mainroot);
        MessageLib.showToolTip(qsTr("Updated"),16,3000,"white","green", mainroot);
    }
    function _updateRPCCancel(){

    }
    function _updateRPCError(){
        MessageLib.showToolTip(qsTr("No Updated"),16,3000,"white","red", mainroot);
        signalPreUpdate(false);
    }

//    function _updateRPCLast(params){
//        openBusy();

//        var r_params = prepareParamsLocal("model."+modelName+".write",
//                                          [
//                                              [idRecord],
//                                                  params,
//                                              contextPreferences(context_timestamp())
//                                          ]);
//        var url = getUrl();
//        var http = getHttpRequest(url, r_params);

//        http.onreadystatechange = function() { // Call a function when the state changes.
//            if (http.readyState == 4) {
//                if (http.status == 200) {
//                    closeBusy();
//                    //                    console.log(http.responseText);
//                    var response = JSON.parse(http.responseText.toString());
//                    if(response.hasOwnProperty("result")){
//                        params["id"]=idRecord;


//                        if(readAfterAction==false){
////                            console.log("aqui")
//                            updated(params);

//                            if(myParent!=-1){
//                                if(myParent.closeUpdate){
//                                    myParent.accept();
//                                    clearValues();
//                                }
//                            }else{

//                            }
//                            signalPreUpdate(true);
//                        }else{
//                            _tempParams=params;
//                            beforeAction="write"
//                            _reload();
//                        }

//                        //MessageLib.showMessage(qsTr("Updated"), mainroot);
//                        MessageLib.showToolTip(qsTr("Updated"),16,3000,"white","green", mainroot);


//                    }else{
//                        analizeErrors(response);
//                        MessageLib.showToolTip(qsTr("No Updated"),16,3000,"white","red", mainroot);
//                        signalPreUpdate(false);
//                    }

//                } else {
//                    MessageLib.showMessage("error: "+http.status,mainroot);
//                    closeBusy();
//                }
//            }
//        }
//        http.send(JSON.stringify(r_params));



////        var data = QJsonNetworkQml.recursiveCall("update..","model."+modelName+".write",
////                                                 [
////                                                     [idRecord],
////                                                         params,
////                                                     preferences
////                                                 ]);
////        closeBusy();
////        if(data.data!=="error"){
////            params["id"]=idRecord;
////            updated(params);
////            return true;
////        }
////        return false;
//    }

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
                var params = Object.assign(paramsf,paramsPlusUpdate);
                _updateRPC(params);
//                if(_updateRPC(params)==true){
//                    if(myParent!=-1){
//                        myParent.accept();
//                        clearValues();
//                    }else{

//                    }

//                    //MessageLib.showMessage(qsTr("Updated"), mainroot);
//                    MessageLib.showToolTip(qsTr("Updated"),16,3000,"white","green", mainroot);
//                    return true;
//                }else{
//                   // MessageLib.showMessage(qsTr("No Updated"), mainroot);
//                    MessageLib.showToolTip(qsTr("No Updated"),16,3000,"white","red", mainroot);
//                    return false;
//                }
            }else{
                if(myParent.closeUpdate){
                    if(myParent!=-1){
                        myParent.accept();
                        clearValues();
                    }
                }
                signalPreUpdate(true);
            }
        }else{
            signalPreUpdate(false);
        }
        _fixModeO2M();
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
            _preCreate();
        }else{
            _preUpdate();
        }
    }
    signal signalPreCreate(bool result)
    signal signalPreUpdate(bool result)
    signal signalSave(bool result)

    onSignalPreCreate: {
        signalSave(result)
    }
    onSignalPreUpdate: {
        signalSave(result)
    }

    function _preCreate(){
        if(_preValidRequired()==true){
            var paramsf = getFieldsValues(false);
            if(Object.keys(paramsf).length>=0){
                var params = Object.assign(paramsf,paramsPlusCreate)
                _createRPC(params);
//                if(_createRPC(params)==true){
//                    if(myParent!=-1){
//                        myParent.accept();
//                        clearValues();
//                    }else{

//                    }
//                    //MessageLib.showMessage(qsTr("Created"), mainroot);
//                    MessageLib.showToolTip(qsTr("Created"),16,3000,"white","green", mainroot);
//                    return true;
//                }else{
//                    MessageLib.showToolTip(qsTr("No Created"),16,3000,"white","red", mainroot);
//                    //MessageLib.showMessage(qsTr("No Created"), mainroot);
//                    return false;
//                }
            }
            //return true;
        }else{
            signalPreCreate(false);
        }
        _fixModeO2M();
    }

    property var paramstemp:({})
    function _createRPC(params){
        paramstemp=params;
        var r_params = prepareParamsLocal("model."+modelName+".create",
                                        [
                                            [ params
                                            ],
                                            contextPreferences(context)
                                        ]);
        ConectionLib.jsonRpcAction(templateForm,r_params,context,
                                   "templateForm._createRPCOk(response)",
                                   "templateForm._createRPCCancel()",
                                   "templateForm._createRPCError()");
    }
    function _createRPCOk(response){
        var idResult = response.result[0];
        paramstemp["id"]=idResult;
        idRecord = idResult;
        if(readAfterAction==false){
            created(paramstemp);
            //////////
            if(myParent!=-1){
                if(myParent.closeCreate){
                    myParent.accept();
                    clearValues();
                }
            }else{

            }
            signalPreCreate(true);
        }else{
            _tempParams=paramstemp;
            beforeAction="create"
            _reload();
        }

        //MessageLib.showMessage(qsTr("Created"), mainroot);
        MessageLib.showToolTip(qsTr("Created"),16,3000,"white","green", mainroot);
    }
    function _createRPCCancel(){

    }
    function _createRPCError(){
        MessageLib.showToolTip(qsTr("No Created"),16,3000,"white","red", mainroot);
        signalPreCreate(false);
    }

//    function _createRPCLast(params){
//        openBusy();

//        var r_params = prepareParamsLocal("model."+modelName+".create",
//                                        [
//                                            [ params
//                                            ],
//                                            contextPreferences(context)
//                                        ]);
//        var url = getUrl();
//        var http = getHttpRequest(url, r_params);

//        http.onreadystatechange = function() { // Call a function when the state changes.
//            if (http.readyState == 4) {
//                if (http.status == 200) {
//                    closeBusy();
//                    //                    console.log(http.responseText);
//                    var response = JSON.parse(http.responseText.toString());
//                    if(response.hasOwnProperty("result")){
//                        var idResult = response.result[0];
//                        params["id"]=idResult;
//                        idRecord = idResult;
//                        if(readAfterAction==false){
//                            created(params);
//                            //////////
//                            if(myParent!=-1){
//                                if(myParent.closeCreate){
//                                    myParent.accept();
//                                    clearValues();
//                                }
//                            }else{

//                            }
//                            signalPreCreate(true);
//                        }else{
//                            _tempParams=params;
//                            beforeAction="create"
//                            _reload();
//                        }

//                        //MessageLib.showMessage(qsTr("Created"), mainroot);
//                        MessageLib.showToolTip(qsTr("Created"),16,3000,"white","green", mainroot);

//                    }else{
//                        analizeErrors(response);
//                        MessageLib.showToolTip(qsTr("No Created"),16,3000,"white","red", mainroot);
//                        signalPreCreate(false);
//                    }

//                } else {
//                    MessageLib.showMessage("error: "+http.status,mainroot);
//                    closeBusy();
//                }
//            }
//        }
//        http.send(JSON.stringify(r_params));


////        var data = QJsonNetworkQml.recursiveCall("crearin","model."+modelName+".create",
////                                                 [
////                                                     [ params
////                                                     ],
////                                                     preferences
////                                                 ]);
////        closeBusy();
////        if(data.data!=="error"){
////            var idResult = data.data.result[0];
////            params["id"]=idResult;
////            idRecord = idResult;
////            created(params);
////            return true
////        }

////        return false;
//    }

    function _default(fields){
        var r_params = prepareParamsLocal("model."+modelName+".default_get",
                                          [
                                              fields,
                                              preferences
                                          ]);

        ConectionLib.jsonRpcAction(templateForm,r_params,context,
                                   "templateForm._defaultOk(response)",
                                   "templateForm._defaultBack()",
                                   "templateForm._defaultError()");
    }
    function _defaultOk(response){
        setValues(response.result);
    }
    function _defaultBack(){

    }
    function _defaultError(){
        clearValues();
        if(myParent!=-1){
            if(myParent.type == "dialogedit"){
                if(myParent.closeCreate){
                    myParent.emitActionCancel();
                }
            }
        }
    }

//    function _defaultLast(fields){

////        var params = getFieldsNames();
//        openBusy();

//        var r_params = prepareParamsLocal("model."+modelName+".default_get",
//                                          [
//                                              fields,
//                                              preferences
//                                          ]);
//        var url = getUrl();
//        var http = getHttpRequest(url, r_params,"");

//        http.onreadystatechange = function() { // Call a function when the state changes.
//            if (http.readyState == 4) {
//                if (http.status == 200) {
//                    closeBusy();
//                    var response = JSON.parse(http.responseText.toString());
//                    if(response.hasOwnProperty("result")){
////                        console.log(JSON.stringify(response))
//                        setValues(response.result);

//                    }else{
//                        analizeErrors(response);
//                        clearValues();
//                        if(myParent!=-1){
//                            if(myParent.type == "dialogedit"){
//                                if(myParent.closeCreate){
//                                    myParent.emitActionCancel();
//                                }
//                            }
//                        }
//                    }

//                } else {
//                    MessageLib.showMessage("error: "+http.status,mainroot);
//                    closeBusy();
//                }
//            }
//        }
//        http.send(JSON.stringify(r_params));

//    }
    property var _tempParams:({})
    Timer{
        id:tAfterReload
        interval: 200
        onTriggered: {
            if(beforeAction=="create"){
                created(_tempParams);
                if(myParent!=-1){
                    if(myParent.closeCreate){
                        myParent.accept();
                        clearValues();
                    }
                }else{

                }
                beforeAction="";
                signalPreCreate(true);
                _tempParams={};
            }
            if(beforeAction=="write"){
                updated(_tempParams);
                if(myParent!=-1){
                    if(myParent.closeUpdate){
                        myParent.accept();
                        clearValues();
                    }
                }else{

                }
                signalPreUpdate(true);
                beforeAction="";
                _tempParams={};
            }
        }
    }
    function _fixModeO2M(){
        for(var i=0,len=itemsField.length;i<len;i++){
            if(itemsField[i].type=="one2many"){
                itemsField[i].mode=itemsField[i].mode_init;
            }
        }
    }

    function _reload(){
        var params = getFieldsNames();
        //                                              [['id','=',idRecord]],
        //                                              0,2,[],
        var r_params = prepareParamsLocal("model."+modelName+".read",
                                          [
                                              [idRecord],
                                              params,
                                              contextPreferences(context)
                                          ]);

        ConectionLib.jsonRpcAction(templateForm,r_params,context,
                                   "templateForm._reloadOk(response)",
                                   "templateForm._reloadBack()",
                                   "templateForm._reloadError()");
    }
    function _reloadOk(response){
        if(response.result.length>0){
            var obj = response.result[0];
            setValues(obj);
            tAfterReload.restart();
        }
    }
    function _reloadBack(){

    }
    function _reloadError(){
        //analizeErrors(response);
        clearValues();
        if(myParent!=-1){
            if(myParent.type == "dialogedit"){
                myParent.emitActionCancel();
            }
        }
    }

//    function _reloadLast(){
//        var params = getFieldsNames();
//        openBusy();
//        //                                              [['id','=',idRecord]],
//        //                                              0,2,[],

//        var r_params = prepareParamsLocal("model."+modelName+".read",
//                                          [
//                                              [idRecord],
//                                              params,
//                                              contextPreferences(context)
//                                          ]);
//        var url = getUrl();
//        var http = getHttpRequest(url, r_params,"");

//        http.onreadystatechange = function() { // Call a function when the state changes.
//            if (http.readyState == 4) {
//                if (http.status == 200) {
//                    closeBusy();
//                    var response = JSON.parse(http.responseText.toString());
////                    console.log(http.responseText.toString());
//                    if(response.hasOwnProperty("result")){
//                        if(response.result.length>0){
//                            var obj = response.result[0];
//                            setValues(obj);
//                            tAfterReload.restart();
//                        }
//                    }else{
//                        analizeErrors(response);
//                        clearValues();
//                        if(myParent!=-1){
//                            if(myParent.type == "dialogedit"){
//                                myParent.emitActionCancel();
//                            }
//                        }
//                    }

//                } else {
//                    MessageLib.showMessage("error: "+http.status,mainroot);
//                    closeBusy();
//                }
//            }
//        }
//        http.send(JSON.stringify(r_params));


////        var data = QJsonNetworkQml.recursiveCall("sread","model."+modelName+".search_read",
////                                                 [
////                                                     [['id','=',idRecord]],
////                                                     0,2,[],params,
////                                                     preferences
////                                                 ]);
////        closeBusy();
////        if(data.data!=="error"){
////            if(data.data.result.length>0){
////                var obj = data.data.result[0];
////                setValues(obj);
////            }
////        }else{
////            clearValues();
////            if(myParent!=-1){
////                if(myParent.type == "dialogedit"){
////                    myParent.emitActionCancel();
////                }
////            }
////        }
//    }

    function getFieldsNames(){
        var params=[];
        for(var i=0,len=itemsField.length;i<len;i++){
                params.push(itemsField[i].fieldName)
            if(itemsField[i].type=="many2one"){
                params.push(itemsField[i].fieldName+".rec_name");
            }
            if(itemsField[i].type=="one2many"){
                var _po2m = [];
                if(setting.typelogin==0){
//                    _po2m=itemsField[i].getFieldsNamesTryton40();
                }else{
                    _po2m=itemsField[i].getFieldsNames();
                }

               // params = Object.assign(params,_po2m)
                params=params.concat(_po2m);
            }

        }
        params.push("rec_name");
        params.push("_timestamp");
        return params;
    }

    function getFieldsNamesSimple(){
        var params=[];
        for(var i=0,len=itemsField.length;i<len;i++){
                params.push(itemsField[i].fieldName)
//            if(itemsField[i].type=="many2one"){
//                params.push(itemsField[i].fieldName+".rec_name");
//            }
            if(itemsField[i].type=="one2many"){
                var _po2m = itemsField[i].getFieldsNames();
               // params = Object.assign(params,_po2m)
                params=params.concat(_po2m);
            }

        }
        return params;
    }

    function setValues(values){
        if(values.hasOwnProperty("_timestamp")){
            _timestamp=values["_timestamp"];
        }
        for(var i=0,len=itemsField.length;i<len;i++){
            if(itemsField[i].type=="many2one"){
                if(values[itemsField[i].fieldName]!=null){
                    if(setting.typelogin==0){//Tryton 4
                        if(values[itemsField[i].fieldName] && values[itemsField[i].fieldName+".rec_name"]){
                            itemsField[i].setValue({"id":values[itemsField[i].fieldName],"name":values[itemsField[i].fieldName+".rec_name"]});
                        }
                    }else{
                        if(values[itemsField[i].fieldName+"."]["id"] && values[itemsField[i].fieldName+"."]["rec_name"]){
                            itemsField[i].setValue({"id":values[itemsField[i].fieldName+"."]["id"],"name":values[itemsField[i].fieldName+"."]["rec_name"]});
                        }
                    }
                }else{
                    itemsField[i].setValue({"id":-1,"name":""})
                }
            }else{
                if(itemsField[i].type=="one2many"){
                    if(setting.typelogin==0){//Tryton 4
                        if(values[itemsField[i].fieldName]){
                            itemsField[i].setValueTryton40(values[itemsField[i].fieldName]);
                        }
                    }else{
                        if(values[itemsField[i].fieldName+"."]){
                            itemsField[i].setValue(values[itemsField[i].fieldName+"."]);
                        }
                    }
                }else{
                    if(values[itemsField[i].fieldName]){
                        itemsField[i].setValue(values[itemsField[i].fieldName]);
                    }
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
