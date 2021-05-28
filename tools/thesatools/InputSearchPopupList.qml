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
    property int valueId: -1
    property string valueName
    property bool boolSearch: true
    property alias textSearch: tfsearch.text
    property real heightDelegate: height
    signal textChanged(string text)//search
    signal valueChanged(int id, string name);
    property bool buttonSearchMinus: false
    //property bool buttonSearchPlus: false
    property bool boolForceSearch: false

    //signal clear()

    function forceActiveFocus(){
        tfsearch.forceActiveFocus();
    }

    function updateModel(dataList){
        pmodel.clear();
        for(var i=0,len=dataList.length;i<len;i++){
            pmodel.append({"id":dataList[i].id,"name":dataList[i].name})
        }
        if(len <= maxItemListHeight){
            popup.height = (len * heightDelegate)+2
        }else{
            popup.height = maxItemListHeight * heightDelegate
        }
    }

    function selectItem(data){
        updateValue(data);
    }

    function clearValue(){
        valueId=-1;
        valueName="";
        lname.text ="";
        popup.close();
        tfsearch.text="";
        boolValueAssigned=false;
        //no emit signal
    }

    function updateValue(values){// format -> {"id":-1,"name":""}
        setValue(values);
        tvalueEmit.start();
    }

    function setValue(values){// format -> {"id":-1,"name":""}
        valueId=values.id;
        valueName=values.name;
        if(valueId==-1){
            boolValueAssigned=false;
        }else{
            boolValueAssigned=true;
        }

        lname.text = values.name;
        popup.close();
        boolSearch=false;
        tfsearch.text="";
        ttruesearch.start();
    }

    Timer{
        id:tvalueEmit
        interval: 100
        onTriggered: {valueChanged(valueId, valueName);}//emit signal onValueChanged(id,name)}
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
            if(tfsearch.text=="" && boolForceSearch==false){
                popup.close();
            }else{
                popup.open();
                countSearch = countSearch>100?0:countSearch+1;
                control.textChanged(tfsearch.text);
                boolForceSearch=false;
            }
        }
    }

    ListModel{
        id:pmodel
    }

    function execTimerDelaySearch(){
        tdelaysearch.restart();
    }

    TextField{
        id:tfsearch
        anchors.fill: parent
        //width: control.width //- fban.width
        readOnly: boolValueAssigned
        topPadding: 0
        onTextChanged: {
            if(boolSearch===true && boolValueAssigned===false){
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

    Item{
        anchors{fill:parent; bottomMargin: tfsearch.bottomPadding-4}
        Label{
            id:lname
            visible: boolValueAssigned
            anchors{fill:parent;rightMargin: 24}
            maximumLineCount: control.maximumLineCount
            elide: Label.ElideRight
            fontSizeMode: textFit?Text.Fit:Text.FixedSize
            minimumPixelSize: 10
            font.pixelSize: tfsearch.font.pixelSize
            verticalAlignment: Text.AlignVCenter
        }
        FlatAwesome {
            id: fbse
            width: height
            height: 20
            visible: boolValueAssigned==false?buttonSearchMinus==true?true:false:false
            anchors{right: parent.right; verticalCenter: parent.verticalCenter; verticalCenterOffset:-lname.bottomPadding}
            text:"\uf0d7"//"\uf010"
            onClicked: {
                tfsearch.text="";
                boolForceSearch=true;
                tdelaysearch.start();
                if(tfsearch.focus==false){
                    tfsearch.forceActiveFocus();
                }

            }
        }
        FlatAwesome {
            id: fban
            width: height
            height: 20
            visible: boolValueAssigned
            anchors{right: parent.right; verticalCenter: parent.verticalCenter; verticalCenterOffset:-lname.bottomPadding}
            text:"\uf00d"
            onClicked: {
                valueId=-1;
                valueName=null;
                boolValueAssigned = false;
                tfsearch.forceActiveFocus();
                // clear(); //emit signal clear
                valueChanged(valueId, valueName);//emit signal onValueChanged(id,name)

            }
        }
    }

    property real popupWidth: control.width
    Component{
        id:pdelegate
        ItemDelegate {
            width: control.width
            height: heightDelegate//control.height
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
            ScrollBar.vertical: ScrollBar {policy: popuplist.contentHeight > height?ScrollBar.AlwaysOn:ScrollBar.AlwaysOff}
        }
    }
}
