//this file is part the thesa: tryton client,  PySide2(qml2) based
//"""Login.qml
//__author__ = "Numael Garay"
//__copyright__ = "Copyright 2020"
//__license__ = "GPL"
//__version__ = "1.4"
//__maintainer__ = "Numael Garay"
//__email__ = "mantrixsoft@gmail.com"

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import thesatools 1.0

Dialog {
    id:diLogin
    modal: true
    property bool boolExpand: false
    property var listTryVersion: ["4","5"]
    property bool boolBackLogin: false
    property real _height
    anchors.centerIn: parent

    focus: true
    width: boolExpand?maxWidthDialog:boolShortWidth135?maxWidthDialog-14:maxWidthDialog-200
    closePolicy: Dialog.NoAutoClose
    //standardButtons: Dialog.Ok | Dialog.Cancel
    onVisibleChanged: {
        if(visible){
            idatabase.text=setting.dbase;
            iport.text=setting.port;
            ihost.text=setting.host;
            inameuser.text=setting.user;
            ipassword.text="";

            itypelogin.index=setting.typelogin;
            itypesystem.index=setting.typesysmodule?1:0;

            boolExpand=false;
            if(inameuser.text.trim()!=""){
                ipassword.forcefocus();
            }else{
                inameuser.forcefocus();
            }
            _height=contentItem.height;
        }
    }
    header:Item{
        id:mh
        implicitHeight: 30
        Label{
            text:mainroot.boolSession? qsTr("Re-Sign in Tryton"):qsTr("Sign in Tryton")
            height: 30
            anchors.centerIn: parent
            font.pixelSize: 20
            font.bold: true
            color: mainroot.Material.accent
            verticalAlignment: Label.AlignVCenter
            horizontalAlignment: Label.AlignHCenter
        }
        Image {
            width: mh.height+20
            height: mh.height+10
            anchors{right: parent.right;rightMargin: 20; bottom: parent.bottom;bottomMargin: -20}
            asynchronous: true
            cache: false
            source: "images/login64.png"
            onStatusChanged: if(status == Image.Error){}
            fillMode: Image.PreserveAspectFit
            smooth: true
        }
    }
    function saveSettings(){
        setting.dbase=idatabase.text;
        setting.port=iport.text;
        setting.host=ihost.text;
        setting.user=inameuser.text.trim();
        setting.typelogin=itypelogin.index;
        setting.typesysmodule=itypesystem.index==0?false:true;
    }

    footer: ToolBar {
        id:mtb
        implicitHeight: 42
        background: Rectangle {
            width: mtb.width
            height: mtb.height
            color: "transparent"
        }
        RowLayout {
            anchors{right: parent.right;rightMargin: 8}
            height: parent.height
            spacing: 8
            ToolButton {
                id:bclosesession
                text: qsTr("Close Session")
                implicitHeight: 34
                visible: mainroot.boolSession
                onClicked: {
                    mainroot.closeSession();
                }
                contentItem: Text {
                    text: bclosesession.text
                    font: bclosesession.font
                    opacity: enabled ? 1.0 : 0.3
                    color: diLogin.Material.accent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
            }
            ToolButton {
                id:bconect
                text: qsTr("Connect")
                implicitHeight: 34
                onClicked: {
                    conection()
                }
                contentItem: Text {
                    text: bconect.text
                    font: bconect.font
                    opacity: enabled ? 1.0 : 0.3
                    color: diLogin.Material.accent//control.down ? "#17a81a" : "#21be2b"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
            }
        }
    }

    function conection(){
        boolBlocking=true;
        setting.typelogin=itypelogin.index;
        setting.typesysmodule=itypesystem.index==0?false:true;
        //update system and network
        QJsonNetworkQml.setVersionTryton(listTryVersion[setting.typelogin]);
        QJsonNetworkQml.openConect(inameuser.text.trim(),
                                   ipassword.text,
                                   ihost.text,
                                   iport.text,
                                   idatabase.text);
    }
    property alias aliasBackground: backgroundlogin.source
    contentItem: Pane{
        id:mp
        background: Item {
            width: mp.width
            height: mp.height
            Item {
                anchors.fill: parent
                visible: boolBackLogin
                Image {
                    id: backgroundlogin
                    anchors.fill: parent
                    asynchronous: true
                    cache: false
                    onStatusChanged: if(background.status == Image.Error){errorBackg()}
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                }
            }
            Rectangle {
                id:rectp
                anchors.fill: parent
                color: boolBackLogin?mainroot.Material.background:"transparent"
                border.color: mp.Material.background
                border.width: 1
                radius: miradius
                opacity: boolBackLogin?0.9:1
            }
        }

        Pane{
            id:panel1
            anchors.fill: parent
            padding: 0
            background: Item {
                width: mp.width
                height: mp.height
            }
            Keys.onPressed: {
                if (event.key == Qt.Key_Back) {
                    thesaClosing();
                    event.accepted = true;
                }
            }
            RowLayout{
                anchors.fill: parent
                ColumnLayout{
                    id:cl1
                    spacing: 8
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    RowLayout{
                        Layout.fillWidth: true
                        spacing: 8
                        InputLabelCube{
                            id:inameuser
                            label: qsTr("User Name:")
                            enabled: !mainroot.boolSession
                            fontSize:20
                            boolOnDesk: boolBackLogin
                            onAccepted: {
                                if(ipassword.text.trim()==""){
                                    ipassword.forcefocus();
                                }else{
                                    conection();
                                }
                            }
                            Layout.fillWidth: true
                        }

                    }
                    RowLayout{
                        Layout.fillWidth: true
                        spacing: 8
                        InputLabelCube{
                            id:ipassword
                            label: qsTr("Password:")
                            echoMode: TextField.Password
                            fontSize:20
                            boolOnDesk: boolBackLogin
                            onAccepted: {
                                conection();
                            }
                            Layout.fillWidth: true
                        }
                    }
                }
                Rectangle{
                    id:mibuttonexpand
                    width: 22
                    height: parent.height
                    border{width: 2; color: mainroot.Material.foreground}
                    radius: miradius
                    color: mainroot.Material.background
                    FlatAwesome {
                        id: mbexpand
                        width: parent.width
                        height: width
                        anchors{centerIn: parent}
                        text: boolExpand?"\uf137":"\uf138"
                        //textToolTip: qsTr("Config")
                        onClicked: {
                            if(boolExpand){
                                boolExpand = false;
                                mp.height=_height;
                            }else{
                                boolExpand = true;
                            }

                        }
                    }
                }
                ScrollView{
                    visible: boolExpand
                    clip: true
                    Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                    property real doublepadding: 20//mp.padding*2
                    Layout.maximumHeight: rectp.height-doublepadding
                    Layout.maximumWidth: cola.width//panel1.width/2

                    ColumnLayout{
                        id:cola
                        width: boolExpand?panel1.width/2:0
                        Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                        visible: boolExpand

                        InputLabelCube{
                            id:ihost
                            label: qsTr("Host:")
                            width: parent.width
                            enabled: !mainroot.boolSession
                            fontSize:18
                            boolOnDesk: boolBackLogin
                            //Layout.fillWidth: true
                        }
                        InputLabelCube{
                            id:iport
                            label: qsTr("Port:")
                            width: parent.width
                            enabled: !mainroot.boolSession
                            fontSize:18
                            boolOnDesk: boolBackLogin

                        }
                        InputLabelCube{
                            id:idatabase
                            label: qsTr("Data Base:")
                            width: parent.width
                            enabled: !mainroot.boolSession
                            fontSize:18
                            boolOnDesk: boolBackLogin
                        }
                        InputComboBoxCube{
                            id:itypelogin
                            enabled:!mainroot.boolSession
                            width: parent.width
                            label: qsTr("Type Login:")
                            model: ["tryton 4","tryton 5"]
                            boolOnDesk: boolBackLogin
                        }
                        InputComboBoxCube{
                            id:itypesystem
                            enabled: boolMovil?false:!mainroot.boolSession
                            width: parent.width
                            label: qsTr("Type System:")
                            model: ["Local","Module"]
                            boolOnDesk: boolBackLogin
                            Component.onCompleted: {
                                if(boolMovil){
                                    index=1;//movil only module
                                }
                            }
                        }
                    }

                }
            }
        }
    }

}
