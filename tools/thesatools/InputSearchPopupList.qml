//this file is part the thesa: tryton client based PySide2(qml2)
// tools InputSearchPopupList
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

Control{
    id:control
    width: 120
    height: 40
    implicitHeight: 40
    property int maxItemListHeight: 5
    property bool boolValueAssigned: false
    property int maximumLineCount: 1
    property int countSearch: 0
    property bool textFit: true
//    property var value//:({})
    property int valueId: -1
    property string valueName
    property bool boolSearch: true
    property alias textSearch: tfsearch.text
    signal textChanged(string text)//search
    signal valueChanged(int id, string name);
    signal clear()

    function updateModel(dataList){
        pmodel.clear();
        for(var i=0,len=dataList.length;i<len;i++){
            pmodel.append({"id":dataList[i].id,"name":dataList[i].name})
        }
        if(len <= maxItemListHeight){
            popup.height = (len * control.height)+2
        }else{
            popup.height = maxItemListHeight * control.height
        }
    }

    function selectItem(data){
        setValue(data);
    }

    function initValue(values){// format -> {"id":-1,"name":""}
        valueId=values.id;
        valueName=values.name;
        //no emit signal
    }

    function setValue(values){// format -> {"id":-1,"name":""}
        valueId=values.id;
        valueName=values.name;
        boolValueAssigned=true;
        lname.text = values.name;
        popup.close();
        boolSearch=false;
        tfsearch.text="";
        ttruesearch.start();
        valueChanged(values.id, values.name);//emit signal onValueChanged(id,name)
    }
    Timer{
        id:ttruesearch
        interval: 200
        onTriggered: {boolSearch=true}
    }
    Timer{
        id:tdelaysearch
        interval: 300
        onTriggered: {
            if(tfsearch.text==""){
                popup.close();
            }else{
                popup.open();
                countSearch = countSearch>100?0:countSearch+1;
                control.textChanged(tfsearch.text);
            }
        }
    }

    ListModel{
        id:pmodel
    }

    Item {
        id: tas
        width: control.width
        height: control.height//-10
        visible: boolValueAssigned
        Label{
            id:lname
            anchors{fill:parent;rightMargin: iconq.width+4}
            maximumLineCount: control.maximumLineCount
            elide: Label.ElideRight
            fontSizeMode: textFit?Text.Fit:Text.FixedSize
            minimumPixelSize: 10
            verticalAlignment: Text.AlignVCenter
        }
        Label{
            id:iconq
            height: parent.height
            width: height
            anchors{right: parent.right}
            text:"\uf00d"
            font.family:fawesome.name
            font.bold: false
            font.italic: false
            font.pixelSize:16// height-2
            verticalAlignment: Text.AlignVCenter
            color: marea.pressed?mainroot.Material.accent:mainroot.Material.foreground
            MouseArea{
                id:marea
                anchors.fill: parent
                visible: boolValueAssigned
                onClicked: {
                    valueId=-1;
                    valueName=null;
                    boolValueAssigned = false;
                    tfsearch.forceActiveFocus();
                    clear(); //emit signal clear
                    valueChanged(valueId, valueName);//emit signal onValueChanged(id,name)
                }
            }
        }
    }
    function execTimerDelaySearch(){
        tdelaysearch.restart();
    }

    TextField{
        id:tfsearch
        width: control.width
        visible: !boolValueAssigned
        leftPadding: 2
        onTextChanged: {
            if(boolSearch){
                execTimerDelaySearch();
            }
        }
        Keys.onPressed: {
            if (event.key === Qt.Key_Down ) {
                event.accepted = true;
                popuplist.forceActiveFocus();
            }
        }
    }
    property real popupWidth: control.width
    Component{
        id:pdelegate
        ItemDelegate {
            width: control.width
            height: control.height
            contentItem: Item{
                RowLayout{
                    anchors.fill: parent
                    Label {
                        id:textItem
                        text: name
                        Layout.fillWidth: true
                        color: mainroot.Material.foreground
                        elide: Text.ElideRight
                        maximumLineCount: control.maximumLineCount
                        verticalAlignment: Text.AlignVCenter
                        fontSizeMode: textFit?Text.Fit:Text.FixedSize
                        minimumPixelSize: 10
                    }
                }
            }
            highlighted: ListView.isCurrentItem
            onClicked: {
                selectItem({"id":id,"name":name});

            }
            Keys.onPressed: {
                if (event.key === Qt.Key_Return ) {
                    event.accepted = true;
                    selectItem({"id":id,"name":name});
                }
                if (event.key === Qt.Key_Enter ) {
                    event.accepted = true;
                    selectItem({"id":id,"name":name});
                }
            }
        }
    }
    Popup{
        id: popup
        y: control.height - 1
        width: popupWidth//control.width
        implicitHeight: control.implicitHeight
        padding: 1
        // modal: true
        //focus: true
        onClosed: {
            pmodel.clear();
            implicitHeight = control.implicitHeight
        }
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
        contentItem: ListView {
            id:popuplist
            clip: true
            implicitHeight: contentHeight
            model: popup.visible ? pmodel : null
            delegate: pdelegate
            //currentIndex: control.highlightedIndex
            //ScrollIndicator.vertical: ScrollIndicator { }
            ScrollBar.vertical: ScrollBar {policy: popuplist.contentHeight > height?ScrollBar.AlwaysOn:ScrollBar.AsNeeded}
        }
    }
}