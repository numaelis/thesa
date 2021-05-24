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


