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
    id:testgetfile

    Component.onDestruction: {
        Tools.signalResponsePickerImage.disconnect(slotPicker);
    }

    Component.onCompleted: {
        Tools.signalResponsePickerImage.connect(slotPicker);
    }

    function slotPicker(pid, option, path){
        if(pid=="pid1"){
            openBusy();
            inputFile.text=path;
            var newImagePath = Tools.scaleImage(100,path);//reduce to 100 pixels
            var t64=Tools.getFileBase64(newImagePath)
            labelBase64.text = t64.substring(0,16) + "  ...";
            closeBusy();
        }
    }


    ColumnLayout{
        anchors.centerIn: parent
        Layout.fillWidth: true
        Label{
            text:"picker"
            Layout.alignment: Label.AlignHCenter
        }

        InputLabelCube{
            id: inputFile
            label: "file: "
            readOnly: true
            boolOnDesk: true
            Layout.fillWidth: true
        }

        ButtonAwesone{
            text: "\uf052"
            textToolTip: "select file image"
            onClicked: {
                Tools.openImagePicker("pid1", qsTr("Select Image"));
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
