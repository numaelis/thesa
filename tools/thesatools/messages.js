//this file is part of Thesa
//author Numael Garay
var msj;

function showMessage(texto, _parent){
    var mensajeObject=Qt.createComponent("Messages.qml");
    msj = mensajeObject.createObject(_parent);
    msj.mtext = texto;
    msj.open();
}
function showMessageLog(texto, _parent){
    var mensajeObject=Qt.createComponent("MessagesLog.qml");
    msj = mensajeObject.createObject(_parent);
    msj.mtext = texto;
    msj.open();
}

function showQuestion(texto, _parent, action){
    var quest = "import QtQuick 2.5;"+
                    "QuestionAction {"+
                    "mtext: '"+texto+"';"+
                    "onEmitAction: {"+action+";}"+
                    " }"

    var dial = Qt.createQmlObject(quest, _parent, "dynamicSnippet1");
    dial.open();
}

function showQuestionAndNotAction(texto, _parent, action, notaction){
    var quest = "import QtQuick 2.15;"+
                    "QuestionAction {"+
                    "mtext: '"+texto+"';"+
                    "isNotAction: true;"+
                    "onEmitAction: {"+action+";}"+
                    "onEmitNotAction: {"+notaction+";}"+
                    " }"

    var dial = Qt.createQmlObject(quest, _parent, "dynamicSnippet1");
    dial.open();
}

function showQuestionInput(texto, _parent, action){//action(text)
    var quest = "import QtQuick 2.5;"+
                    "QuestionAction {"+
                    "mtext: '"+texto+"';"+
                    "inputText: true;"+
                    "onEmitActionInput: {"+action+";}"+
                    " }"

    var dial = Qt.createQmlObject(quest, _parent, "dynamicSnippet1");
    dial.open();
}

function showQuestionInputOptional(texto, _parent, action){//action(text)
    var quest = "import QtQuick 2.5;"+
                    "QuestionAction {"+
                    "mtext: '"+texto+"';"+
                    "inputText: true;"+
                    "inputOptional: true;"+
                    "onEmitActionInput: {"+action+";}"+
                    " }"

    var dial = Qt.createQmlObject(quest, _parent, "dynamicSnippet1");
    dial.open();
}

function showQuestionCheckOption(texto, _parent, data, action, notaction){
    var quest = "import QtQuick 2.15;"+
                    "QuestionAction {"+
                    "mtext: '"+texto+"';"+
                    "isNotAction: true;"+
//                    "inputText: true;"+
                    "isCheckAlways: true;"+
                    "onEmitActionCheck: {"+action+";}"+
                    "onEmitNotAction: {"+notaction+";}"+
                    " }"

    var dial = Qt.createQmlObject(quest, _parent, "dynamicSnippet1");
    dial.dataCheckAlways=data;
    dial.visibleCheckAlways = mainroot.visibleCheckAlways;
    dial.isButtonCancel=false;
    dial.open();
}

function pruebamulti(){


//    const newObject = Qt.createQmlObject(`
//        import QtQuick 2.0

//        Rectangle {
//            color: "red"
//            width: 20
//            height: 20
//        }
//        `,
//        parentItem,
//        "myDynamicSnippet"
//    );

    var trec2 = ""
    var myparent
//    const rec2 = Qt.createComponent(`
//                import QtQuick 2.15
//            Rectangle {
//            width: 400
//            height: 400
//            color: "blue"
//            }`);
//    rec2.createObject(container);
    const rec2 = Qt.createQmlObject(`
                import QtQuick 2.15
            Rectangle {
            width: 400
            height: 400
            color: "blue"
            }`, container, "dynamicSnippet1");

    var trec1 = "import QtQuick 2.15;"+
            "Rectangle {"+
            "width: 200;"+
            "height: 200;"+
            "color: 'white';"+
            " }"
    var rec1 = Qt.createQmlObject(trec1, rec2, "dynamicSnippet1");

}

function showQuestionInputPass(texto, _parent, action, notaction){//action(text)
    var quest = "import QtQuick 2.5;"+
                    "QuestionAction {"+
                    "mtext: '"+texto+"';"+
                    "inputText: true;"+
                    "isNotAction: true;"+
                    "isButtonCancel: false;"+
                    "inputOptional: false;"+
                    "onEmitActionInput: {"+action+";}"+
                    "onEmitNotAction: {"+notaction+";}"+
                    " }"

    var dial = Qt.createQmlObject(quest, _parent, "dynamicSnippet1");
    dial.activePassword();
    dial.open();
}

function showQuestionInputPassConfig(title, label1, label2, textnom, _parent, action, notaction){//action(text)
    var quest = "import QtQuick 2.5;"+
                    "QuestionAction {"+
                    "mtext: '';"+
            "textlabel1: '"+label1+"';"+
            "textlabel2: '"+label2+"';"+
            "textNotMatch: '"+textnom+"';"+
            "verifyPassword: true;"+
                    "inputText: true;"+
                    "isNotAction: true;"+
                    "isButtonCancel: true;"+
            "isButtonNot: false;"+
                    "inputOptional: false;"+
                    "onEmitActionInput: {"+action+";}"+
                    "onEmitNotAction: {"+notaction+";}"+
                    " }"

    var dial = Qt.createQmlObject(quest, _parent, "dynamicSnippet1");
    dial.activePassword();
    dial.mtitle=title;
    dial.open();
}

function showToolTip(text, pixelSize, timeout, colortext, colorback, parent){
    var tooltipcom=Qt.createComponent("ToolTipDynamic.qml");
    var tooltip = tooltipcom.createObject(parent);
    tooltip.colortext = colortext;
    tooltip.colorback = colorback;
    tooltip.font.pixelSize = pixelSize;
    tooltip.show(text, timeout);
}


