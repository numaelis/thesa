//this file is part the thesa: tryton client based PySide2(qml2)
// filters with format
//__author__ = "Numael Garay"
//__copyright__ = "Copyright 2020"
//__license__ = "GPL"
//__version__ = "1.0.0"
//__maintainer__ = "Numael Garay"
//__email__ = "mantrixsoft@gmail.com"

import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import "../thesatools"
//TODO add filter dialog
//
Control{
    id:control
    signal executeFind(var domain)
    signal down()

    function _getData(){
        var text = tffilters.text
        //si texto no tiene : usar rec_name si hay espacios varios rec_name
        var listData=[];
        listData.push(["rec_name","ilike","%"+text+"%"])
        return listData;
    }
    RowLayout{
        anchors.fill: parent
        Button{
            text:qsTr("Filters")
            Layout.fillHeight: true
            height: parent.height
        }
        TextField{
            id:tffilters
            Layout.fillWidth: true
            selectByMouse: !boolMovil
            Keys.onPressed: {
                if (event.key === Qt.Key_Down ) {
                    event.accepted = true;
                    down();
                }
                if (event.key === Qt.Key_Return ) {
                    event.accepted = true;
                    executeFind(_getData());
                }
                if (event.key === Qt.Key_Enter ) {
                    event.accepted = true;
                    executeFind(_getData());
                }
            }
        }
        ButtonAwesone{
            Layout.fillHeight: true
            text: "\uf002"
            ToolTip.visible: false
            onClicked: {
                executeFind(_getData());
            }
        }

    }

}
