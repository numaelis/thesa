//this file is part the thesa: tryton client based PySide2(qml2)
// tools thesa ScanQZXing connect dynamic, need to plugin QZXing
//__author__ = "Numael Garay"
//__copyright__ = "Copyright 2020"
//__license__ = "GPL"
//__version__ = "1.0.0"
//__maintainer__ = "Numael Garay"
//__email__ = "mantrixsoft@gmail.com"


import QtQuick 2.0
import "messages.js" as MessageLib

Item {
    id:tsq
    property QtObject componentQZXing
    property QtObject myQZXing
    property int enabledDecoders: format_EAN_13 | format_CODE_39 | format_QR_CODE
    property int format_AZTEC : 2
    property int format_CODABAR : 4
    property int format_CODE_128 : 32
    property int format_CODE_128_GS1 : 262144
    property int format_CODE_39 : 8
    property int format_CODE_93 : 16
    property int format_DATA_MATRIX : 64
    property int format_EAN_13 : 256
    property int format_EAN_8 : 128
    property int format_ITF : 512
    property int format_MAXICODE : 1024
    property int format_PDF_417 : 2048
    property int format_QR_CODE : 4096
    property int format_RSS_14 : 8192
    property int format_RSS_EXPANDED : 16384
    property int format_UPC_A : 32768
    property int format_UPC_E : 65536
    property int format_UPC_EAN_EXTENSION : 131072
    signal signalTagFound(string tag)

    function createScanQZXing(){
        componentQZXing = Qt.createComponent("ScanQZXing.qml");
        myQZXing = componentQZXing.createObject(container);
        if (myQZXing == null) {
            // Error Handling
            MessageLib.showMessage(qsTr("error loading componet Thesa QZXing: ")+componentQZXing.errorString(), mainroot);
        }else{
            myQZXing.signalTagFound.connect(tsq.signalTagFound);
            myQZXing.signalClose.connect(disconnect);
            myQZXing.setEnableDecoders(enabledDecoders);
            myQZXing.open();
        }
    }
    function disconnect(){
        myQZXing.signalTagFound.disconnect(tsq.signalTagFound);
        myQZXing.signalClose.disconnect(disconnect);
        myQZXing.destroy();
    }
}
