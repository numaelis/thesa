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
        ModelInvoices.find([['type','=','out']])//synchro
    }

    Component.onCompleted: {
        ModelManagerQml.addModel("ModelInvoices","ProxyModelInvoices");
        //ModelInvoices.signalResponseData.connect(onsignalResponseData);
        ModelInvoices.setLanguage(planguage);
        ModelInvoices.setModelMethod("model.account.invoice");
        ModelInvoices.setDomain([['type','=','out']]);//
        ModelInvoices.setMaxLimit(1000);
        ModelInvoices.setOrder([['number', 'DESC'],['invoice_date', 'DESC']])
        //ModelInvoices.setFields([]);->>load all fields model
        ModelInvoices.setFields(['reference','invoice_date','total_amount','create_date', 'party.name']);
        ModelInvoices.setPreferences(preferences);

        ModelInvoices.addFieldFormatDecimal(['total_amount']);// config .setLanguage(planguage);
        ModelInvoices.addFieldFormatDateTime([['invoice_date','dd/MM/yy'],['create_date','dd/MM/yy hh:mm:ss']]);//:

        //        ModelInvoices.setSearch("model.account.invoice",
//                                [['type','=','in']],
//                                10,
//                                [['number', 'DESC'],['invoice_date', 'DESC']],
//                                []//['reference','invoice_date','total_amount','create_date']
//                                );


    }

    Frame{
        anchors.fill: parent
        RowLayout{
            anchors.fill: parent
            spacing: f2.padding
            Frame{
                id:f2
                Layout.fillHeight: true
                Layout.fillWidth: true
                //Layout.minimumWidth: 340//dpis*85
                Layout.maximumWidth: boolShortWidth135?parent.width:340// if < 13.5 cms
                ColumnLayout{
                    anchors.fill: parent
                    spacing: 4
                    Item{
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.maximumHeight: 56
                        TextField{
                            id:ffind
                            width: parent.width - bfind.width - 8 - brecarga.width
                            height: parent.height
                            selectByMouse: !boolMovil
                            anchors{left: parent.left}
                            placeholderText: qsTr("search by name")
                            Keys.onPressed: {
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
                               ModelInvoices.find([['type','=','out']])
                            }

                        }
                    }

                    Item{
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        ListView {
                            id: listViewInvoices
                            anchors.fill: parent
                            keyNavigationWraps: true
                            clip: true
                            focus: true
                            ScrollBar.vertical: ScrollBar { }
                            model: ProxyModelInvoices
                            cacheBuffer: 0
                            //onYChanged: {}
                            onContentYChanged: {
                                if (atYEnd){
                                    if(parseFloat(contentY).toFixed(5) == contentHeight - height){
                                        ModelInvoices.nextSearch();
                                    }
                                }
//                                if (contentY === contentHeight - height) {
//                                    ModelInvoices.nextSearch();//asyncron
//                                }
                            }
                            delegate: ItemDelegate {
                                id:idelepro
                                width: parent.width
                                height: 40
                                font.bold: true
                                font.pixelSize: 20
                                function getObjectId(){
                                    return object.id;
                                }
                                contentItem: Item{
                                    anchors{fill: parent;margins: 4}

                                    Text {
                                        id:trefer
                                        width: parent.width
                                        height: parent.height/4
                                        fontSizeMode: Text.Fit
                                        minimumPixelSize: 8
                                        text: object.json.reference
                                        font: idelepro.font
                                        color: idelepro.enabled ? idelepro.Material.primaryTextColor: idelepro.Material.hintTextColor
                                        elide: Text.ElideRight
                                        horizontalAlignment: Text.AlignLeft
                                        verticalAlignment: Text.AlignVCenter
                                        anchors{right: parent.right;top:parent.top}
                                    }
                                    Text {
                                        id:tname
                                        width: parent.width
                                        height: parent.height-trefer.height
                                        fontSizeMode: Text.Fit
                                        minimumPixelSize: 8//object.json.create_date_format
                                        text: object.json.invoice_date_format+"   "+ object.json['party.name'].substring(0,16)+"   $"+ object.json.total_amount_format
                                        font: idelepro.font
                                        color: idelepro.enabled ? idelepro.Material.primaryTextColor: idelepro.Material.hintTextColor
                                        elide: Text.ElideRight
                                        horizontalAlignment: Text.AlignLeft
                                        verticalAlignment: Text.AlignVCenter
                                        anchors{right: parent.right;bottom: parent.bottom}
                                    }

                                }

                                highlighted: ListView.isCurrentItem
                                onClicked: {
                                    listViewInvoices.forceActiveFocus();
                                    listViewInvoices.currentIndex = model.index;

                                    //selectProduct(object.id);

                                }
                            }
                        }
                    }
                }
            }
            Frame{
                id:ffg
                Layout.fillHeight: true
                Layout.fillWidth: true
                width: boolShortWidth135?0:implicitWidth
                visible: !boolShortWidth135

            }
        }
    }

}
