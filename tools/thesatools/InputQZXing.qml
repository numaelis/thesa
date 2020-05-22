//this file is part the thesa: tryton client based PySide2(qml2)
// tools input thesa ScanQZXing connect dynamic, need to plugin QZXing
//__author__ = "Numael Garay"
//__copyright__ = "Copyright 2020"
//__license__ = "GPL"
//__version__ = "1.0.0"
//__maintainer__ = "Numael Garay"
//__email__ = "mantrixsoft@gmail.com"

import QtQuick 2.7

Item {
    id:iQZX
    implicitWidth: 50
    implicitHeight: 50
    property string icon: "\uf05b"
    //property string textToolTip: qsTr("Scan Code")
    property int enabledDecoders: format_EAN_13 | format_CODE_39 | format_QR_CODE
    signal signalTagFound(string tag)

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
    //2 4 32 262144 8 16 64 256 128 512 1024 2048 4096 8192 16384 32768 65536 131072

    ButtonAwesone{
        anchors.fill: parent
        text: iQZX.icon
        textToolTip:qsTr("Scan Code")
        onClicked: {
            mytsQZXing.createScanQZXing();
        }

    }

    ThesaScanQZXing{
        id:mytsQZXing
        enabledDecoders:iQZX.enabledDecoders
        onSignalTagFound: {
            iQZX.signalTagFound(tag)
        }
    }

}
