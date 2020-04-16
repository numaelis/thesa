//this file is part the thesa: tryton client based PySide2(qml2)
// test example Statistics by year
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
import QtCharts 2.3
import thesatools 1.0

TabDesktop {
    id:statistic

    property  var  listShortNamesMonths: Tools.calendarShortNamesMonths(planguage);

    onFirstTimeTab:{
        ModelProduct2.find([[]])
    }

    Component.onCompleted: {
        ModelManagerQml.addModel("ModelProduct2","ProxyModelProduct2");
        //ModelProduct2.signalResponseData.connect(onsignalResponseData);
        ModelProduct2.setLanguage(planguage);
        ModelProduct2.setSearch("model.product.template",
                                [],
                                1000,
                                [['name', 'ASC']],
                                ["rec_name", "name"]
                                );
        ModelProduct2.setPreferences(preferences);
    }

    function selectProduct(mid){
        openBusy();
//        console.log("mid",mid)
        var data= QJsonNetworkQml.callDirect("my_pid_1","model.sale.line.search_read",
                                             [
                                                 ['AND',
                                                  [['sale.sale_date','>=', tfyear.text+'-01-01']],
                                                  [['sale.sale_date','<=', tfyear.text+'-12-31']],
                                                  [['product', '=', mid]]],0,null,
                                                 [['sale.sale_date', 'ASC']],
                                                 ["sale.sale_date","product","quantity","product.name"],
                                                 preferences
                                             ]);

        if(data.data!=="error"){
            var resultArray = data.data.result;
            barSeries.clear();
            barSeries2.clear();

            var record,mk;
            var objectQuantyMonth ={
                '1':0,
                '2':0,
                '3':0,
                '4':0,
                '5':0,
                '6':0,
                '7':0,
                '8':0,
                '9':0,
                '10':0,
                '11':0,
                '12':0
            }

            for(var i=0,len=resultArray.length;i<len;i++){
                record = resultArray[i];
                mk=record["sale.sale_date"].month.toString();
                if(objectQuantyMonth.hasOwnProperty(mk)){
                    objectQuantyMonth[mk]=objectQuantyMonth[mk]+record.quantity;
                }
            }
            var listQuantyMonth = [];
            for( var rm in objectQuantyMonth){
                listQuantyMonth.push(parseInt(objectQuantyMonth[rm]));
            }
            if(boolShortWidth135){
                dialog_stat_movil.open();
                barSeries2.append(tfyear.text, listQuantyMonth);
                maxisY2.max = Math.max.apply(null,listQuantyMonth);//+5;
            }else{
                barSeries.append(tfyear.text, listQuantyMonth);
                maxisY.max = Math.max.apply(null,listQuantyMonth);//+5;
            }

        }else{
            barSeries.clear();
            barSeries2.clear();
        }
        closeBusy();
    }

    function findbyname(){
        if(ffind.text!=""){
            ModelProduct2.find([["name","ilike","%"+ffind.text+"%"]]);//method asyncron
        }else{
            ModelProduct2.find([[]]);
        }
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
                    RowLayout{
                        Label{
                            text:qsTr("year to analyze: ")
                        }
                        TextField{
                            id:tfyear
                            width: 100
                            height: 50
                            validator: RegExpValidator { regExp:/^(19|20|21)\d\d$/}
                            Component.onCompleted: {text=2020}
                            onFocusChanged: {if(focus==false){if(text==""){text=2020}}}
                        }
                    }
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
                                ModelProduct2.find([[]])
                            }

                        }
                    }

                    Item{
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        ListView {
                            id: listViewProductS
                            anchors.fill: parent
                            keyNavigationWraps: true
                            clip: true
                            focus: true
                            ScrollBar.vertical: ScrollBar { }
                            model: ProxyModelProduct2
                            cacheBuffer: 0
                            //onYChanged: {}
                            onContentYChanged: {
                                if (contentY === contentHeight - height) {
                                    ModelProduct2.nextSearch();//asyncron
                                }
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
                                        id:textoName
                                        width: parent.width
                                        height: parent.height
                                        fontSizeMode: Text.Fit
                                        minimumPixelSize: 8//object.json.create_date_format
                                        text: object.id +" "+ object.json.name
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
                                    listViewProductS.forceActiveFocus();
                                    listViewProductS.currentIndex = model.index;

                                    selectProduct(object.id);

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
                ChartView {
                    id:mviewStat
                    title: qsTr("product sales statistics per year")
                    anchors.fill: parent
                    legend.alignment: Qt.AlignBottom
                    antialiasing: true
                    theme: setting.theme
                    BarSeries {
                        id:barSeries
                        axisX: BarCategoryAxis {
                            categories:
                                listShortNamesMonths
                            //["ene", "feb", "mar", "abr", "may", "jun","jul", "ago", "sep", "oct", "nov", "dic" ]
                        }
                        axisY: ValueAxis {
                            id:maxisY
                            min: 0
                            max: 150
                        }
                    }
                }
            }
        }
    }
    Dialog {
        id: dialog_stat_movil
        anchors.centerIn: parent
        width: parent.width-10
        height: parent.height-20
        modal: true
        focus: true
        standardButtons: Dialog.Ok
        closePolicy: Dialog.NoAutoClose
        contentItem: Pane {
            anchors.fill: parent
            ChartView {
                id:mviewStat2
                title: qsTr("product sales statistics per year")
                anchors.fill: parent
                legend.alignment: Qt.AlignBottom
                antialiasing: true
                theme: setting.theme

                BarSeries {
                    id:barSeries2
                    axisX: BarCategoryAxis {
                        categories:
                            listShortNamesMonths
                    }
                    axisY: ValueAxis {
                        id:maxisY2
                        min: 0
                        max: 150
                    }
                }
            }
        }
    }
}
