//this file is part the thesa: tryton client based PySide2(qml2)
// tools FilterTagList
//__author__ = "Numael Garay"
//__copyright__ = "Copyright 2021"
//__license__ = "GPL"
//__version__ = "1.0.0"
//__maintainer__ = "Numael Garay"
//__email__ = "mantrixsoft@gmail.com"
import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3

Control{
    id:control
    implicitHeight: 60
    implicitWidth: 100
    signal changeValues(var values)

    function addTag(obj){//{"name":"","value1..":""}
        listmodel.append(obj);
        tchange.start();
    }

    function clear(){
        listmodel.clear();
    }

    function getValues(){
        var listobj = [];
        for (var i=0, len=listmodel.count;i<len;i++){
            listobj.push({"value":JSON.parse(listmodel.get(i).value)});
//            listobj.push({"value":[listmodel.get(i).value1,listmodel.get(i).value2,listmodel.get(i).value3]});
        }
        return listobj;
    }

    function remove(index){
        listmodel.remove(index);
        tchange.start();
    }
    Timer{
        id:tchange
        interval: 200
        onTriggered: {
            changeValues(getValues());
        }
    }

    ListModel{
        id:listmodel
    }
    padding: 2
    ListView{
        id:listview
        anchors.fill: parent
        clip: true
        model: listmodel
        delegate: fdelegate
        orientation: Qt.Horizontal
        ScrollBar.horizontal: ScrollBar {policy: listview.contentWidth>width?ScrollBar.AlwaysOn:ScrollBar.AlwaysOff}
    }
    Component{
        id:fdelegate
        ItemDelegate{
            leftPadding: 8
            rightPadding: 8
            topPadding: 0
            bottomPadding: 0
            height: listview.height
            contentItem: RowLayout{
                Label{
                    id:mlabel
                    text: name
                    padding: 0
                    font.pixelSize: 20
                    //height: listview.height
                    Layout.fillWidth: true
                    Layout.preferredHeight: listview.height
                    verticalAlignment: Qt.AlignVCenter
                    color: mainroot.Material.accent
                }
                FlatAwesome {
                    id: fban
                    Layout.preferredHeight: 22
                    Layout.preferredWidth: 22
                    Layout.alignment: Qt.AlignVCenter
                    //anchors{right: parent.right; verticalCenter: parent.verticalCenter}
                    text:"\uf00d"
                    onClicked: {
                        remove(index);
                    }
                }
            }
        }
    }

}
