//this file is part the thesa: tryton client,  PySide2(qml2) based
//"""MenuList.qml
//__author__ = "Numael Garay"
//__copyright__ = "Copyright 2020"
//__license__ = "GPL"
//__version__ = "1.0"
//__maintainer__ = "Numael Garay"
//__email__ = "mantrixsoft@gmail.com"

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3

FocusScope {
    id: menul
    signal signalSelectPanel(int index)

    property alias aliasmodel: listView.model
    property alias aliasCurrentIndex: listView.currentIndex
    function setModel(data){
        aliasmodel.clear();
        var i = 0;
        var len=data.length;
        for(i=0;i<len;i++){
            aliasmodel.append(data[i]);
        }
    }

    Rectangle{
        anchors.fill: parent
        opacity: boolBack?0.8:1
        color:boolBack?mainroot.Material.background:Qt.lighter(mainroot.Material.background)//Qt.lighter("steelblue")
    }

    ColumnLayout {
        spacing: 0
        anchors.fill: parent

        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            keyNavigationWraps: true
            clip: true
            focus: true
            ScrollBar.vertical: ScrollBar { }

            delegate: ItemDelegate {
                id:idele
                width: parent.width
                height: 60
                text: model.name
                font.bold: true
                font.pixelSize: 12
                contentItem: Item{
                    anchors.fill: parent

                    Label {
                        id:images
                        width: 30
                        height: 30
                        text: micon
                        font.family: fawesome.name
                        font.pixelSize: 30
                        font.italic: false
                        font.bold: true
                        color: idele.Material.accent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        anchors{horizontalCenter: parent.horizontalCenter;top:parent.top;topMargin: 8}
                        //wrapMode: Text.Wrap
                    }
                    Label {
                        id:texto
                        width: idele.width
                        height: 20
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 8
                        text: idele.text
                        font: idele.font
                        color: idele.enabled ? idele.Material.primaryTextColor
                                             : idele.Material.hintTextColor
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        anchors{horizontalCenter: parent.horizontalCenter;bottom: parent.bottom;bottomMargin: 2}
                        //wrapMode: Text.Wrap
                    }
                }

                property string micon: model.icon
                highlighted: ListView.isCurrentItem

                onClicked: {
                    if(boolDrawer){
                        menudrawer.close();
                    }
                    listView.forceActiveFocus()
                    listView.currentIndex = model.index

                }
            }

            onCurrentItemChanged: {
                menul.signalSelectPanel(currentIndex) //currentItem.url
                if(currentIndex!=-1){
                    lTitleBarra.objtitle={
                        "name":model.get(currentIndex).name,
                        "icon":model.get(currentIndex).icon
                    };
                }
                if(boolDrawer){
                    if(menudrawer.opened){
                        menudrawer.close();
                    }
                }
            }
        }
    }
}

