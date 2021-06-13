//this file is part the thesa: tryton client based PySide2(qml2)
// template field text
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
    property string type: "text"//numeric
    property string labelAlias: ""
    property bool required: false
    property bool password: false
    property var decimal: 0
    property bool readOnly: false
    enabled: !readOnly
    property alias item_field: tfield

    property bool isChange: false

    signal change(string text)

//    property bool isParentO2M: false
    property var itemParent: -1

    padding: 0
    function _forceActiveFocus(){
        tfield.forceActiveFocus();
    }

    function getValue(){
        if(type=="numeric"){
            return decimalSchema(tfield.text);
        }
        return tfield.text;
    }

    function setValue(value){
        if(value==null){
            value = "";
        }

        if(type=="numeric"){
            tfield.text = decimalFromSchema(value);
        }else{
            tfield.text=value;
        }
        isChange=false;
    }

    function clearValue(){
        tfield.clear();
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
        if(type == "numeric"){
            if(decimal>=1 && decimal <=2){//TODO 2 decimals or 4 decimals
                setValidator('import QtQuick 2.5;RegExpValidator { regExp:/^(0|[1-9][0-9]*|0\\.([1-9][0-9]|[0-9][0-9]|[0-9])|[1-9][0-9]*\\.([0-9][0-9]|[0-9]))$/ }');
            }if(decimal>3){
                setValidator('import QtQuick 2.5;RegExpValidator { regExp:/^(0|[1-9][0-9]*|0\\.([1-9][0-9]|[0-9][0-9]|[0-9]|[0-9][0-9][0-9]|[0-9][0-9][0-9][0-9])|[1-9][0-9]*\\.([0-9][0-9]|[0-9]|[0-9][0-9][0-9]|[0-9][0-9][0-9][0-9]))$/ }');
            }else{
                setValidator('import QtQuick 2.9;RegExpValidator { regExp:/^(0|[1-9][0-9]*)$/}');
            }
        }
        if(type == "text"){
            if(password){
                tfield.echoMode = TextInput.Password;
            }
        }
    }

    function formatDecimalPlaces(value, mplaces){
        if(value == ""){
            return "";
        }
        var number = parseFloat(value);
        if (isNaN(number)){
            number = 0;
        }
        var places = mplaces;
        var symbol = ""; //$
        var thousand =  thousands_sep;
        var decimal = decimal_point;
        var negative = number < 0 ? "-" : "",
        i = parseInt(number = Math.abs(+number || 0).toFixed(places), 10) + "",
        j = (j = i.length) > 3 ? j % 3 : 0;
        return symbol + negative + (j ? i.substr(0, j) + thousand : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + thousand) + (places ? decimal + Math.abs(number - i).toFixed(places).slice(2) : "");
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
        Item{
            TextField{
                anchors.fill: parent
                readOnly: true
                visible: format_text.visible
                onFocusChanged: {
                    if(focus==true){
                        tfield.forceActiveFocus();
                    }
                }
            }
            Label{
                id:format_text
                anchors.fill: parent
                visible: type=="numeric" && tfield.focus==false?true:false
                horizontalAlignment: Label.AlignRight
                fontSizeMode: Label.Fit
                minimumPixelSize: 9
                elide: Label.ElideRight
                font.pixelSize: tfield.font.pixelSize
                text:formatDecimalPlaces(tfield.text, decimal)
                padding: 0
                verticalAlignment: Label.AlignVCenter
                bottomPadding: tfield.bottomPadding-4
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        tfield.forceActiveFocus();
                    }
                }
                z:12
            }

            TextField{
                id:tfield
                anchors.fill: parent
                visible: !format_text.visible
                topPadding: 0

                onTextEdited: {
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

                onAccepted: {

                }
            }
        }
    }
}
