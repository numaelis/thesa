//this file is part the thesa: tryton client based PySide2(qml2)
// Many2One
//__author__ = "Numael Garay"
//__copyright__ = "Copyright 2020"
//__license__ = "GPL"
//__version__ = "1.0.0"
//__maintainer__ = "Numael Garay"
//__email__ = "mantrixsoft@gmail.com"

import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.2
import "../thesatools"

//TODO facilitate the search for a many2one field
//* a popup list updates the text
//*...?

// setValue({"id":-1, "name":""})
// signal onValueChanged(value)
// signal clear()

InputSearchPopupList{
    id:controlo2m
    property string modelName: ""
    property var domain:[]
    property var order:[]
    property int limit: 500
    property bool boolLastCall: false
    onTextChanged: {
        var domainplus = [];
        domainplus.push(['rec_name', 'ilike', '%'+text+'%']);
        domainplus.push(domain);
        if(!QJsonNetworkQml.isRunning()){
            var result= QJsonNetworkQml.recursiveCall("@co2m"+countSearch,
                                                      "model."+modelName+".search_read",
                                                      [
                                                          domainplus,
                                                          0,
                                                          limit,
                                                          order,
                                                          ['id','rec_name'],
                                                          preferences
                                                      ]
                                                      );
            if(result.data!=="error"){
                var dataList=[];
                var resultArray = result.data.result;
                for(var i=0,len=resultArray.length;i<len;i++){
                    dataList.push({"id":resultArray[i].id, "name":resultArray[i].rec_name});
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
            }
        }else{
            boolLastCall = true;
        }
    }

}
