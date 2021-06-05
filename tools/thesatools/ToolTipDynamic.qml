//this file is part of Tessa
//author Numael Garay
import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2

ToolTip{
    id:tooltip
    property string colortext: mainroot.Material.foreground
    property string colorback: mainroot.Material.background
    delay: 300
    timeout: 3000
    font.bold: true
    font.pixelSize: 14
    Material.elevation: 6
    Material.foreground: colortext
    Material.background: colorback
    onClosed: {
        tcloseAll.start();
    }

    Timer{
        id:tcloseAll
        interval: 800
        onTriggered: {destroy(0);}
    }

}
