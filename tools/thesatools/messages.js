//this file is part of Tessa
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

function showQuestionInputPass(texto, _parent, action){//action(text)
    var quest = "import QtQuick 2.5;"+
                    "QuestionAction {"+
                    "mtext: '"+texto+"';"+
                    "inputText: true;"+
                    "onEmitActionInput: {"+action+";}"+
                    " }"

    var dial = Qt.createQmlObject(quest, _parent, "dynamicSnippet1");
    dial.activePassword();
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


