//this file is part the thesa: tryton client based PySide2(qml2)
//__author__ = "Numael Garay"
import QtQuick 2.9
//import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
//import QtQuick.Layouts 1.3

FocusScope {
    id:tabdes
    signal firstTimeTab();
    signal selectTab();
    property string type: "tab"
    property int countTimeTab: -1
    property string postTitle: ""
    property bool isPreClosing: false
    // if isPreClosing is true: a function must be defined with the name preClosing
    //      example
    //      function preClosing(){
    //         .....
    //         .....
    //         .....
    //      }


    //property string name: value
    function selectMyTab(){
        countTimeTab+=1;
    }
    function getPostTitle(){
        return postTitle;
    }




    onCountTimeTabChanged: {
        if(countTimeTab==0){
            temitsignal.start();
        }
        selectTab();
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
