//this file is part the thesa: tryton client based PySide2(qml2)
// Many2One
//__author__ = "Numael Garay"
//__copyright__ = "Copyright 2020-2021"
//__license__ = "GPL"
//__version__ = "1.0.0"
//__maintainer__ = "Numael Garay"
//__email__ = "mantrixsoft@gmail.com"

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import "../thesatools"
import "../thesatools/conections.js" as ConectionLib


// getValue() -> id
// setValue({"id":-1, "name":""}) no emit change
// updateValue({"id":-1, "name":""})//emit change
// signal onValueChanged(value)


InputSearchPopupList{
    id:controlm2o
    property bool tryton: true
    property string fieldName: ""
    property string type: "many2one"
    //    property bool required: false
    //    property bool readOnly: false
    //    enabled: !readOnly
    property string modelName: ""
    property var domain:[]
    property var order:[]
    property int limit: 300
    property bool boolLastCall: false

    //property bool isChange: false
    //signal change(string text)

    //    Component.onCompleted: {
    //        control.objectName="tryton_"+fieldName+"_"+_getNewNumber();
    //    }

    function getId(){
        if(valueId==-1){
            return null;
        }
        return valueId;
    }

    function getValue(){
        return getId();
    }

    Timer{
        id:tsoneif
        interval: 100
        onTriggered: {
            _selectIfOneItem();
        }
    }
    function selectIfOneItem(){
        tsoneif.restart();
    }
    property var context: ({})
    function _selectIfOneItem(){
//        var domainplus = [];
//        domainplus.push(domain);
//        if(!QJsonNetworkQml.isRunning()){
//            var result= QJsonNetworkQml.recursiveCall("@cm2oone",
//                                                      "model."+modelName+".search_read",
//                                                      [
//                                                          domainplus,
//                                                          0,
//                                                          limit,
//                                                          order,
//                                                          ['id','rec_name'],
//                                                          preferences
//                                                      ]
//                                                      );
//            if(result.data!=="error"){
//                var resultArray = result.data.result;
//                if(resultArray.length === 1){
//                    updateValue({"id":resultArray[0].id, "name":resultArray[0].rec_name});
//                }
//            }
//        }
    }

    function listSearch(methodlocal, paramslocal){
//        paramstempup=params;
        var r_params = prepareParamsLocal(methodlocal, paramslocal);
        ConectionLib.jsonRpcAction(controlm2o,r_params,context,
                                   "controlm2o.listSearchOk(response)",
                                   "controlm2o.listSearchCancel()",
                                   "controlm2o.listSearchError()");
    }
    function listSearchOk(response){
//        var response = JSON.parse(http.responseText.toString());
        if(response.hasOwnProperty("result")){
            var dataList=[];
            var resultArray = response["result"];
            for(var i=0,len=resultArray.length;i<len;i++){
                dataList.push({"id":resultArray[i].id, "name":resultArray[i].rec_name});
            }
            if(len==0){
                showtooltip(qsTr("no items"));
            }

            updateModel(dataList);
            if(boolLastCall){
                boolLastCall=false;
                if(boolSearch==true && boolValueAssigned==false){
                    execTimerDelaySearch();// textChanged last
                }
            }
        }else{
            textSearch="";
            analizeErrors(response);
        }
    }
    function listSearchCancel(){

    }
    function listSearchError(){

    }

//    function qqlistSearch(methodlocal, paramslocal) {
//        openBusy();
//        //        var methodlocal= "model."+modelName+".search_read";
//        //        var paramslocal=[true,{}];
//        var params = prepareParamsLocal(methodlocal, paramslocal);
//        var url = getUrl();
//        var http = getHttpRequest(url, params,"");
//        //        var timer = Qt.createQmlObject("import QtQuick 2.3; Timer {interval: 4000; repeat: false; running: true;}",mainroot,"MyTimer");
//        //        timer.triggered.connect(function(){
//        //            http.abort();
//        //            console.log("timeout");

//        //        });
//        //        timer.start();

//        http.onreadystatechange = function() { // Call a function when the state changes.
//            if (http.readyState == 4) {
//                if (http.status == 200) {
//                    closeBusy();
//                    //                    console.log(http.responseText);
//                    var response = JSON.parse(http.responseText.toString());
//                    if(response.hasOwnProperty("result")){
//                        var dataList=[];
//                        var resultArray = response["result"];
//                        for(var i=0,len=resultArray.length;i<len;i++){
//                            dataList.push({"id":resultArray[i].id, "name":resultArray[i].rec_name});
//                        }
//                        if(len==0){
//                            showtooltip(qsTr("no items"));
//                        }

//                        updateModel(dataList);
//                        if(boolLastCall){
//                            boolLastCall=false;
//                            if(boolSearch==true && boolValueAssigned==false){
//                                execTimerDelaySearch();// textChanged last
//                            }
//                        }
//                    }else{
//                        textSearch="";
//                        analizeErrors(response);
//                    }

//                } else {
//                    MessageLib.showMessage("error: "+http.status,mainroot);
//                    closeBusy();
//                }
//            }
//        }
//        http.send(JSON.stringify(params));

//    }

    onTextChanged: {
        var domainplus = [];
        if(text.trim()!=""){
            domainplus.push(['rec_name', 'ilike', '%'+text+'%']);
        }

        domainplus.push(domain);

        listSearch("model."+modelName+".search_read",
                   [
                       domainplus,
                       0,
                       limit,
                       order,
                       ['id','rec_name'],
                       preferences
                   ]);

    }

    //    onTextChanged: {
    //        var domainplus = [];
    //        if(text.trim()!=""){
    //            domainplus.push(['rec_name', 'ilike', '%'+text+'%']);
    //        }

    //        domainplus.push(domain);
    //        if(!QJsonNetworkQml.isRunning()){
    //            var result= QJsonNetworkQml.recursiveCall("@cm2o"+countSearch,
    //                                                      "model."+modelName+".search_read",
    //                                                      [
    //                                                          domainplus,
    //                                                          0,
    //                                                          limit,
    //                                                          order,
    //                                                          ['id','rec_name'],
    //                                                          preferences
    //                                                      ]
    //                                                      );
    //            if(result.data!=="error"){
    //                var dataList=[];
    //                var resultArray = result.data.result;
    //                for(var i=0,len=resultArray.length;i<len;i++){
    //                    dataList.push({"id":resultArray[i].id, "name":resultArray[i].rec_name});
    //                }
    //                if(len==0){
    //                    showtooltip(qsTr("no items"));
    //                }

    //                updateModel(dataList);
    //                if(boolLastCall){
    //                    boolLastCall=false;
    //                    if(boolSearch==true && boolValueAssigned==false){
    //                        execTimerDelaySearch();// textChanged last
    //                    }
    //                }
    //            }else{
    //                textSearch="";
    //            }
    //        }else{
    //            boolLastCall = true;
    //        }
    //    }

}
