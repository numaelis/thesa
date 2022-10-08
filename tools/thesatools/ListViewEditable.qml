//this file is part the thesa: tryton client based PySide2(qml2)
//__author__ = "Numael Garay"
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import "messages.js" as MessageLib

Rectangle {
    id:lve
    implicitWidth:  240
    height: heightList+heightTools + (1*padding)//dpis*18
    property real padding: 4*1.4
    property real heightTools: 30
    property real headMHeight: 16//font pixel head Model
    property real heightHeader: 20
    property real heightList: 100
    property alias delegate: mlistView.delegate
    property var listHead: []//{width,name}
    property bool boolEditable: true
    property alias label: label1.text
    property alias contentWidthListView: mlistView.contentWidth
    property alias currentIndex: mlistView.currentIndex

    radius: miradius
    color:"transparent"
    signal selectItem(int i);
    signal signalAddItem();
    property bool boolOnDesk: true
    Component.onCompleted: {
        if(boolOnDesk){
            onDesk();
        }
    }
    function forceFocus(){
        mlistView.forceActiveFocus();
    }

    function onDesk(){
        lve.border.width= 1
        radius= miradius+2
        lve.border.color= Qt.darker(mainroot.Material.foreground)
        lve.color= "transparent"
    }

    function clearModel(){
        miModel.clear();
    }

    function setModel(data){
        miModel.clear();
        var i = 0;
        var len=data.length;
        for(i=0;i<len;i++){
            miModel.append(data[i]);
        }
    }
    function getModel(){
        var dataList= [];
        var i = 0;
        var len=miModel.count;
        for(i=0;i<len;i++){
            dataList.append(miModel.get(i));
            mlistView.currentIndex=i;
            dataList.push(mlistView.currentItem.getData());//
        }
        return dataList;
    }
    function addItem(data){
        miModel.append(data);
        mlistView.positionViewAtEnd();
    }
    function delItem(index){
        miModel.remove(index);
    }

    ListModel{
        id:miModel
    }
    Item{
        id:mtools
        width: parent.width - (2*lve.padding)
        height: heightTools
        anchors{horizontalCenter: parent.horizontalCenter;top: parent.top;topMargin: lve.padding}
        Label{
            id:label1
            text: "hola:"
            width: parent.width - mbnew.width - mbdel.width - dpis
            font.bold: true
            font.italic: true
            //font.pixelSize: dpis*3
            height: parent.height
            anchors{left: parent.left}
            verticalAlignment: Label.AlignVCenter
        }

        MiniButton {
            id: mbnew
            width: height
            height: parent.height
            anchors{right: mbdel.left;rightMargin: dpis}
            enabled: boolEditable
            text:"\uf067"
            textToolTip: qsTr("New")
            onClicked: {

            }
        }
        MiniButton {
            id: mbdel
            width: height
            height: parent.height
            anchors{right: parent.right}
            enabled: boolEditable
            text:"\uf068"
            textToolTip: qsTr("Remove Item")
            onClicked: {
                preDelItem()
                  //delItem(mlistView.currentIndex);
            }
        }
    }

    ListView {
        id: mlistView
        width: parent.width - (2*lve.padding)
        height: heightList
        anchors{horizontalCenter: parent.horizontalCenter;bottom: parent.bottom; bottomMargin: 0}//ien.padding
        //anchors{fill:parent;topMargin: mhe.height+lve.padding;leftMargin: lve.padding; rightMargin: lve.padding;bottomMargin: lve.padding}
        contentWidth: headerItem.width
        keyNavigationWraps: true
        clip: true
        focus: true
        ScrollBar.vertical: ScrollBar { }
        ScrollBar.horizontal: ScrollBar { }
        ScrollIndicator.horizontal: ScrollIndicator { }
        ScrollIndicator.vertical: ScrollIndicator { }
        flickableDirection: Flickable.HorizontalAndVerticalFlick
        header:  Row {
            id:mHeaderView
            z:8
            //height: heightHeader
            spacing: 4
            function itemAt(index) { return repeater.itemAt(index) }
            Repeater {
                id: repeater
                model: listHead//["Quisque", "Posuere", "Curabitur", "Vehicula", "Proin"]
                Label {
                    text: modelData.name
                    font.bold: true
                    font.pixelSize:headMHeight
                    width:  modelData.width==-1?paintedWidth+20:modelData.width
                    elide: Label.ElideRight
                    topPadding: 10
                    bottomPadding: 10
                    background: Rectangle {color: mainroot.Material.background }
                    horizontalAlignment: modelData.align
                }
            }
        }
        headerPositioning:ListView.OverlayHeader
        model: miModel
        cacheBuffer: 0
        //delegate: compoDelegate


        onCurrentItemChanged: {
            lve.selectItem(currentIndex)
            //root.signalSelectPanel(currentIndex) //currentItem.url
        }
    }

    function preDelItem(){
        var tmens= "import QtQuick 2.9;import QtQuick.Controls 2.2;import QtQuick.Layouts 1.3;"+
                "Dialog {"+
                "id:msjdelcon;"+
                "modal: true;"+
                "x: ((mainroot.width - width) / 2);"+
                "y: ((mainroot.height - (height*2))/ 2);"+
                "width: (dpis*60);"+
                "title: qsTr('Confirmación');"+
                "visible: true;"+
                "focus: true;"+
                "closePolicy: Dialog.NoAutoClose;"+
                "standardButtons: Dialog.Ok | Dialog.Cancel;"+
                "onAccepted: {delItem(mlistView.currentIndex)}"+
                "onRejected: {}"+
                "Label {"+
                "id: lText;"+
                "width: parent.width;"+
                "text: '¿Desea Quitar este Item?';"+
                "wrapMode: Text.WordWrap;"+
                "maximumLineCount: 4;"+
                "font.bold: true;"+
                "elide: Label.ElideRight;"+
                "anchors.centerIn: parent;"+
                "horizontalAlignment: Text.AlignHCenter;"+
                "}"+
                "}"
        var s=Qt.createQmlObject(tmens, mainroot, "dynamicSnippet1");
    }

}
