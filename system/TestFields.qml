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

    ColumnLayout{
        anchors{fill:parent; margins:20}
        //Layout.fillWidth: true
        Label{
            Layout.alignment: Qt.AlignHCenter
            text:"in construction..."
            Layout.preferredHeight: 40
        }

        Pane{
            Layout.fillWidth: true
            Layout.preferredHeight: 140
            RowLayout{
                anchors.fill: parent
                spacing: 6

                Label{
                    text:"Party:"
                    font.pixelSize:20
                    Layout.preferredHeight:fparty.height
                    verticalAlignment: Qt.AlignTop
                    padding: 0
                    Layout.preferredWidth:paintedWidth
                }

                FieldMany2One{
                    id:fparty
                    enabled: true
                    modelName: "party.party"
                    domain: []
                    order: []
                    limit: 500
                    maxItemListHeight:15
                    //textFit:false
                    font.pixelSize:20
                    Layout.fillWidth: true
                    onValueChanged:{
                        console.log("id:", id, "  rec_name:", name);
                        if(boolValueAssigned){
                            fdirection.domain = [['party', '=', id]];
                            fdirection.forceActiveFocus();
                        }else{
                            fdirection.domain = [];
                            fdirection.setValue({"id":-1,"name":""});
                        }
                    }

                }
                Item {
                    id: separa
                    Layout.preferredWidth:30
                }

                Label{
                    text:"Direction:"
                    font.pixelSize:20
                    Layout.preferredHeight:fparty.height
                    verticalAlignment: Qt.AlignTop
                    padding: 0
                    Layout.preferredWidth:paintedWidth
                }

                FieldMany2One{
                    id:fdirection
                    Layout.preferredWidth:300
                    enabled: fparty.boolValueAssigned
                    modelName: "party.address"
                    font.pixelSize:20
                    buttonSelection:true

                }

            }
            Material.elevation: 6

        }

        Pane{
            Layout.fillWidth: true
            Layout.fillHeight: true
        }



    }

}
