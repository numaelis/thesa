//this file is part the thesa: tryton client based PySide2(qml2)
// template field document
//__author__ = "Numael Garay"
//__copyright__ = "Copyright 2020-2021"
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
    property string type: "text"//numeric
    property string labelAlias: ""
    property bool required: false
    property alias typeDocument: tfield.typeDocument// "DNI"//DNI CUIT TEL
    property bool readOnly: false
    enabled: !readOnly
    property var itemParent: -1
    property alias item_field: tfield

    property bool isChange: false

    signal change(string text)

    padding: 0

    function _forceActiveFocus(){
        tfield.forceF();
    }

    function getValue(){
        return tfield.getValue();
    }

    function setValue(text){
        if(text==null){
            text = "";
        }
        tfield.setValue(text);
        isChange=false;
    }

    function clearValue(){
        tfield.clearValue();
        isChange=false;
    }

    function changeOff(){
        isChange=false;
    }

    function setValidator(str_qml_regexp){
        tfield.validator= Qt.createQmlObject(str_qml_regexp, tfield, "dynamicSnippet1");
    }

    Component.onCompleted: {
        control.objectName="tryton_"+fieldName+"_"+_getNewNumber();
    }

    function changeToParent(name, value){
        if(itemParent!=-1){
            if(itemParent.type=="one2many"){
               itemParent.changeField(name, value);
            }
        }
    }

    LabelCube{
        id:labelcube
        anchors.fill: parent
        label: labelAlias
        labelcolor:"grey"
        boolBack:false
        FieldDocument{
            id:tfield
            onFieldTextEdited: {
               // if(focus==true){
                    isChange=true;
//                }
            }

            onFieldCursorVisible:{
                if(isCursor==false){
                    if(isChange==true){
                        change(value);
                        changeToParent(fieldName,value);
                    }
                }
            }

            onFieldAccepted: {
//                if(isChange==true){
//                    change(getValue());
//                }
            }
        }
    }
}
