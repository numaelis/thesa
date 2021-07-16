//this file is part the thesa: tryton client based PySide2(qml2)
// template field text area ( fields.Text())
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
    property string type: "text"
    property string labelAlias: ""
    property bool required: false
    property bool readOnly: false
    property bool richText: false
    enabled: !readOnly
    property alias item_field: tfield

    property bool isChange: false

    signal change(string text)
    implicitHeight: 100

    //    property bool isParentO2M: false
    property var itemParent: -1

    padding: 0
    function _forceActiveFocus(){
        tfield.forceActiveFocus();
    }

    function getValue(){
        return tfield.text;
    }

    function setValue(value){
        if(value==null){
            value = "";
        }
        tfield.text=value;
        isChange=false;
    }

    function clearValue(){
        tfield.clear();
        isChange=false;
    }

    function changeOff(){
        isChange=false;
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
        ScrollView {
            clip: true
            focus: true
            ScrollBar.vertical.policy: tfield.contentHeight > height?ScrollBar.AlwaysOn:ScrollBar.AlwaysOff
            TextArea{
                id:tfield
                clip: true
                wrapMode: TextArea.WordWrap
                textFormat: richText?TextArea.PlainText:TextArea.RichText
                selectByMouse: true//!boolMovil
                onTextChanged: {
                    isChange=true;
                }
                onCursorVisibleChanged: {
                    if(isCursorVisible==false){
                        if(isChange==true){
                            change(text);
                            changeToParent(fieldName,text);
                        }
                    }
                }

            }
        }
    }
}
