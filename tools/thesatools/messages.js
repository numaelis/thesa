//this file is part of Tessa
//author Numael Garay
var msj;

function showMessage(texto, pariente){
    var mensajeObject=Qt.createComponent("Messages.qml");
    msj = mensajeObject.createObject(pariente);
    msj.mtext = texto;
    msj.open();
}
function showMessageLog(texto, pariente){
    var mensajeObject=Qt.createComponent("MessagesLog.qml");
    msj = mensajeObject.createObject(pariente);
    msj.mtext = texto;
    msj.open();
}

function showQuestion(texto, pariente, action){
    var quest = "import QtQuick 2.5;"+
                    "QuestionAction {"+
                    "mtext: '"+texto+"';"+
                    "onEmitAction: {"+action+";}"+
                    " }"

    var dial = Qt.createQmlObject(quest, pariente, "dynamicSnippet1");
    dial.open();
}

function showQuestionInput(texto, pariente, action){//action(text)
    var quest = "import QtQuick 2.5;"+
                    "QuestionAction {"+
                    "mtext: '"+texto+"';"+
                    "inputText: true;"+
                    "onEmitActionInput: {"+action+";}"+
                    " }"

    var dial = Qt.createQmlObject(quest, pariente, "dynamicSnippet1");
    dial.open();
}

function showQuestionInputPass(texto, pariente, action){//action(text)
    var quest = "import QtQuick 2.5;"+
                    "QuestionAction {"+
                    "mtext: '"+texto+"';"+
                    "inputText: true;"+
                    "onEmitActionInput: {"+action+";}"+
                    " }"

    var dial = Qt.createQmlObject(quest, pariente, "dynamicSnippet1");
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


