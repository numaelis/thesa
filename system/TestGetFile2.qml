//this file is part the thesa: tryton client based PySide2(qml2)
// test example files
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
    id:testgetfile2

    ColumnLayout{
        anchors.centerIn: parent
        Layout.fillWidth: true

        InputLabelCube{
            id: inputFile
            label: "file: "
            readOnly: true
            boolOnDesk: true
            Layout.fillWidth: true
        }

        ButtonAwesome{
            text: "\uf052"
            textToolTip: "select file"
            onClicked: {
                var result = Tools.getFilePath("Select File","All (*.*)");
//                var result = Tools.getFilePath("Select File","Image (*.png *.xpm *.jpg *.gif *.jpeg *.bmp *ppm)");
                if(result.error===false){
                    //console.log(result.fullname, result.name);
                    inputFile.text=result.fullname;
                    var t64 = Tools.getFileBase64(result.fullname);
                    labelBase64.text = t64.substring(0,16) + "  ...";
                }

//                var result = Tools.getImagePath("Select File");
//                if(result.error==false){
//                inputFile.text=result.fullname;
//                var t64 = Tools.getFileBase64(result.fullname);
//                labelBase64.text = t64.substring(0,16) + "  ...";
//                }
            }
        }
        InputLabelCube{
            id: labelBase64
            label: "base64: "
            readOnly: true
            boolOnDesk: true
            Layout.fillWidth: true
        }
    }

}
