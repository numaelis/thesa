//this file is part the thesa: tryton client based PySide2(qml2)
//__author__ = "Numael Garay"
import QtQuick 2.9
//import QtQuick.Controls 2.2
//import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3

StackLayout {
    id:stdesktop
    Layout.preferredWidth: parent.width - menulist.width
    Layout.fillWidth: true
    Layout.fillHeight: true
    KeyNavigation.tab: menulist
    onCurrentIndexChanged: {
        if(currentIndex!=-1){
            children[currentIndex].initTab();
        }
    }

}
