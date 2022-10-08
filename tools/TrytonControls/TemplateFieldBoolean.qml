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
    property string type: "boolean"
    property string labelAlias: ""
    property bool required: false
    property bool readOnly: false
    enabled: !readOnly
    property alias item_field: tfield
    property bool isChange: false
    property var itemParent: -1
    signal change(bool value)

    padding: 0

    function _forceActiveFocus(){
        tfield._forceActiveFocus();
    }

    function getValue(){
        var value = tfield.checked;
        return value;
    }

    function setValue(value){
        if(value==null){
            tfield.checked=false;
        }
        if(value == false || value == true){
            tfield.checked=value;
        }else{
            tfield.checked=false;
        }
        isChange=false;
    }

    function clearValue(){
        tfield.checked=false;
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

    LabelCube{
        id:labelcube
        anchors.fill: parent
        label: labelAlias
        labelcolor:"grey"
        boolBack:false

        CheckBox {
            id:tfield
            //            checked: selectItem
            width: height
            height: 35
            anchors{horizontalCenter: parent.horizontalCenter;bottom: parent.bottom}
            text: ""
            onClicked: {
                //                isChange=true;
            }
            onCheckedChanged: {
                isChange=true;
                change(tfield.checked);
                changeToParent(fieldName,tfield.checked);
                //                if(checked){
                //                    selectItem=true;
                //                }else{
                //                    selectItem=false;
                //                }
            }
        }


    }
}
