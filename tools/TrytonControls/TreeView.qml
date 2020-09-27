//this file is part the thesa: tryton client based PySide2(qml2)
// view tree
//__author__ = "Numael Garay"
//__copyright__ = "Copyright 2020"
//__license__ = "GPL"
//__version__ = "1.0.0"
//__maintainer__ = "Numael Garay"
//__email__ = "mantrixsoft@gmail.com"

import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import "../thesatools"
//TODO
//
//
Control{
    id:control
    //    implicitWidth: 100
    //    implicitHeight: 100
    property bool activeFilters: true
    property bool activeStates: false
    property bool activeAutoFields: false
    property bool editable: false//... for the moment not supported
    property alias delegate: listview.delegate
    property int maximumLineCount: 1
    property real heightHeader: 30
    property real heightField: 30
    property real heightFilter: 40
    property bool verticalLine: true
    property bool horizontalLine: true
    property bool multiSelectItems: true
    property var listHead: []
    //    property bool useTableView: true
    property string modelName: ""
    property var fields: []
    property var fieldsFormatDecimal: []
    property var fieldsFormatDateTime: []
    property int limit: 1000
    property var order: []
    property var domain: []
    property var _models//: [null,null]
    property var _manager: null
    property string viewName: ""//name tryton model="ir.ui.view", type tree

    Component.onCompleted: {
        _initModel();
    }

    function loadFieldsFromModel(){

    }
    function find(data){
        var domainplus = [];
        //domainplus.push(domain);
        //domainplus.push(data);
        //_models.model.find(domainplus);
    }

    function _initModel(){
        _models = ModelManagerQml.addModel("_model"+_getNewNumber(), "_proxymodel"+_getNewNumber);
        //console.log(_models.model, _models.proxy);
        if(_models.hasOwnProperty("model")){
            _models.model.setLanguage(planguage);
            _models.model.setModelMethod("model."+modelName);
            _models.model.setDomain(domain);
            _models.model.setMaxLimit(limit);
            _models.model.setOrder(order)
            _models.model.setFields(fields);
            _models.model.setPreferences(preferences);
        }
    }

    function getIds(){
        var ids=[];
        
        return ids;
    }

    
    Item {
        id: ifilter
        width: parent.width
        height: activeFilters?heightFilter:0
        z:12
        FiltersInput{
            anchors.fill: parent
            onExecuteFind:{
                find(domain)
            }
            onDown:{
                listview.forceActiveFocus();
            }
        }
    }
    ListView{
        id:listview
        anchors{fill: parent;topMargin: ifilter.height+2}
        clip: true
        focus: true
        model:_models.proxy
        cacheBuffer: contentHeight+heightField
       
        
    }

    
}
