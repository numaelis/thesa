//this file is part the thesa: tryton client based PySide2(qml2)
// test example tryton controls fields
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
import TrytonControls 1.0

TabDesktop {
    id:testfields

    onFirstTimeTab:{
    }

    Column{
        anchors.fill: parent
        //Layout.fillWidth: true
        Label{
            Layout.alignment: Qt.AlignHCenter
            text:"in construction..."
        }

        RowLayout{
            //Layout.fillWidth: true
           // Layout.alignment: Qt.AlignHCenter
            spacing: 6

            Label{
                text:"Party:"
                font.pixelSize:20
                height: myparty.height
                verticalAlignment: Qt.AlignVCenter
            }

            FieldMany2One{
                id:myparty
                enabled: true
                width: 400
                modelName: "party.party"
                domain: []
                order: []
                limit: 500
                maxItemListHeight:15
                //textFit:false
                font.pixelSize:20
                onClear:{
                    console.log("clear value");
                }
                onValueChanged:{
                    console.log("id:", id, "  rec_name:", name);

                    if(id==-1){
                        console.log("clear value");
                    }

                }

            }

        }


    }

}
