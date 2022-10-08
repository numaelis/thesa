//this file is part of Thesa
//author Numael Garay
//var conn;

function jsonRpcAction(_parent, params, context, sresult, scancel, serror){
    var _conn = "import QtQuick 2.15;"+
                    "Conections {"+
//                    "_params: "+params+";"+
//                    "_mcontext: "+context+";"+
                    "autoDestroy: true;"+
                    "useBusy: true;"+
                    "onSignalResult: {"+sresult+";}"+
                    "onSignalError: {"+serror+";}"+
                    "onSignalCancel: {"+scancel+";}"+
                    " }"

    var conn = Qt.createQmlObject(_conn, _parent, "dynamicSnippet1");
    conn._params = params;
    conn._mcontext= context;
    conn.recursiveConect();
}
