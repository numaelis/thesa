//this file is part the thesa: tryton client based PySide2(qml2)
// test example tryton controls
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
    id:testViewTree

    onFirstTimeTab:{
        
    }
            Label{
                text:" in Construction..."

                font.pixelSize:23
            }
            TreeView{
                id:mytv
                anchors{fill: parent;topMargin:30}
                

            }

}
