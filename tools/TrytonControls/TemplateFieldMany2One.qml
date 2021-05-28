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
    property string labelAlias: ""
    property string fieldName: ""
    property string type: "many2one"
    property bool required: false
    property bool readOnly: false
    enabled: !readOnly
    property string modelName: ""
    property var domain:[]
    property var order:[]
    property int limit: 200
    property bool boolLastCall: false
    property alias buttonSelection: fm2o.buttonSearchMinus
    property bool isChange: false
    signal change(int id, string name)

    padding: 0

    function _forceActiveFocus(){
        fm2o.forceActiveFocus();
    }

    function getValue(){
       return fm2o.getValue();
    }

    function setValue(value){
        fm2o.setValue(value);
        isChange=false;
    }

    function clearValue(){
        fm2o.clearValue();
        isChange=false;
    }

    Component.onCompleted: {
        control.objectName="tryton_"+fieldName+"_"+_getNewNumber();
        fm2o.fieldName = fieldName;
        fm2o.modelName = modelName;
        fm2o.order = order;
        fm2o.domain = domain;
        fm2o.limit = limit;
    }

    LabelCube{
        id:labelcube
        anchors.fill: parent
        label: labelAlias
        labelcolor:"grey"
        boolBack:false
        FieldMany2One{
            id:fm2o
            onValueChanged: {
                isChange=true;
                change(id, name);
            }

        }
    }
}
