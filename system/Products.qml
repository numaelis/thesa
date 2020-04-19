//this file is part the thesa: tryton client based PySide2(qml2)
// test example Products Price
//__author__ = "Numael Garay"
//__copyright__ = "Copyright 2020"
//__license__ = "GPL"
//__version__ = "1.0.0"
//__maintainer__ = "Numael Garay"
//__email__ = "mantrixsoft@gmail.com"

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import thesatools 1.0

TabDesktop {
    id:articulos
    onFirstTimeTab:{
        ModelProduct.find([[]])
    }

    Component.onCompleted: {
        ModelManagerQml.addModel("ModelProduct","ProxyModelProduct");
        //ModelProduct.signalResponseData.connect(onsignalResponseData);
        ModelProduct.setLanguage(planguage);
        ModelProduct.setSearch("model.product.template",
                               [],
                               1000,
                               [['name', 'ASC']],
                               ["rec_name", "name"]
                               );
        ModelProduct.setPreferences(preferences);

    }

    function selectProduct(mid){
        boolBlocking=true;
        var data= QJsonNetworkQml.callDirect("mpidproduct","model.product.template.read",
                                                     [
                                                         [mid],["cost_price","list_price"],preferences
                                                     ]);
        if(data.data!=="error"){
            if(data.data.result.length>0){
                var resultObject = data.data.result[0];
                var costp=0;
                var listp=0;
                if(resultObject.hasOwnProperty("cost_price")){
                    costp=resultObject.cost_price.decimal;
                }
                if(resultObject.hasOwnProperty("list_price")){
                    listp=resultObject.list_price.decimal;
                }

                showData(costp, listp);
            }
        }else{
            showData("","");
        }

        timerBlockingFalse.start();
    }
    function showData(cost, list){
        if(boolShortWidth135){
            dialog_price.open();
            dia_pricepur.text=qsTr("cost price:")+" $"+formatCentUp(cost);
            dia_pricesale.text=qsTr("list price:")+" $"+formatCentUp(list);
        }else{
            pricepur.text=qsTr("cost price:")+" $"+formatCentUp(cost);
            pricesale.text=qsTr("list price:")+" $"+formatCentUp(list);
        }
    }

    function findbyname(){
        if(ffind.text!=""){
            ModelProduct.find([["name","ilike","%"+ffind.text+"%"]]);//method asyncron
        }else{
            ModelProduct.find([[]]);
        }
    }
    Item {
        id: iii
        anchors.fill: parent
        Rectangle{
            anchors{fill: parent;margins: 8}
            border.width: 1
            border.color: Qt.darker(mainroot.Material.foreground)
            color: "transparent"
            Rectangle {
                anchors{fill: parent;margins: 8}
                border.width: 1
                border.color: Qt.darker(mainroot.Material.foreground)
                color: "transparent"
                Item{
                    id:panelleft
                    width: boolShortWidth135?parent.width:340// if < 13.5 cms
                    height: parent.height
                    Item {
                        id: itemsearch
                        width: parent.width
                        height: 56
                        TextField{
                            id:ffind
                            width: parent.width - bfind.width - 8 - brecarga.width
                            height: parent.height
                            selectByMouse: !boolMovil
                            anchors{left: parent.left}
                            placeholderText: qsTr("search by name")
                            Keys.onPressed: {
                                if (event.key === Qt.Key_Down ) {
                                    event.accepted = true;
                                    listViewProduct.forceActiveFocus();
                                }
                                if (event.key === Qt.Key_Return ) {
                                    event.accepted = true;
                                    findbyname();
                                }
                            }
                        }
                        ButtonAwesone{
                            id:bfind
                            width: height - 10
                            height: parent.height
                            anchors{right: brecarga.left;rightMargin: 4}
                            text: "\uf002"
                            onClicked: {
                                findbyname();
                            }
                        }
                        ButtonAwesone{
                            id:brecarga
                            width: height - 10
                            height: parent.height
                            anchors{right: parent.right}
                            text: "\uf01e"
                            textToolTip: qsTr("Reload")
                            onClicked: {
                                if(ffind.text!=""){
                                    ffind.text="";
                                }
                                ModelProduct.find([[]])
                            }

                        }
                    }

                    ListView {
                        id: listViewProduct
                        width: parent.width
                        height: parent.height - itemsearch.height-2
                        anchors{bottom: parent.bottom}
                        keyNavigationWraps: true
                        clip: true
                        focus: true
                        ScrollBar.vertical: ScrollBar { }
                        model: ProxyModelProduct
                        cacheBuffer: 0
                        onContentYChanged: {
                            if (contentY === contentHeight - height) {
                                ModelProduct.nextSearch();
                            }
                        }
                        delegate: ItemDelegate {
                            id:idelepro
                            width: parent.width
                            height: 40
                            //text: model.name
                            font.bold: true
                            font.pixelSize: 20
                            function getObjectId(){
                                return object.id;
                            }
                            contentItem: Item{
                                anchors{fill: parent;margins: 4}

                                Text {
                                    id:textoName
                                    width: parent.width
                                    height: parent.height

                                    fontSizeMode: Text.Fit
                                    minimumPixelSize: 8
                                    text: object.id +" "+ object.json.name
                                    //text: object.json.reference+" "+object.json.invoice_date.day+"/"+object.json.invoice_date.month+"/"+object.json.invoice_date.year +" "+ object.json.total_amount_format
                                    // {'__class__': 'date', 'year': 2019, 'day': 18, 'month': 11}
                                    font: idelepro.font
                                    color: idelepro.enabled ? idelepro.Material.primaryTextColor: idelepro.Material.hintTextColor
                                    elide: Text.ElideRight
                                    horizontalAlignment: Text.AlignLeft
                                    verticalAlignment: Text.AlignVCenter
                                    anchors{right: parent.right;top:parent.top}
                                }

                            }

                            highlighted: ListView.isCurrentItem
                            onClicked: {
                                listViewProduct.forceActiveFocus();
                                listViewProduct.currentIndex = model.index;
                                selectProduct(object.id);

                            }
                            Keys.onPressed: {
                                if (event.key === Qt.Key_Return ) {
                                    event.accepted = true;
                                    listViewProduct.forceActiveFocus();
                                    listViewProduct.currentIndex = model.index;
                                    selectProduct(object.id);
                                }
                                if (event.key === Qt.Key_Enter ) {
                                    event.accepted = true;
                                    listViewProduct.forceActiveFocus();
                                    listViewProduct.currentIndex = model.index;
                                    selectProduct(object.id);
                                }
                            }
                        }

                        onCurrentItemChanged: {

                        }
                    }
                }
                Item {
                    id: panelright
                    width: boolShortWidth135?0:parent.width-panelleft.width
                    height: parent.height
                    visible: !boolShortWidth135
                    anchors{left: panelleft.right}
                    Pane {
                        anchors.centerIn: parent
                        Column{
                            spacing: 20
                            Label{
                                id:pricepur
                                font.pixelSize: 30
                            }
                            Label{
                                id:pricesale
                                font.pixelSize: 30
                            }
                        }
                    }
                }
            }
        }
    }
    Dialog {
        id: dialog_price
        anchors.centerIn: parent
       // width: 300
        modal: true
        focus: true
        standardButtons: Dialog.Ok
        closePolicy: Dialog.NoAutoClose
        contentItem: Pane {
            anchors.centerIn: parent
            ColumnLayout{
                spacing: 20
                Label{
                    id:dia_pricepur
                    font.pixelSize: 30
                }
                Label{
                    id:dia_pricesale
                    font.pixelSize: 30
                }
            }
        }
    }
}
