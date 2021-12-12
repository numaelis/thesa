//this file is part the thesa: tryton client based PySide2(qml2)
// template field text (fields.Char())
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
    property bool password: false
    property int decimal: 0
    property bool readOnly: false
    enabled: !readOnly
    property alias item_field: tfield

    property bool isChange: false

    signal change(string text)
    signal accepted(string text)
//    property bool isParentO2M: false
    property var itemParent: -1

    padding: 0
    function _forceActiveFocus(){
        tfield.forceActiveFocus();
    }

    function selectAll(){
        tfield.selectAll();
    }

    function getValue(){
        if(type=="numeric"){
            if(tfield.text==""){
                return null;
            }
            return decimalSchema(tfield.text);
        }
        if(type=="float"){
            if(tfield.text==""){
                return null;
            }
            return parseFloat(tfield.text);
        }
        if(type=="integer"){
            if(tfield.text==""){
                return null;
            }
            return parseInt(tfield.text);
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
        if(type=="numeric"){
            tfield.focus=false;
        }

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
        if(type == "numeric" || type == "float"){
            if(decimal>=1 && decimal <=2){
                setValidator('import QtQuick 2.5;RegExpValidator { regExp:/^(0|[1-9][0-9]*|0\\.([1-9][0-9]|[0-9][0-9]|[0-9])|[1-9][0-9]*\\.([0-9][0-9]|[0-9]))$/ }');
            }else{
                if(decimal>=3){
                    setValidator('import QtQuick 2.5;RegExpValidator { regExp:/^(0|[1-9][0-9]*|0\\.([1-9][0-9]|[0-9][0-9]|[0-9]|[0-9][0-9][0-9]|[0-9][0-9][0-9][0-9])|[1-9][0-9]*\\.([0-9][0-9]|[0-9]|[0-9][0-9][0-9]|[0-9][0-9][0-9][0-9]))$/ }');
                }else{
                    setValidator('import QtQuick 2.9;RegExpValidator { regExp:/^(0|[1-9][0-9]*)$/}');
                }
            }
        }
        if(type == "integer"){
            decimal = 0;
            setValidator('import QtQuick 2.9;RegExpValidator { regExp:/^(0|[1-9][0-9]*)$/}');
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
        var mdecimal = decimal_point;
        var negative = number < 0 ? "-" : "",
        i = parseInt(number = Math.abs(+number || 0).toFixed(places), 10) + "",
        j = (j = i.length) > 3 ? j % 3 : 0;
        return symbol + negative + (j ? i.substr(0, j) + thousand : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + thousand) + (places ? mdecimal + Math.abs(number - i).toFixed(places).slice(2) : "");
    }

    function changeToParent(name, value){
        if(itemParent!=-1){
            if(itemParent.type=="one2many"){
                var _value=value;
                if(type=="numeric"){
                    _value = value != ""?decimalSchema(value):null;
                }
                if(type=="float"){
                    _value = value != ""?parseFloat(value):null;
                }
                if(type=="integer"){
                   _value = value != ""?parseInt(value):null;
                }

               itemParent.changeField(name, _value);
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
                horizontalAlignment: control.type== "text"?TextField.AlignLeft:TextField.AlignRight

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
                    if(type=="numeric"){
                        tfield.focus=false;
                    }
                    control.accepted(text);
                }
            }
        }
    }
}
