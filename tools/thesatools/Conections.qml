//this file is part of Thesa
//__author__ = "Numael Garay"
//__copyright__ = "Copyright 2020-2022"
//__license__ = "GPL"
//__version__ = "1.0"

import QtQuick 2.15
import "messages.js" as MessageLib
Item {
    id:conection
    signal signalResult(var response)
    signal signalError()
    signal signalCancel()
    property bool autoDestroy: true
    property var _params: ({})
    property var _init_params: ({})
    property var _mcontext: ({})
    property bool useBusy: true
    property bool waitUseWarning: false
    property bool waitUseLogin: false
    signal analize(var response)

    onAnalize: {
        if(response.hasOwnProperty("result")){
            if(waitUseWarning){
                waitUseWarning=false;
                _params=JSON.parse(JSON.stringify(_init_params));
                _recursive(_params, "");
            }else{
                if(waitUseLogin){
                    if(response["result"]==null){
                        if(useBusy){
                            closeBusy();
                        }
                        MessageLib.showQuestionInputPass("Re-Enter password",
                                                         mainroot,
                                                         "conection.actionPassOk(text)",
                                                         "conection.notActionPassOk()");
                    }else{
                        if (response["result"].length>0 &&  Array.isArray(response["result"])){
                            waitUseLogin=false;
                            listToken=response["result"];
                            sessionToken = QJsonNetworkQml.getSessionToken(setting.user, response["result"]);
                            //boolLogin=true;
//                            luser=setting.user;
                            //                    if(boolSession==false){
                            //                        boolSession=true;
                            //                        getPreferences();
                            //                    }
                            _params=JSON.parse(JSON.stringify(_init_params));
                            _recursive(_params, "");
                        }else{
                            if(useBusy){
                                closeBusy();
                            }
                            MessageLib.showQuestionInputPass("Re-Enter password",
                                                             mainroot,
                                                             "conection.actionPassOk(text)",
                                                             "conection.notActionPassOk()");
                        }
                    }
                }else{
                    signalResult(response);
                    if(useBusy){
                        closeBusy();
                    }
                    if(autoDestroy){
                        tcloseAll.start();
                    }
                }
            }

        }else{
            if(response.error[0] == "UserWarning"){
                if(useBusy){
                    closeBusy();
                }
                var title = response["error"][1][0];
                var info = response["error"][1][1];
                var data = {"name":title, "info":info};
                MessageLib.showQuestionCheckOption(info,mainroot,data,"conection.actionCheckOk(dataCheck)","conection.notActionCheckOk()");


            }else{
                if(response.error[0].startsWith("403") || response.error[0].startsWith("401")){
                    if(useBusy){
                        closeBusy();
                    }
                    MessageLib.showQuestionInputPass("Re-Enter password",
                                                     mainroot,
                                                     "conection.actionPassOk(text)",
                                                     "conection.notActionPassOk()");
                }else{
                    analizeErrors(response);
                    signalError();
                    if(useBusy){
                        closeBusy();
                    }
                    if(autoDestroy){
                        tcloseAll.start();
                    }
                }
            }

            //analizeErrors(response);

        }
    }
    function actionPassOk(text){
        _params = prepareParamsLocal(methodLogin,
                                    [setting.user, text]);
        waitUseLogin=true;
        _recursive(_params, methodLogin);
    }
    function notActionPassOk(){
        signalCancel();
        if(autoDestroy){
            tcloseAll.start();
        }
    }

    function actionCheckOk(dataCheck){
        _params = prepareParamsLocal("model.res.user.warning.create",
                                    [
                                         [{'always': dataCheck.check,
                                              'user': listToken[0],
                                              'name': dataCheck.name}],
                                         contextPreferences(_mcontext)
                                    ]);
        waitUseWarning=true;
        _recursive(_params, "");

    }
    function notActionCheckOk(){
        signalCancel();
        if(autoDestroy){
            tcloseAll.start();
        }
    }

    Timer{
        id:tcloseAll
        interval: 800
        onTriggered: {destroy(0);}
    }

    function recursiveConect(){//, action, notaction){
        _init_params=JSON.parse(JSON.stringify(_params));
        _recursive(_params,"");
    }

    function _recursive(params, method){
        if(useBusy){
            openBusy();
        }

        var url = getUrl();
        var http = getHttpRequest(url, params, method);

        http.onreadystatechange = function() { // Call a function when the state changes.
            if (http.readyState == 4) {
                if (http.status == 200) {
                    var response = JSON.parse(http.responseText.toString());
                    analize(response);
                } else {
                    MessageLib.showMessage("error: "+http.status,mainroot);
                    signalError();
                    if(useBusy){
                        closeBusy();
                    }
                    if(autoDestroy){
                        tcloseAll.start();
                    }
                }
            }
        }
        http.send(JSON.stringify(params));
    }
}
