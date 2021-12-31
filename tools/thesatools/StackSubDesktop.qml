//this file is part the thesa: tryton client based PySide2(qml2)
//__author__ = "Numael Garay"
import QtQuick 2.9
//import QtQuick.Controls 2.2
//import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3

StackLayout {
    id:mystack
    property int indexSaved: -1
    property bool boolSaveIndex: false;
    property var tabs: []
    function initTab(){
        barroot.deleteTabs();
        barroot.addTabs(tabs, mystack);
        if(boolSaveIndex){
            barroot.currentIndex=indexSaved;
            mystack.currentIndex=indexSaved;
            boolSaveIndex=false;
        }
        clickTab();
    }
    function saveIndex(){
        if(boolSaveIndex==false){
            indexSaved=currentIndex;
            boolSaveIndex=true;
        }
    }
    function clickTab(){
        if (currentIndex!=-1){
            children[currentIndex].selectMyTab();
            postTitle = " "+children[currentIndex].getPostTitle();
        }
    }
}
