//this file is part the thesa: tryton client based PySide2(qml2)
// test example Party Call
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
    id:partys

    onFirstTimeTab:{
        ModelPerson.find();
    }

    Component.onCompleted: {
        ModelManagerQml.addModel("ModelPerson","ProxyModelPerson");
        ModelPerson.setLanguage(planguage);
        ModelPerson.setModelMethod("model.party.party");
        ModelPerson.setDomain([]);
        ModelPerson.setMaxLimit(1000);
        ModelPerson.setOrder([['name', 'ASC']])
        ModelPerson.setFields(["rec_name", "name"]);
        ModelPerson.setPreferences(preferences);

//        ModelPerson.setSearch("model.party.party",
//                              [],
//                              1000,
//                              [['name', 'ASC']],
//                              ["rec_name", "name"]
//                              );
    }


    function selectParty(mid){
        openBusy();
        myModelPhone.clear();
        var data= QJsonNetworkQml.recursiveCall("my_pid_1","model.party.contact_mechanism.search_read",
                                             [
                                                 ['party', '=', mid],0,null,
                                                 [],
                                                 ["type","value"],
                                                 preferences
                                             ]);

        if(data.data!=="error"){
            var resultArray = data.data.result;
            var phonesArray=[];
            for(var i=0,len=resultArray.length;i<len;i++){
                var record = resultArray[i];
                if(record.type == "phone"){
                    myModelPhone.append({phone:record.value})

                }
            }

            if(myModelPhone.count>0){
                if(boolShortWidth135){
                    dialog_party.open();
                }

            }else{
                MessageLib.showMessage(qsTr("does not have a phone number"), mainroot);
            }


        }
        closeBusy();
    }
    ListModel{
        id:myModelPhone
    }

    function findbyname(){
        if(ffind.text!=""){
            ModelPerson.find(["name","ilike","%"+ffind.text+"%"]);
        }else{
            ModelPerson.find();
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
                    Item{
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.maximumHeight: 56
                        TextField{
                            id:ffind
                            width: parent.width - bfind.width - 8 - brecarga.width
                            height: parent.height
                            selectByMouse: !isMobile
                            anchors{left: parent.left}
                            placeholderText: qsTr("search by name")
                            Keys.onPressed: {
                                if (event.key === Qt.Key_Return ) {
                                    event.accepted = true;
                                    findbyname();
                                }
                            }
                        }
                        ButtonAwesome{
                            id:bfind
                            width: height - 10
                            height: parent.height
                            anchors{right: brecarga.left;rightMargin: 4}
                            text: "\uf002"
                            onClicked: {
                                findbyname();
                            }
                        }
                        ButtonAwesome{
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
                                ModelPerson.find();
                            }

                        }
                    }

                    Item{
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        ListView {
                            id: listViewParty
                            anchors.fill: parent
                            keyNavigationWraps: true
                            clip: true
                            focus: true
                            ScrollBar.vertical: ScrollBar { }
                            model: ProxyModelPerson
                            cacheBuffer: 0
                            //onYChanged: {}
                            onContentYChanged: {
                                if (atYEnd){
                                    if(parseFloat(contentY).toFixed(5) == contentHeight - height){
                                        ModelPerson.nextSearch();
                                    }
                                }
//                                if (contentY === contentHeight - height) {
//                                    ModelPerson.nextSearch();
//                                }
                            }
                            delegate: ItemDelegate {
                                id:idelepro
                                width: listViewParty.width
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
                                        minimumPixelSize: 8
                                        text: object.json.name
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
                                    listViewParty.forceActiveFocus();
                                    listViewParty.currentIndex = model.index;

                                    selectParty(object.id);

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
                ListView {
                    id: listViewPhone
                    width: 300
                    height: parent.height
                    anchors.centerIn: parent
                    clip: true
                    ScrollBar.vertical: ScrollBar { }
                    model:myModelPhone
                    delegate: Item{
                        id:ideph
                        width: listViewPhone.width
                        height: 40
                        RowLayout{
                            anchors.fill: parent
                            Label{
                                text:phone
                            }
                            Button{
                                text: qsTr("Call");
                                onClicked: {
                                    Tools.callPhone(phone);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    Dialog {
        id: dialog_party
        //anchors.centerIn: parent
        x: (parent.width - width) / 2
        y: (parent.height - (height))/ 2
        width: parent.width-30
        height: parent.height-30
        modal: true
        focus: true
        standardButtons: Dialog.Ok
        closePolicy: Dialog.NoAutoClose
        contentItem: Pane {
            anchors.fill: parent
            ListView {
                id: listViewPhone2
                width: 300
                anchors.fill: parent
                clip: true
                ScrollBar.vertical: ScrollBar { }
                model:myModelPhone
                delegate: Item{
                    width: listViewPhone2.width
                    height: 40
                    RowLayout{
                        anchors.fill: parent
                        Label{
                            text:phone
                        }
                        Button{
                            text: qsTr("Call");
                            onClicked: {
                                Tools.callPhone(phone);
                            }
                        }
                    }
                }
            }

        }
    }
}
