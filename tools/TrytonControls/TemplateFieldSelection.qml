//this file is part the thesa: tryton client based PySide2(qml2)
// template field selection
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

Control{
    id:control
    property bool tryton: true
    property string fieldName: ""
    property string type: "selection"
    property string labelAlias: ""
    property bool required: false
    property bool readOnly: false
    enabled: !readOnly
    property alias item_field: tfield
    property var model: []//TODO append "", ""
    property bool isChange: false
    property var itemParent: -1
    signal change(string text)

    padding: 0

    function _forceActiveFocus(){
        tfield.forceActiveFocus();
    }

    function getValue(){
        if(tfield.currentIndex==-1){
            return "";
        }
        return tfield.currentValue;
    }

    property bool boolTimer: false

    function getIndexOf(value){
        var isNumber = typeof value === 'number'?true:false
        for(var i=0,len=model.length;i<len;i++){
            if(isNumber){
                if(value == parseInt(model[i].name)){
                    return i;
                }
            }else{
                if(value == model[i].name){
                    return i;
                }
            }
        }
        model.push({"name":value, "alias":value})
        return model.length-1;
    }

    function setValue(value){
        if(value==null){
            value = "";
        }
        var index = getIndexOf(value);
        boolTimer = true;
        tfield.currentIndex=index;
        isChange=false;
        tbooltimer.start();
    }

    function clearValue(){
        boolTimer = true;
        //tfield.currentIndex=-1//
        tfield.currentIndex=model.length>0?0:-1;
        isChange=false;
        tbooltimer.start();
    }

    function changeOff(){
        isChange=false;
    }

    Timer{
        id:tbooltimer
        interval: 200
        onTriggered: {
            boolTimer = false;
        }
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

    LabelCube{
        id:labelcube
        anchors.fill: parent
        label: labelAlias
        labelcolor:"grey"
        boolBack:false
        ComboBox{
            id:tfield
            font.pixelSize:18
            textRole: "alias"
            valueRole: "name"
            model: control.model
            onCurrentValueChanged: {
                if(boolTimer==false){
                    isChange=true;
                    change(currentValue);
                    changeToParent(fieldName,currentValue);
                }
            }
        }
    }
}
