//this file is part the thesa: tryton client based PySide2(qml2)
//__author__ = "Numael Garay"
import QtQuick 2.9
//import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
//import QtQuick.Layouts 1.3

FocusScope {
    id:tabdes
    signal firstTimeTab();
    property int countTimeTab: -1
    function selectMyTab(){
        countTimeTab+=1;
    }
    onCountTimeTabChanged: {
        if(countTimeTab==0){
            temitsignal.start();
        }
    }
    Rectangle{
        anchors.fill: parent
        opacity: boolBack?0.9:1
        color:mainroot.Material.background
    }
    Timer{
        id:temitsignal
        interval: 400
        onTriggered: firstTimeTab();
    }
}
