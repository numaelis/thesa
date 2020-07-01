//this file is part the thesa: tryton client based PySide2(qml2)
// test example files images with picker signals
//__author__ = "Numael Garay"
//__copyright__ = "Copyright 2020"
//__license__ = "GPL"
//__version__ = "1.0.0"
//__maintainer__ = "Numael Garay"
//__email__ = "mantrixsoft@gmail.com"

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import thesatools 1.0

TabDesktop {
    id:testQZXing

    ColumnLayout{
        anchors.centerIn: parent
        Layout.fillWidth: true
        Label{
            text:"Scan code bar with QZXing..."
            Layout.alignment: Label.AlignHCenter
        }

        InputLabelCube{
            id: labelcode
            label: "codebar: "
            readOnly: true
            boolOnDesk: true
            Layout.fillWidth: true
        }

        InputQZXing{
            enabledDecoders: format_EAN_13 | format_EAN_8 | format_CODE_39 | format_QR_CODE | format_CODE_128 | format_CODE_128_GS1
            onSignalTagFound:{
                labelcode.text=tag;
            }
        }
    }

}
