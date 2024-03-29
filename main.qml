//this file is part the thesa: tryton client,  PySide2(qml2) based
//"""main.qml
//__author__ = "Numael Garay"
//__copyright__ = "Copyright 2020-2021"
//__license__ = "GPL"
//__version__ = "1.8"
//__maintainer__ = "Numael Garay"
//__email__ = "mantrixsoft@gmail.com"

import QtQuick 2.9
import QtQuick.Window 2.3
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import QtQuick.Dialogs 1.1
import QtQml 2.2
import thesatools 1.0

ApplicationWindow {
    id:mainroot
    objectName: "mainroot"
    visible: true
    width: 640
    height: 480
    Material.theme: setting.theme
    Material.accent: setting.accent
    Material.primary: setting.primary
    property real plusDpis: 0 //// CONFIG, bug windows, in windows up plusDpis: 2
    property real dpisFix: parseFloat(Screen.pixelDensity).toFixed(2)//pixels for milimeter
    property real dpisReal: dpisFix + plusDpis
    property int dpis: parseInt(dpisFix + plusDpis)

    property int maxWidthDialog: Screen.desktopAvailableWidth<600?Screen.desktopAvailableWidth:600
    property int maxHeightDialog: 500

    property bool isMobile: false //textArea textfield for android movil = true, only module
    property bool boolqrclocal: false //for android = true and drawer=true

    property real miradius: 2

    property bool boolLogin: false
    property bool boolSession: false
    property var preferences
    property var preferencesAll
    property string luser: ""//login user
    property string psignature: ""//preferences signature
    property string planguage: "es" //languaje from tryton config, auto update sign in
    property string thousands_sep: "." // from tryton config
    property string decimal_point: "," // from tryton config
    property string myFontPrenta:finglobal.name//"Inglobal"
    property bool bool403: false
    property bool bool401: false
    property var argsFucntionLastCall
    property bool boolShortWidth135: width<(dpisReal*135)?true:false//13.5 cm
    property bool boolShortWidth16: width<(dpisReal*160)?true:false//16 cm
    property bool boolShortWidth: width<(dpisReal*90)?true:false//9 cm
    property string dirSystem: setting.typesysmodule?"systemnet":"system"
    property bool boolDrawer: setting.boolDrawer
    property var listTranslations
    property var nameShortDays: Tools.calendarShortNamesDays();
    property var nameLongMonths: Tools.calendarLongNamesMonths();
    property int maxIntervalBusy: 30000 //miliseconds
    property int _intCountModels: 0
    property var generalPurpose: ({})
    property string myCompany: ""
    property string postTitle: ""
    property int mid: 0
    property string methodLogin: "common.db.login"
    property string sessionToken: ""
    property var listToken: []
    property bool visibleCheckAlways: false

    visibility:  Window.Maximized
    title: qsTr("thesa mushroom [tryton]  -  "+ myCompany)

    Component.onCompleted: {
        QJsonNetworkQml.signalResponse.connect(jsonNetSignalResponse);
        tbackground.start();
        swicheDra.checked=setting.boolDrawer;
        listTranslations=Tools.getListCoreTranslations();
        var indexLan = listTranslations.indexOf(setting.translate);
        if(indexLan!=-1){
            listViewTrans.currentIndex=indexLan;
            listViewTrans.currentItem.checked = true;
        }else{
            listViewTrans.currentIndex=listTranslations.indexOf("en");
            listViewTrans.currentItem.checked = true;
        }
    }

    onClosing:{
        close.accepted = false;
        questionClose();
    }
    function questionClose(){
        dquestionclose.open();
    }

    function preThesaClosing(){
        checkClosable();//warning: must be synchronous <<function preClosing in tab>>
        thesaClosing();
    }

    function thesaClosing(){
        if(boolSession){
            QJsonNetworkQml.forceNotRun();
            QJsonNetworkQml.callDirect("desconect","common.db.logout",
                                 []);
            tquit.start();
        }else{
            Qt.quit();
        }
    }

    Timer{
        id:tquit
        interval: 200
        onTriggered: Qt.quit()
    }

    ListModel {
        id: tabModel
    }

    header: ToolBar {
        id:maintoolbar
        RowLayout {
            anchors.fill: parent
            ToolButton{
                id:toolbdrawer
                font.family: fawesome.name
                font.italic: false
                width: boolDrawer?implicitWidth:0
                visible: boolDrawer
                text: "\uf061"//    f057
                font.pixelSize: 20
                onClicked: menudrawer.open()
                Layout.preferredWidth:boolShortWidth16?30:implicitWidth

            }
            Label {
                text: boolShortWidth135?boolDrawer?"T":" Th":boolDrawer?"Thesa":" Thesa"
                elide: Label.ElideRight
                font.pixelSize: 22
                font.italic: false
                font.family: myFontPrenta
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
            }
            Label{
                text:boolShortWidth?"":"  "
                Layout.fillWidth: true
                visible:!boolShortWidth16
            }
            RowLayout {
                 id:lTitleBarra
                 property var objtitle: {"name":"","icon":""}
                 Layout.preferredWidth:boolShortWidth16?30:t1.width+t2.width
                 Label {
                     id: t1
                     width: paintedWidth
                     text:lTitleBarra.objtitle.icon
                     font.family: fawesome.name
                     font.pixelSize: 22
                     font.italic: false
                     verticalAlignment: Label.AlignVCenter
                 }
                 Label {
                     id: t2
                     width: boolShortWidth?0:paintedWidth
                     font.pixelSize: 22
                     font.italic: false
                     text: boolShortWidth16?"":lTitleBarra.objtitle.name + postTitle
                     visible:!boolShortWidth16
                     verticalAlignment: Label.AlignVCenter
                 }
            }
            Label{
                text:boolShortWidth?"":"  "
                Layout.fillWidth: true
                visible:tabModel.count<2
            }
            TabBar {
                id: barroot
                implicitWidth:parent.width/2
                visible: tabModel.count>1
                Layout.fillWidth: true
                Layout.preferredWidth: parent.width//boolShortWidth16?parent.width/2:parent.width / 2
                property var idStackUse
                onCurrentIndexChanged: {
                    if(idStackUse!=null){
                        idStackUse.currentIndex = currentIndex;
                    }
                }

                Repeater {
                    id:rebarroot
                    model: tabModel
                    TabButton {
                        // text: boolShortWidth?model.icon:model.icon +"   " + model.name
                        font.bold: true
                        font.italic: false
                        Layout.fillWidth: true
                        contentItem: Item{
                            id:ii
                            RowLayout{
                                anchors.fill: parent
                                spacing: 10
                                Label{
                                    id:licon
                                    text:model.icon
                                    font.family: fawesome.name
                                    font.pixelSize: 17
                                    elide: Label.ElideRight
                                    verticalAlignment: Label.AlignVCenter
                                }
                                Label{
                                    width: boolShortWidth?0:implicitWidth
                                    text: boolShortWidth?"":model.name
                                    font.pixelSize: 17
                                    elide: Label.ElideRight
                                    verticalAlignment: Label.AlignVCenter
                                    Layout.fillWidth: true
                                }
                            }

                        }


                        onClicked: {
                            if(barroot.idStackUse!=null){
                                barroot.idStackUse.clickTab();
                            }
                        }
                    }
                }
                function addTabs(tabs, idsc){
                    for(var i=0,len=tabs.length;i<len;i++){
                        tabModel.append({name: tabs[i].name, icon: tabs[i].icon});
                    }
                    idStackUse = idsc;
                }
                function deleteTabs(){
                    if(idStackUse!=null){
                        idStackUse.saveIndex();
                    }
                    tabModel.clear();
                }
            }

            ToolButton {
                id:toolbsession
                text: boolShortWidth16?"\uf007":luser+" ["+psignature+"]"//nombre usuario
                //onClicked: menu.open()
                onClicked: optionsMenu.open()
                font.family: boolShortWidth16?fawesome.name:"default"
                font.italic: false
                font.pixelSize: boolShortWidth16?20:14
                Layout.preferredWidth:boolShortWidth16?30:implicitWidth
                Menu {
                    id: optionsMenu
                    x: parent.width - width
                    // transformOrigin: Menu.TopRight

                    MenuItem {
                        id: ms1
                        text: qsTr("Close Session")
                        font.family: myFontPrenta//"Inglobal"
                        font.italic: true
                        font.bold: true
                        contentItem: Text{
                            text: ms1.text
                            font: ms1.font
                            color: ms1.down ? Material.hintTextColor:Material.primaryTextColor
                            horizontalAlignment: Text.AlignLeft
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }

                        onTriggered: {
                            //cerrar session
                            closeSession();
                        }

                    }
                }
            }
            ToolButton {
                id:toolbconfig
                font.family: fawesome.name
                font.italic: false
                font.pixelSize: 20
                text: "\uf0c9"//"\uf085"
                onClicked: configmenu.open()
                Layout.preferredWidth:boolShortWidth135?30:implicitWidth
                Menu {
                    id: configmenu
                    x: parent.width - width
                    transformOrigin: Menu.BottomLeft
                    MenuItem{
                        id:miscreen
                        text: qsTr("Screen")
                        font.family: myFontPrenta
                        font.italic: true
                        font.bold: true
                        onTriggered: {
                            menuscreen.open();
                        }
                        Menu{
                            id:menuscreen
                            MenuItem {
                                id: mi1
                                text: qsTr("Color")
                                font.family: myFontPrenta
                                font.italic: true
                                font.bold: true
                                onTriggered: {
                                    meco.open();
                                }
                                Menu{
                                    id:meco
                                    MenuItem {
                                        text: "Black Green"
                                        onTriggered: {
                                            setting.theme = Material.Dark;
                                            setting.accent = "#41cd52";
                                            setting.primary = "#41cd52";
                                            MessageLib.showMessage(qsTr("maybe you have to restart the application"), mainroot);
                                        }
                                    }
                                    MenuItem {
                                        text: "Black Orange"
                                        onTriggered: {
                                            setting.theme = Material.Dark;
                                            setting.accent = "#f9851d";//Qt.lighter("orange");
                                            setting.primary = "#f9851d";
                                            MessageLib.showMessage(qsTr("maybe you have to restart the application"), mainroot);
                                        }
                                    }
                                    MenuItem {
                                        text: "Black Silver"
                                        onTriggered: {
                                            setting.theme = Material.Dark;
                                            setting.accent = "silver";//Qt.lighter("orange");
                                            setting.primary = "silver";
                                            MessageLib.showMessage(qsTr("maybe you have to restart the application"), mainroot);
                                        }
                                    }
                                    MenuItem {
                                        text: "Light Blue"
                                        onTriggered: {
                                            setting.theme = Material.Light;
                                            setting.accent = Qt.lighter("blue");
                                            setting.primary = Qt.lighter("blue");
                                            MessageLib.showMessage(qsTr("maybe you have to restart the application"), mainroot);
                                        }
                                    }
                                    MenuItem {
                                        text: "Light Green"
                                        onTriggered: {
                                            setting.theme = Material.Light;
                                            setting.accent = "#41cd52";
                                            setting.primary = "#41cd52";
                                            MessageLib.showMessage(qsTr("maybe you have to restart the application"), mainroot);
                                        }
                                    }
                                    MenuItem {
                                        text: "Light Silver"
                                        onTriggered: {
                                            setting.theme = Material.Light;
                                            setting.accent = "silver";
                                            setting.primary = "silver";
                                            MessageLib.showMessage(qsTr("maybe you have to restart the application"), mainroot);
                                        }
                                    }
                                }
                            }
                            MenuItem {
                                id:mi2
                                text: qsTr("Background")
                                font.family: myFontPrenta
                                font.italic: true
                                font.bold: true

                                onTriggered: {
                                    mefo.open();
                                }
                                Menu{
                                    id:mefo
                                    MenuItem {
                                        contentItem: Switch {
                                            id:swicheBack
                                            text: qsTr("Background")
                                            onCheckedChanged: {
                                                if(checked){
                                                    setting.boolBackground=true;

                                                }else{
                                                    setting.boolBackground=false;
                                                }
                                                mefo.close();
                                            }
                                        }
                                    }
                                }
                            }
                            MenuItem {
                                id:mi3
                                text: qsTr("Drawer")
                                font.family: myFontPrenta
                                font.italic: true
                                font.bold: true

                                onTriggered: {
                                    medr.open();
                                }
                                Menu{
                                    id:medr
                                    MenuItem {
                                        contentItem: Switch {
                                            id:swicheDra
                                            text: qsTr("Drawer")
                                            onClicked: {
                                                if(checked){
                                                    setting.boolDrawer=true;
                                                    menulistdrawer.aliasmodel=container.menumodel
                                                    menulistdrawer.aliasCurrentIndex=menulist.aliasCurrentIndex;
                                                    menudrawer.open();
                                                }else{
                                                    setting.boolDrawer=false;
                                                    menulist.aliasmodel=container.menumodel
                                                    menulist.aliasCurrentIndex=menulistdrawer.aliasCurrentIndex;
                                                }
                                                medr.close();
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    MenuItem {
                        id:mi4
                        text: qsTr("Translation")
                        font.family: myFontPrenta
                        font.italic: true
                        font.bold: true

                        onTriggered: {
                            medl.open();
                        }
                        Menu{
                            id:medl
                            MenuItem {
                                width: 180
                                height: listViewTrans.count<6?(listViewTrans.count+1)*30:6*30
                                contentItem: ListView {
                                    id:listViewTrans
                                    model: listTranslations
                                    delegate: RadioDelegate {
                                        height: 30
                                        text: modelData
                                        ButtonGroup.group: buttonGroup
                                        onClicked: {
                                            if(setting.translate!=modelData){
                                                setting.translate=modelData;
                                                MessageLib.showMessage(qsTr("you must restart the application"), mainroot);
                                            }
                                            medl.close();
                                        }
                                    }
                                    ScrollBar.vertical: ScrollBar { }
                                    ButtonGroup {
                                        id: buttonGroup
                                    }
                                }
                            }
                        }
                    }

                    MenuItem {
                        id: mi5
                        text: qsTr("About")
                        font.family: myFontPrenta
                        font.italic: true
                        font.bold: true

                        onTriggered: {
                            dabout.open();
                        }
                    }
                }
            }
        }
    }
    function backLogin(){
        boolLogin=false;
        MessageLib.showMessage(qsTr("Warning!\nthe last order could not be made"), mainroot);
    }

    function closeSession(){
        checkClosable();//warning: must be synchronous <<function preClosing in tab>>
        boolLogin=false;
        boolSession=false;
        sessionToken = "";
        bool403=false;
        bool401=false;
        psignature="";
        myCompany="";
        luser="";
        postTitle="";
        openBusy();
        barroot.currentIndex=-1;
        barroot.deleteTabs();
        if(boolDrawer){
            menulistdrawer.aliasCurrentIndex=-1;
            menulistdrawer.aliasmodel.clear();
        }else{
            menulist.aliasCurrentIndex=-1;
            menulist.aliasmodel.clear();
        }

        if(container.desktop!=null){
            container.desktop.destroy();
            //clear todos los models
            ModelManagerQml.deleteModels();
        }
        ModelManagerQml.clearComponentCache();
        lTitleBarra.objtitle={
            "name":"",
            "icon":""
        };
        QJsonNetworkQml.forceNotRun();
        QJsonNetworkQml.callDirect("desconect","common.db.logout",
                             []);
        closeBusy();
    }
//  test
//    property var argsResponse
//    function _jsonNetSignalResponse(){
//        jsonNetSignalResponse(argsResponse[0],argsResponse[1],argsResponse[2]);
//        argsResponse=[];
//    }

    function  jsonNetSignalResponse(pid, option, data){
        if(pid==="run@"){
            if(option===8){
                MessageLib.showMessage("Warning!\nmultiple calls at once", mainroot);
            }
        }

        if(pid==="open@"){
            var jsonDataOpen=data;
            if(option===1){
                console.log("se redirecciona...");
            }
            if(option===2){
                if(jsonDataOpen.hasOwnProperty("credentials")){
                    if(jsonDataOpen.credentials===true){
                        myLogin.saveSettings();
                        boolLogin=true;
                        sessionToken=jsonDataOpen.sessionToken;
                        listToken=jsonDataOpen.listToken;
                        if (bool403){
                            timerLastCall.start();//deprecate
                        }else{
                            if(bool401){
                                bool401=false;
                                if(boolSession){
                                    timerLastCall.start();//deprecate
                                }else{
                                    luser=setting.user
                                    timerLoadSession.start();
                                }
                            }else{
                                if(boolSession==false){
                                    luser=setting.user
                                    timerLoadSession.start();
                                }
                            }
                        }

                    }else{
                        var erroropen = data.errorString;
                        if(data.status=="200"){
                            erroropen = qsTr("please verify your information");
                        }
                        MessageLib.showMessage(qsTr("failed connection")+": \n"+erroropen, mainroot);
                    }
                }
                boolBlocking=false;
            }


        }
        if(pid==="systemnet"){
            if(option===33){
                MessageLib.showMessageLog(qsTr("error update files qml: ")+JSON.stringify(data),mainroot);
                boolBlocking=false;
            }
            if(option===34){
                MessageLib.showMessageLog(qsTr("error get files from thesamodule, is thesamodule installed on the server?"),mainroot);
                //boolBlocking=false;
            }
            if(option===12){
                MessageLib.showMessageLog(qsTr("this user has no assigned tabs - qml files"),mainroot);
            }
            if(option===13){
                MessageLib.showMessageLog(qsTr("error trying to request qml files"),mainroot);
            }
            if(option===15){
                MessageLib.showMessageLog(qsTr("the folder assigned to this user is empty"),mainroot);
            }
        }

        if(option===2){
            //catch timeout
            var jsonData=data.data;
            if(jsonData.hasOwnProperty("error")){ //catch errors de user
                if(Array.isArray(jsonData.error)){
                    var errores2 = data.errorString+" "+data.reasonPhrase+" "+data.status;
                    if(jsonData.error[0].startsWith('403')){//sessión vencida trytond o acceso denegado( en 5.0 propiedad errada)
                        boolLogin=false;
                        // the session is boolSession=true
                        //save last call
                        if(boolSession){
                            QJsonNetworkQml.saveLastCall();
                            bool403=true;
                        }
                    }else{
                        if(jsonData.error[0].startsWith('401')){//Authorization Required
                            MessageLib.showMessage(qsTr("Authorization Required")+": \n"+errores2, mainroot);
                            boolLogin=false;
                            bool401=true;
                            if(boolSession){
                                QJsonNetworkQml.saveLastCall();
                            }
                        }else{
                            if(jsonData.error[0] == "UserError"){
                                MessageLib.showMessageLog("error: "+JSON.stringify(jsonData.error[1][0]),mainroot);
                            }else{
                                MessageLib.showMessageLog("error: "+JSON.stringify(jsonData.error),mainroot);
                            }
                        }
                    }
                }

            }
            if(pid!="open@"){
                boolBlocking=false;
            }
        }
        if(option===3){
            boolLogin=false;//por ahora asi
            var errores3 = data.errorString+" "+data.reasonPhrase+" "+data.status;
            if(data.status===""){
                errores3 += "\n"+qsTr("No connection to server");
            }
            if(pid==="open@"){
                //"open@" 3 QJsonObject({"reasonPhrase":"Bad Request","status":"400"})
                MessageLib.showMessage(errores3, mainroot);
            }else{
                //data.status =="403"-> 5.0 distinta a 4
                //"reasonPhrase":"FORBIDDEN","status":"403"
                MessageLib.showMessage(qsTr("Failed to connect")+": \n"+errores3, mainroot);
            }
            boolBlocking=false;

        }
        if(option ===4){
            MessageLib.showMessage("Error no document json",mainroot);
            boolBlocking=false;
        }
        if(option ===7){
            MessageLib.showMessage(qsTr("Error generating report"),mainroot);
            boolBlocking=false;
        }


    }

    //    MessageDialog {
    //        id: messageErrorExit
    //        title: "Mensaje"
    //        visible:false
    //        onAccepted: {
    //            boolLogin=false;
    //        }

    //    }
    property alias aliasBackground: background.source
    Item {
        //width: parent.width
        anchors.fill: parent
        visible: setting.boolBackground
        Image {
            id: background
            anchors.fill: parent
            asynchronous: true
            cache: false
            onStatusChanged: if(background.status == Image.Error){errorBackg()}
            fillMode: Image.PreserveAspectCrop
            smooth: true
        }
        Image {
            width: 36
            anchors{right: parent.right;rightMargin: 20; bottom: parent.bottom;bottomMargin: 20}
            asynchronous: true
            cache: false
            source: "images/login64.png"
            onStatusChanged: if(status == Image.Error){}
            fillMode: Image.PreserveAspectFit
            smooth: true
        }
    }
    property bool boolBack: setting.boolBackground
    Timer{
        id:tbackground
        interval: 100
        onTriggered: {
            swicheBack.checked=setting.boolBackground;
            aliasBackground = "images/back.jpg";
            myLogin.aliasBackground = "images/back.jpg";
            //if(setting.typesysmodule){
                if(Tools.fileExists(DirParent+"/"+dirSystem+"/back.jpg")){
                    aliasBackground = "file:///"+DirParent+"/"+dirSystem+"/back.jpg";
                    myLogin.aliasBackground = "file:///"+DirParent+"/"+dirSystem+"/back.jpg";
                }
            //}
        }
    }

    function errorBackg(){
        MessageLib.showMessage(qsTr("Background Image Is Damaged"), mainroot);
    }
    ListModel{
        id:blankModel
    }

    Timer{
        id:tactionCacheOnCompleted
        interval:400
        onTriggered: {SystemNet.actionCacheOnCompleted();}
    }

    function finditemsTabs(ite){
        var result=[];
        for(var i = 0, len=ite.length;i<len;i++){
            var result2 = [];
            if(typeof ite[i].type !== "undefined"){
                if(ite[i].type==="tab"){
                    result.push(ite[i]);
                }
            }
            if(ite[i].children.length>0){
                result2 = finditemsTabs(ite[i].children);
                result=result.concat(result2);
            }
        }
        return result;
    }

    property var  itemsTabs: []

    function checkClosable(){
        // if in tab property isPreClosing is true: a function must be defined with the name preClosing
        //      example
        //      function preClosing(){
        //         .....
        //         .....
        //         .....
        //      }
        if(container.desktop !== null){
            if(container.desktop.children!=="undefined"){
                var items = finditemsTabs(container.desktop.children);
                for(var i = 0, len=items.length;i<len;i++){
                    if(items[i].isPreClosing===true){
                        if(typeof items[i].preClosing !== "undefined"){
                            try {
                              items[i].preClosing();//warning: must be synchronous
                            } catch (error) {
                              console.log(error);
                              MessageLib.showMessage(qsTr("error preClosing Tab: ")+error, mainroot);
                            }

                        }
                    }
                }
            }
        }
        return true;
    }

    RowLayout {
        id: container
        anchors.fill: parent
        spacing: 0
        //Component.onCompleted: {createMenu()}
        property QtObject desktop
        property QtObject component1
        property QtObject component2
        property QtObject menumodel
        function modelblank(){
            menulistdrawer.aliasmodel=blankModel;
            menulist.aliasmodel=blankModel;
        }

        function createMenuComponents(){

            if(setting.typesysmodule){
                component1 = Qt.createComponent("file:///"+DirParent+"/"+dirSystem+"/MenuModel.qml");
            }else{
                if(boolqrclocal){
                    component1 = Qt.createComponent(dirSystem+"/MenuModel.qml");
                }else{
                    component1 = Qt.createComponent("file:///"+DirParent+"/"+dirSystem+"/MenuModel.qml");
                }
            }

            menumodel = component1.createObject(container);

            if (menumodel == null) {
                // Error Handling
                MessageLib.showMessage(qsTr("error loading side menu: ")+component1.errorString(), mainroot);
                container.modelblank();
            }else{
                if(boolDrawer){
                    menulistdrawer.aliasmodel=menumodel
                }else{
                    menulist.aliasmodel=menumodel
                }
            }
            if(setting.typesysmodule){
                component2 = Qt.createComponent("file:///"+DirParent+"/"+dirSystem+"/Desktop.qml");
            }else{
                if(boolqrclocal){
                    component2 = Qt.createComponent(dirSystem+"/Desktop.qml");
                }else{
                    component2 = Qt.createComponent("file:///"+DirParent+"/"+dirSystem+"/Desktop.qml");
                }
            }

            desktop = component2.createObject(container);

            if (desktop == null) {
                // Error Handling
                MessageLib.showMessageLog(qsTr("error loading desktop: ")+component2.errorString(), mainroot);
            }else{
                if(setting.typesysmodule){
                    tactionCacheOnCompleted.start();
                }

            }

        }
        Drawer{
            id:menudrawer
            width: boolDrawer?80:0
            height: mainroot.height
            //visible: boolDrawer
            MenuList{
                id:menulistdrawer
                anchors.fill: parent
                focus: true
                //KeyNavigation.tab: container.desktop
                onSignalSelectPanel: {
                    if (container.desktop!=null){
                        container.desktop.currentIndex=index;
                    }
                }
            }
        }
        MenuList{
            id:menulist
            visible: !boolDrawer
            Layout.minimumWidth: boolDrawer?0:80
            Layout.maximumWidth: boolDrawer?0:80
            Layout.fillWidth: true
            Layout.fillHeight: true
            focus: true
            //KeyNavigation.tab: container.desktop
            onSignalSelectPanel: {
                if (container.desktop!=null){
                    container.desktop.currentIndex=index;
                }
            }
        }

    }

    FontLoader{
        id:fawesome
        source: "fonts/Font Awesome 5 Free-Solid-900.otf" // version 5.13 desktop
        //https://fontawesome.com/how-to-use/on-the-desktop/setup/getting-started
        //https://fontawesome.com/cheatsheet/free/solid
    }
    FontLoader{
        id:finglobal
        source: "fonts/inglobali.ttf"
    }

    property bool boolBlocking: false
    property string textBlocking: qsTr("Wait...")
    Timer{
        id:timerBlockingFalse
        interval: 300
        onTriggered: boolBlocking=false;
    }
    onBoolBlockingChanged: {
        if(boolBlocking==true){
            tblockingStop.restart();
        }else{
            tblockingStop.stop();
        }
    }
    Timer{//timer en caso de que no haya respuestas, por error de codigo o por servidor demorado
        id:tblockingStop
        interval: maxIntervalBusy// 30000 = 30 seconds MODIFICAR EN CASO DE DEMASIADA ESPERA EN ALGUN CALCULO
        onTriggered: {
            boolBlocking=false;
            //Ocurrió algún Error, el tiempo de espera se Agotó, No Hay Comunicación o Respuestas.
            MessageLib.showMessage(qsTr("Timeout, maybe an error occurred."),mainroot);
        }
    }
    function openBusy(){
        timerBlockingFalse.stop();
        boolBlocking=true;
    }
    function clearMessages(){
        ObjectMessageLast.clearMessages();//prevent repetitions of warnings
    }

    function closeBusy(){
        timerBlockingFalse.restart();
    }
    Dialog{
        id:diblock
        modal: true
        //anchors.centerIn: parent
        x: (parent.width - width) / 2
        y: (parent.height - (height))/ 2
        width: 240
        height: 120
        visible: boolBlocking
        closePolicy: Dialog.NoAutoClose
        contentItem: Row{
            anchors{fill: parent; margins: 4}
            spacing: 0
            Item{
                width: 20
                height: 1
            }
            BusyIndicator{
                id:busy1
                anchors.verticalCenter: parent.verticalCenter
            }
            Item{
                width: 20
                height: 1
            }
            Text{
                text: textBlocking
                width: parent.width - busy1.width-40
                height: parent.height
                font.bold: true
                wrapMode: Text.Wrap
                color: mainroot.Material.primaryTextColor
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
            }
        }

    }
    Login{
        id:myLogin
        visible:!boolLogin
    }

    function formatDecimalNew(texto){//only qt 5.13 up
        return Number(texto).toLocaleString(Qt.locale(planguage));
    }

    function formatDecimal(numero){
        return formatDecimalPlaces(numero,2);
    }

    function formatNumeric(numero){
        return formatDecimalPlaces(numero,0);
    }

    function formatDecimalPlaces(value, mplaces){
        var number = parseFloat(value);
        if (isNaN(number)){
            number = 0;
        }
        var places = mplaces;
        var symbol = ""; //$
        var thousand =  thousands_sep;
        var decimal = decimal_point;
        var negative = number < 0 ? "-" : "",
        i = parseInt(number = Math.abs(+number || 0).toFixed(places), 10) + "",
        j = (j = i.length) > 3 ? j % 3 : 0;
        return symbol + negative + (j ? i.substr(0, j) + thousand : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + thousand) + (places ? decimal + Math.abs(number - i).toFixed(places).slice(2) : "");
    }
    function formatCentUp(numero){
        return formatCentUpPlaces(numero,2);
    }

    function formatCentUpPlaces(numero, mplaces){
        var boolUpCentavos = true;
        var sizeUpcentavos = 1;
        var listt = formatDecimalPlaces(numero, mplaces).split(decimal_point);
        if(listt.length>1){
            return listt[0] + decimal_point + "<font size=" + "'" + sizeUpcentavos + "'" + ">" + listt[1] + "</font>";
        }else{
            return formatDecimalPlaces(numero, mplaces);
        }
    }

    function dateTimeFromSchema(dateSchema){
        if(dateSchema==null){
            return null;
        }
        if(dateSchema.hasOwnProperty("__class__") && dateSchema.hasOwnProperty("year")){
            if(dateSchema.__class__==="date"){
                return new Date(dateSchema.year, dateSchema.month-1, dateSchema.day);
            }else{
                return new Date(dateSchema.year, dateSchema.month-1, dateSchema.day, dateSchema.hour, dateSchema.minute, dateSchema.second);
            }
        }
        return "";
    }

    function formatDateTime(date, format){
        return Qt.formatDateTime(date, format);
    }

    function dateSchemaFromDate(date){
        if(date==null){
            return null;
        }
        return {'__class__': 'date',
            'year': date.getFullYear(),
            'month': date.getMonth()+1,
            'day': date.getDate()}
    }

    function dateSchema(year, month, day){
        return {'__class__': 'date',
            'year': year,
            'month': month,
            'day': day}
    }

    function decimalSchema(value){
        if(value==null){
            return null;
        }
        return {'__class__': 'Decimal','decimal':value.toString()}
    }

    function decimalFromSchema(decimalSchema){
        if(decimalSchema==null){
            return null;
        }
        if(decimalSchema.hasOwnProperty("__class__") && decimalSchema.hasOwnProperty("decimal")){
            if(decimalSchema.__class__==="Decimal"){
                return decimalSchema.decimal;
            }
        }
        return "";
    }


    Timer{
        id:timerLastCall
        interval: 200
        onTriggered: {
            boolBlocking=true;
            //con callDirect y secuencias y  function no se puede bien x ahora
            QJsonNetworkQml.runLastCall();
            bool403=false;
            timerBlockingFalse.start();
        }
    }

    Timer{
        id:timerLoadSession
        interval: 200
        onTriggered: {
            boolBlocking=true;
            getPreferences();
            var boolUpdateSystemNet = false;
            if(setting.typesysmodule){
                boolUpdateSystemNet = updateSystemNet();
            }
            tbackground.start();
            Tools.selectSystemTranslation(setting.translate, setting.typesysmodule);
            if(setting.typesysmodule){
                if(boolUpdateSystemNet){
                    createMenuDesktop();
                }else{
                    container.modelblank();
                }
            }else{
                createMenuDesktop();
            }
            boolSession=true;
            //add model generic
            ModelManagerQml.addModel("ModelGeneric","ProxyModelGeneric");
            //clear cache tools
            Tools.clearCache();
            //close blocking
            timerBlockingFalse.start();
        }
    }

    function contextPreferences(context){
        return Object.assign(JSON.parse(JSON.stringify(preferences)), context)
    }

    function getPreferences(){
        var data =QJsonNetworkQml.callDirect("getPreferences","model.res.user.get_preferences",
                                             [true,{}]);
        if(data.data!=="error"){
            preferences = data.data.result;
            if(preferences.hasOwnProperty("locale")){
                thousands_sep=preferences.locale.thousands_sep;
                decimal_point=preferences.locale.decimal_point;
            }
            QJsonNetworkQml.setPreferences(preferences);
            if(preferences.language!==null){
                planguage=preferences.language;
                nameShortDays= Tools.calendarShortNamesDays(planguage);
                nameLongMonths= Tools.calendarLongNamesMonths(planguage);
            }
            data = QJsonNetworkQml.callDirect("getPreferences","model.res.user.get_preferences",
                                              [false,preferences]);
            if(data.data!=="error"){
                preferencesAll = data.data.result;
                psignature=preferencesAll.name;
                myCompany=preferencesAll["company.rec_name"];
            }
        }
    }

    function createMenuDesktop(){
        //create entorno
        container.createMenuComponents();
        if(boolDrawer){
            menudrawer.open();
        }
    }

    function updateSystemNet(){
        return SystemNet.rechargeNet(preferences, preferencesAll.name);
    }
    function _messageWarningPySide(){
            //last call 403 function with arguments
            //for PySide2 12, by bug no macro Q_ARG
            messageWarning(argsFucntionLastCall[0]);
            argsFucntionLastCall=[];//clear
            QJsonNetworkQml.forceNotRun();
        }
    function _forceNotRun(){
        QJsonNetworkQml.forceNotRun();
    }

    function messageWarning(msg){
        MessageLib.showMessageLog(msg,mainroot);
    }
    function _getNewNumber(){
        _intCountModels+=1;
        return _intCountModels;
    }

    function getId(){
        mid+=1;
        return mid;
    }

    function prepareParamsLocal(method, params){
            var newid = getId();
            return {"method": method,
                "params": params,
                "id": newid}
        }

    function getUrl(){
        var murl = setting.host+":"+setting.port+"/";
        if(murl==""){
            var re_murl = Misc.getUrlTryton();
            if(re_murl=="" || re_murl==null || re_murl=="undefined"){
                MessageLib.showMessage("Url error", mainroot);
                murl = "";
            }else{
                murl = re_murl;
            }
        }

        return murl + setting.dbase + "/";
    }

    function getHttpRequest(url, params, method){
        var http = new XMLHttpRequest();
        http.open("POST", url, true);
        http.withCredentials=true;
        //"User-Agent", "Mozilla/5.0 (X11; Linux x86_64; rv:99.0) Gecko/20100101 Firefox/99.0")
        //        http.setRequestHeader('Content-type', 'application/json; charset=utf-8');
        //        http.setRequestHeader("Content-length", params.length);
        //        http.setRequestHeader("Connection", "close");
        http.setRequestHeader("Content-type", "application/json");
        if(method!=methodLogin){
            http.setRequestHeader('Authorization', sessionToken);
        }
        return http;
    }

    function analizeErrorsStatus(status){
        MessageLib.showMessage("error: "+status,mainroot);
    }

    function analizeErrors(response){
        if(response.hasOwnProperty("error")){
//            console.log("wsi", JSON.stringify(response));
            var error = response["error"];
            if(error[0].startsWith("403")){

                boolLogin=false;
                if(boolSession){

                    bool403=true;
                }
            }else{
                if(error[0].startsWith('401')){//Authorization Required
                    MessageLib.showMessage("Autorización Requerida, status: 401", mainroot);
                    boolLogin=false;
                    bool401=true;
                    if(boolSession){
                        //                        QJsonNetworkQml.saveLastCall();
                    }
                }else{
                    if(error[0] == "UserError"){
                        MessageLib.showMessageLog("error: "+JSON.stringify(error[1][0]),mainroot);
                    }else{
                        if(error[0] == "ConcurrencyException"){
                            MessageLib.showMessageLog("error:\n Error de concurrencia, Este registro ha sido modificado mientras lo editaba, por favor actualice el registro antes de guardar",mainroot);
                        }else{
                            var info_error = error[0];
                            var trace = error[1]!="undefined"?error[1]:"";
                            MessageLib.showMessageLog("error:\n "+info_error+"\n\n"+trace,mainroot);
                        }
                    }
                }
            }
        }

    }
    Settings {
        id: setting
        //property string style: "Default"
        property string host: "http://localhost"
        property string port: "8000"
        property string dbase: "tryton"
        property string user: "admin"
        property string generalLetter: finglobal.name
        property string style: "Material"
        property int theme: Material.Dark
        property color accent: "#41cd52"
        property color primary: "#41cd52"
        property bool boolBackground: true
        property int typelogin: 1//"4":0,"5":1
        property bool typesysmodule: false//"local":false, "module":true
        property bool boolDrawer: false
        property string translate
    }


    Dialog {
        id:dabout
        // title: qsTr("about")
        //standardButtons: Dialog.Ok
        closePolicy: Dialog.NoAutoClose
        //anchors.centerIn: parent
        x: (parent.width - width) / 2
        y: (parent.height - (height))/ 2
        Label {
            textFormat: Label.RichText
            text: "<b><center><h2>Thesa "+ThesaVersion+"</h2><br>tryton client qt-qml</b><br>Copyright (C) 2020-2021 Numael Garay <br><br>
                    <b><a href=\"https://github.com/numaelis/thesa\">https://github.com/numaelis/thesa</a><b></center>"
            onLinkActivated: Qt.openUrlExternally("https://github.com/numaelis/thesa")
            Image {
                width: 36
                anchors{right: parent.right;rightMargin: 12; top: parent.top;topMargin: 4}
                asynchronous: true
                cache: false
                source: "images/login64.png"
                onStatusChanged: if(status == Image.Error){}
                fillMode: Image.PreserveAspectFit
                smooth: true
            }
        }

        footer: ToolBar {
            id:mtb
            implicitHeight: 44
            background: Rectangle {
                width: mtb.width
                height: mtb.height
                color: "transparent"//diLogin.Material.background
            }
            RowLayout {
                anchors{right: parent.right;rightMargin: 8}
                height: parent.height
                spacing: 8

                ToolButton {
                    id:bcredit
                    text: qsTr("Credits")
                    implicitHeight: 36
                    onClicked: {
                        dcredits.open();
                    }
                    contentItem: Text {
                        text: bcredit.text
                        font: bcredit.font
                        opacity: enabled ? 1.0 : 0.3
                        color: mainroot.Material.accent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                }
                ToolButton {
                    id:blicense
                    text: qsTr("License")
                    implicitHeight: 36
                    onClicked: {
                        dlicense.open();
                    }
                    contentItem: Text {
                        text: blicense.text
                        font: blicense.font
                        opacity: enabled ? 1.0 : 0.3
                        color: mainroot.Material.accent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                }
                ToolButton {
                    id:baok
                    text: qsTr("Ok")
                    implicitHeight: 36
                    onClicked: {
                        dabout.accept();
                    }
                    contentItem: Text {
                        text: baok.text
                        font: baok.font
                        opacity: enabled ? 1.0 : 0.3
                        color: mainroot.Material.accent//control.down ? "#17a81a" : "#21be2b"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                }
            }
        }

    }
    Dialog {
        id:dquestionclose
        standardButtons: Dialog.Ok|Dialog.Cancel
        width: 250
        height: 200
        //title: "close"
        closePolicy: Dialog.NoAutoClose
        //anchors.centerIn: parent
        x: (parent.width - width) / 2
        y: (parent.height - (height))/ 2
        onAccepted: preThesaClosing();
        modal: true
        Label {
            anchors.centerIn: parent
            textFormat: Label.RichText
            font.pixelSize: 20
            font.bold: true
            color: mainroot.Material.accent
            text: qsTr("¿Close thesa?")
        }
    }
    Dialog {
        id:dcredits
        standardButtons: Dialog.Ok
        closePolicy: Dialog.NoAutoClose
        //anchors.centerIn: parent
        x: (parent.width - width) / 2
        y: (parent.height - (height))/ 2
        Label {
            textFormat: Label.RichText
            text: "<b><center><h2>Credits</h2></b><br>Numael Garay -  mantrixsoft@gmail.com<br><br></center>"
        }
    }
    Dialog {
        id:dlicense
        implicitWidth: boolShortWidth135?parent.width-10:620
        implicitHeight: mainroot.height-20
        title: "License"
        standardButtons: Dialog.Ok
        closePolicy: Dialog.NoAutoClose
        //anchors.centerIn: parent
        x: (parent.width - width) / 2
        y: (parent.height - (height))/ 2
        contentItem: Pane{
            ScrollView{
                clip:true
                anchors.fill: parent
                ScrollBar.vertical.policy: ScrollBar.AlwaysOn
                TextArea {
                    id: areaText
                    implicitWidth: parent.width
                    clip: true
                    text: licenseGPL
                    onTextChanged: {
                        positionAt(0,0)
                    }

                    readOnly: true
                    selectByMouse: false
                    wrapMode: Text.Wrap
                    font.bold: true
                    padding: 4
                }
            }
        }
    }


    property string licenseGPL:"GNU GENERAL PUBLIC LICENSE
                       Version 3, 29 June 2007

 Copyright (C) 2007 Free Software Foundation, Inc. <http://fsf.org/>
 Everyone is permitted to copy and distribute verbatim copies
 of this license document, but changing it is not allowed.

                            Preamble

  The GNU General Public License is a free, copyleft license for
software and other kinds of works.

  The licenses for most software and other practical works are designed
to take away your freedom to share and change the works.  By contrast,
the GNU General Public License is intended to guarantee your freedom to
share and change all versions of a program--to make sure it remains free
software for all its users.  We, the Free Software Foundation, use the
GNU General Public License for most of our software; it applies also to
any other work released this way by its authors.  You can apply it to
your programs, too.

  When we speak of free software, we are referring to freedom, not
price.  Our General Public Licenses are designed to make sure that you
have the freedom to distribute copies of free software (and charge for
them if you wish), that you receive source code or can get it if you
want it, that you can change the software or use pieces of it in new
free programs, and that you know you can do these things.

  To protect your rights, we need to prevent others from denying you
these rights or asking you to surrender the rights.  Therefore, you have
certain responsibilities if you distribute copies of the software, or if
you modify it: responsibilities to respect the freedom of others.

  For example, if you distribute copies of such a program, whether
gratis or for a fee, you must pass on to the recipients the same
freedoms that you received.  You must make sure that they, too, receive
or can get the source code.  And you must show them these terms so they
know their rights.

  Developers that use the GNU GPL protect your rights with two steps:
(1) assert copyright on the software, and (2) offer you this License
giving you legal permission to copy, distribute and/or modify it.

  For the developers\' and authors\' protection, the GPL clearly explains
that there is no warranty for this free software.  For both users\' and
authors\' sake, the GPL requires that modified versions be marked as
changed, so that their problems will not be attributed erroneously to
authors of previous versions.

  Some devices are designed to deny users access to install or run
modified versions of the software inside them, although the manufacturer
can do so.  This is fundamentally incompatible with the aim of
protecting users\' freedom to change the software.  The systematic
pattern of such abuse occurs in the area of products for individuals to
use, which is precisely where it is most unacceptable.  Therefore, we
have designed this version of the GPL to prohibit the practice for those
products.  If such problems arise substantially in other domains, we
stand ready to extend this provision to those domains in future versions
of the GPL, as needed to protect the freedom of users.

  Finally, every program is threatened constantly by software patents.
States should not allow patents to restrict development and use of
software on general-purpose computers, but in those that do, we wish to
avoid the special danger that patents applied to a free program could
make it effectively proprietary.  To prevent this, the GPL assures that
patents cannot be used to render the program non-free.

  The precise terms and conditions for copying, distribution and
modification follow.

                       TERMS AND CONDITIONS

  0. Definitions.

  \"This License\" refers to version 3 of the GNU General Public License.

  \"Copyright\" also means copyright-like laws that apply to other kinds of
works, such as semiconductor masks.

  \"The Program\" refers to any copyrightable work licensed under this
License.  Each licensee is addressed as \"you\".  \"Licensees\" and
\"recipients\" may be individuals or organizations.

  To \"modify\" a work means to copy from or adapt all or part of the work
in a fashion requiring copyright permission, other than the making of an
exact copy.  The resulting work is called a \"modified version\" of the
earlier work or a work \"based on\" the earlier work.

  A \"covered work\" means either the unmodified Program or a work based
on the Program.

  To \"propagate\" a work means to do anything with it that, without
permission, would make you directly or secondarily liable for
infringement under applicable copyright law, except executing it on a
computer or modifying a private copy.  Propagation includes copying,
distribution (with or without modification), making available to the
public, and in some countries other activities as well.

  To \"convey\" a work means any kind of propagation that enables other
parties to make or receive copies.  Mere interaction with a user through
a computer network, with no transfer of a copy, is not conveying.

  An interactive user interface displays \"Appropriate Legal Notices\"
to the extent that it includes a convenient and prominently visible
feature that (1) displays an appropriate copyright notice, and (2)
tells the user that there is no warranty for the work (except to the
extent that warranties are provided), that licensees may convey the
work under this License, and how to view a copy of this License.  If
the interface presents a list of user commands or options, such as a
menu, a prominent item in the list meets this criterion.

  1. Source Code.

  The \"source code\" for a work means the preferred form of the work
for making modifications to it.  \"Object code\" means any non-source
form of a work.

  A \"Standard Interface\" means an interface that either is an official
standard defined by a recognized standards body, or, in the case of
interfaces specified for a particular programming language, one that
is widely used among developers working in that language.

  The \"System Libraries\" of an executable work include anything, other
than the work as a whole, that (a) is included in the normal form of
packaging a Major Component, but which is not part of that Major
Component, and (b) serves only to enable use of the work with that
Major Component, or to implement a Standard Interface for which an
implementation is available to the public in source code form.  A
\"Major Component\", in this context, means a major essential component
(kernel, window system, and so on) of the specific operating system
(if any) on which the executable work runs, or a compiler used to
produce the work, or an object code interpreter used to run it.

  The \"Corresponding Source\" for a work in object code form means all
the source code needed to generate, install, and (for an executable
work) run the object code and to modify the work, including scripts to
control those activities.  However, it does not include the work\'s
System Libraries, or general-purpose tools or generally available free
programs which are used unmodified in performing those activities but
which are not part of the work.  For example, Corresponding Source
includes interface definition files associated with source files for
the work, and the source code for shared libraries and dynamically
linked subprograms that the work is specifically designed to require,
such as by intimate data communication or control flow between those
subprograms and other parts of the work.

  The Corresponding Source need not include anything that users
can regenerate automatically from other parts of the Corresponding
Source.

  The Corresponding Source for a work in source code form is that
same work.

  2. Basic Permissions.

  All rights granted under this License are granted for the term of
copyright on the Program, and are irrevocable provided the stated
conditions are met.  This License explicitly affirms your unlimited
permission to run the unmodified Program.  The output from running a
covered work is covered by this License only if the output, given its
content, constitutes a covered work.  This License acknowledges your
rights of fair use or other equivalent, as provided by copyright law.

  You may make, run and propagate covered works that you do not
convey, without conditions so long as your license otherwise remains
in force.  You may convey covered works to others for the sole purpose
of having them make modifications exclusively for you, or provide you
with facilities for running those works, provided that you comply with
the terms of this License in conveying all material for which you do
not control copyright.  Those thus making or running the covered works
for you must do so exclusively on your behalf, under your direction
and control, on terms that prohibit them from making any copies of
your copyrighted material outside their relationship with you.

  Conveying under any other circumstances is permitted solely under
the conditions stated below.  Sublicensing is not allowed; section 10
makes it unnecessary.

  3. Protecting Users\' Legal Rights From Anti-Circumvention Law.

  No covered work shall be deemed part of an effective technological
measure under any applicable law fulfilling obligations under article
11 of the WIPO copyright treaty adopted on 20 December 1996, or
similar laws prohibiting or restricting circumvention of such
measures.

  When you convey a covered work, you waive any legal power to forbid
circumvention of technological measures to the extent such circumvention
is effected by exercising rights under this License with respect to
the covered work, and you disclaim any intention to limit operation or
modification of the work as a means of enforcing, against the work\'s
users, your or third parties\' legal rights to forbid circumvention of
technological measures.

  4. Conveying Verbatim Copies.

  You may convey verbatim copies of the Program\'s source code as you
receive it, in any medium, provided that you conspicuously and
appropriately publish on each copy an appropriate copyright notice;
keep intact all notices stating that this License and any
non-permissive terms added in accord with section 7 apply to the code;
keep intact all notices of the absence of any warranty; and give all
recipients a copy of this License along with the Program.

  You may charge any price or no price for each copy that you convey,
and you may offer support or warranty protection for a fee.

  5. Conveying Modified Source Versions.

  You may convey a work based on the Program, or the modifications to
produce it from the Program, in the form of source code under the
terms of section 4, provided that you also meet all of these conditions:

    a) The work must carry prominent notices stating that you modified
    it, and giving a relevant date.

    b) The work must carry prominent notices stating that it is
    released under this License and any conditions added under section
    7.  This requirement modifies the requirement in section 4 to
    \"keep intact all notices\".

    c) You must license the entire work, as a whole, under this
    License to anyone who comes into possession of a copy.  This
    License will therefore apply, along with any applicable section 7
    additional terms, to the whole of the work, and all its parts,
    regardless of how they are packaged.  This License gives no
    permission to license the work in any other way, but it does not
    invalidate such permission if you have separately received it.

    d) If the work has interactive user interfaces, each must display
    Appropriate Legal Notices; however, if the Program has interactive
    interfaces that do not display Appropriate Legal Notices, your
    work need not make them do so.

  A compilation of a covered work with other separate and independent
works, which are not by their nature extensions of the covered work,
and which are not combined with it such as to form a larger program,
in or on a volume of a storage or distribution medium, is called an
\"aggregate\" if the compilation and its resulting copyright are not
used to limit the access or legal rights of the compilation\'s users
beyond what the individual works permit.  Inclusion of a covered work
in an aggregate does not cause this License to apply to the other
parts of the aggregate.

  6. Conveying Non-Source Forms.

  You may convey a covered work in object code form under the terms
of sections 4 and 5, provided that you also convey the
machine-readable Corresponding Source under the terms of this License,
in one of these ways:

    a) Convey the object code in, or embodied in, a physical product
    (including a physical distribution medium), accompanied by the
    Corresponding Source fixed on a durable physical medium
    customarily used for software interchange.

    b) Convey the object code in, or embodied in, a physical product
    (including a physical distribution medium), accompanied by a
    written offer, valid for at least three years and valid for as
    long as you offer spare parts or customer support for that product
    model, to give anyone who possesses the object code either (1) a
    copy of the Corresponding Source for all the software in the
    product that is covered by this License, on a durable physical
    medium customarily used for software interchange, for a price no
    more than your reasonable cost of physically performing this
    conveying of source, or (2) access to copy the
    Corresponding Source from a network server at no charge.

    c) Convey individual copies of the object code with a copy of the
    written offer to provide the Corresponding Source.  This
    alternative is allowed only occasionally and noncommercially, and
    only if you received the object code with such an offer, in accord
    with subsection 6b.

    d) Convey the object code by offering access from a designated
    place (gratis or for a charge), and offer equivalent access to the
    Corresponding Source in the same way through the same place at no
    further charge.  You need not require recipients to copy the
    Corresponding Source along with the object code.  If the place to
    copy the object code is a network server, the Corresponding Source
    may be on a different server (operated by you or a third party)
    that supports equivalent copying facilities, provided you maintain
    clear directions next to the object code saying where to find the
    Corresponding Source.  Regardless of what server hosts the
    Corresponding Source, you remain obligated to ensure that it is
    available for as long as needed to satisfy these requirements.

    e) Convey the object code using peer-to-peer transmission, provided
    you inform other peers where the object code and Corresponding
    Source of the work are being offered to the general public at no
    charge under subsection 6d.

  A separable portion of the object code, whose source code is excluded
from the Corresponding Source as a System Library, need not be
included in conveying the object code work.

  A \"User Product\" is either (1) a \"consumer product\", which means any
tangible personal property which is normally used for personal, family,
or household purposes, or (2) anything designed or sold for incorporation
into a dwelling.  In determining whether a product is a consumer product,
doubtful cases shall be resolved in favor of coverage.  For a particular
product received by a particular user, \"normally used\" refers to a
typical or common use of that class of product, regardless of the status
of the particular user or of the way in which the particular user
actually uses, or expects or is expected to use, the product.  A product
is a consumer product regardless of whether the product has substantial
commercial, industrial or non-consumer uses, unless such uses represent
the only significant mode of use of the product.

  \"Installation Information\" for a User Product means any methods,
procedures, authorization keys, or other information required to install
and execute modified versions of a covered work in that User Product from
a modified version of its Corresponding Source.  The information must
suffice to ensure that the continued functioning of the modified object
code is in no case prevented or interfered with solely because
modification has been made.

  If you convey an object code work under this section in, or with, or
specifically for use in, a User Product, and the conveying occurs as
part of a transaction in which the right of possession and use of the
User Product is transferred to the recipient in perpetuity or for a
fixed term (regardless of how the transaction is characterized), the
Corresponding Source conveyed under this section must be accompanied
by the Installation Information.  But this requirement does not apply
if neither you nor any third party retains the ability to install
modified object code on the User Product (for example, the work has
been installed in ROM).

  The requirement to provide Installation Information does not include a
requirement to continue to provide support service, warranty, or updates
for a work that has been modified or installed by the recipient, or for
the User Product in which it has been modified or installed.  Access to a
network may be denied when the modification itself materially and
adversely affects the operation of the network or violates the rules and
protocols for communication across the network.

  Corresponding Source conveyed, and Installation Information provided,
in accord with this section must be in a format that is publicly
documented (and with an implementation available to the public in
source code form), and must require no special password or key for
unpacking, reading or copying.

  7. Additional Terms.

  \"Additional permissions\" are terms that supplement the terms of this
License by making exceptions from one or more of its conditions.
Additional permissions that are applicable to the entire Program shall
be treated as though they were included in this License, to the extent
that they are valid under applicable law.  If additional permissions
apply only to part of the Program, that part may be used separately
under those permissions, but the entire Program remains governed by
this License without regard to the additional permissions.

  When you convey a copy of a covered work, you may at your option
remove any additional permissions from that copy, or from any part of
it.  (Additional permissions may be written to require their own
removal in certain cases when you modify the work.)  You may place
additional permissions on material, added by you to a covered work,
for which you have or can give appropriate copyright permission.

  Notwithstanding any other provision of this License, for material you
add to a covered work, you may (if authorized by the copyright holders of
that material) supplement the terms of this License with terms:

    a) Disclaiming warranty or limiting liability differently from the
    terms of sections 15 and 16 of this License; or

    b) Requiring preservation of specified reasonable legal notices or
    author attributions in that material or in the Appropriate Legal
    Notices displayed by works containing it; or

    c) Prohibiting misrepresentation of the origin of that material, or
    requiring that modified versions of such material be marked in
    reasonable ways as different from the original version; or

    d) Limiting the use for publicity purposes of names of licensors or
    authors of the material; or

    e) Declining to grant rights under trademark law for use of some
    trade names, trademarks, or service marks; or

    f) Requiring indemnification of licensors and authors of that
    material by anyone who conveys the material (or modified versions of
    it) with contractual assumptions of liability to the recipient, for
    any liability that these contractual assumptions directly impose on
    those licensors and authors.

  All other non-permissive additional terms are considered \"further
restrictions\" within the meaning of section 10.  If the Program as you
received it, or any part of it, contains a notice stating that it is
governed by this License along with a term that is a further
restriction, you may remove that term.  If a license document contains
a further restriction but permits relicensing or conveying under this
License, you may add to a covered work material governed by the terms
of that license document, provided that the further restriction does
not survive such relicensing or conveying.

  If you add terms to a covered work in accord with this section, you
must place, in the relevant source files, a statement of the
additional terms that apply to those files, or a notice indicating
where to find the applicable terms.

  Additional terms, permissive or non-permissive, may be stated in the
form of a separately written license, or stated as exceptions;
the above requirements apply either way.

  8. Termination.

  You may not propagate or modify a covered work except as expressly
provided under this License.  Any attempt otherwise to propagate or
modify it is void, and will automatically terminate your rights under
this License (including any patent licenses granted under the third
paragraph of section 11).

  However, if you cease all violation of this License, then your
license from a particular copyright holder is reinstated (a)
provisionally, unless and until the copyright holder explicitly and
finally terminates your license, and (b) permanently, if the copyright
holder fails to notify you of the violation by some reasonable means
prior to 60 days after the cessation.

  Moreover, your license from a particular copyright holder is
reinstated permanently if the copyright holder notifies you of the
violation by some reasonable means, this is the first time you have
received notice of violation of this License (for any work) from that
copyright holder, and you cure the violation prior to 30 days after
your receipt of the notice.

  Termination of your rights under this section does not terminate the
licenses of parties who have received copies or rights from you under
this License.  If your rights have been terminated and not permanently
reinstated, you do not qualify to receive new licenses for the same
material under section 10.

  9. Acceptance Not Required for Having Copies.

  You are not required to accept this License in order to receive or
run a copy of the Program.  Ancillary propagation of a covered work
occurring solely as a consequence of using peer-to-peer transmission
to receive a copy likewise does not require acceptance.  However,
nothing other than this License grants you permission to propagate or
modify any covered work.  These actions infringe copyright if you do
not accept this License.  Therefore, by modifying or propagating a
covered work, you indicate your acceptance of this License to do so.

  10. Automatic Licensing of Downstream Recipients.

  Each time you convey a covered work, the recipient automatically
receives a license from the original licensors, to run, modify and
propagate that work, subject to this License.  You are not responsible
for enforcing compliance by third parties with this License.

  An \"entity transaction\" is a transaction transferring control of an
organization, or substantially all assets of one, or subdividing an
organization, or merging organizations.  If propagation of a covered
work results from an entity transaction, each party to that
transaction who receives a copy of the work also receives whatever
licenses to the work the party\'s predecessor in interest had or could
give under the previous paragraph, plus a right to possession of the
Corresponding Source of the work from the predecessor in interest, if
the predecessor has it or can get it with reasonable efforts.

  You may not impose any further restrictions on the exercise of the
rights granted or affirmed under this License.  For example, you may
not impose a license fee, royalty, or other charge for exercise of
rights granted under this License, and you may not initiate litigation
(including a cross-claim or counterclaim in a lawsuit) alleging that
any patent claim is infringed by making, using, selling, offering for
sale, or importing the Program or any portion of it.

  11. Patents.

  A \"contributor\" is a copyright holder who authorizes use under this
License of the Program or a work on which the Program is based.  The
work thus licensed is called the contributor\'s \"contributor version\".

  A contributor\'s \"essential patent claims\" are all patent claims
owned or controlled by the contributor, whether already acquired or
hereafter acquired, that would be infringed by some manner, permitted
by this License, of making, using, or selling its contributor version,
but do not include claims that would be infringed only as a
consequence of further modification of the contributor version.  For
purposes of this definition, \"control\" includes the right to grant
patent sublicenses in a manner consistent with the requirements of
this License.

  Each contributor grants you a non-exclusive, worldwide, royalty-free
patent license under the contributor\'s essential patent claims, to
make, use, sell, offer for sale, import and otherwise run, modify and
propagate the contents of its contributor version.

  In the following three paragraphs, a \"patent license\" is any express
agreement or commitment, however denominated, not to enforce a patent
(such as an express permission to practice a patent or covenant not to
sue for patent infringement).  To \"grant\" such a patent license to a
party means to make such an agreement or commitment not to enforce a
patent against the party.

  If you convey a covered work, knowingly relying on a patent license,
and the Corresponding Source of the work is not available for anyone
to copy, free of charge and under the terms of this License, through a
publicly available network server or other readily accessible means,
then you must either (1) cause the Corresponding Source to be so
available, or (2) arrange to deprive yourself of the benefit of the
patent license for this particular work, or (3) arrange, in a manner
consistent with the requirements of this License, to extend the patent
license to downstream recipients.  \"Knowingly relying\" means you have
actual knowledge that, but for the patent license, your conveying the
covered work in a country, or your recipient\'s use of the covered work
in a country, would infringe one or more identifiable patents in that
country that you have reason to believe are valid.

  If, pursuant to or in connection with a single transaction or
arrangement, you convey, or propagate by procuring conveyance of, a
covered work, and grant a patent license to some of the parties
receiving the covered work authorizing them to use, propagate, modify
or convey a specific copy of the covered work, then the patent license
you grant is automatically extended to all recipients of the covered
work and works based on it.

  A patent license is \"discriminatory\" if it does not include within
the scope of its coverage, prohibits the exercise of, or is
conditioned on the non-exercise of one or more of the rights that are
specifically granted under this License.  You may not convey a covered
work if you are a party to an arrangement with a third party that is
in the business of distributing software, under which you make payment
to the third party based on the extent of your activity of conveying
the work, and under which the third party grants, to any of the
parties who would receive the covered work from you, a discriminatory
patent license (a) in connection with copies of the covered work
conveyed by you (or copies made from those copies), or (b) primarily
for and in connection with specific products or compilations that
contain the covered work, unless you entered into that arrangement,
or that patent license was granted, prior to 28 March 2007.

  Nothing in this License shall be construed as excluding or limiting
any implied license or other defenses to infringement that may
otherwise be available to you under applicable patent law.

  12. No Surrender of Others\' Freedom.

  If conditions are imposed on you (whether by court order, agreement or
otherwise) that contradict the conditions of this License, they do not
excuse you from the conditions of this License.  If you cannot convey a
covered work so as to satisfy simultaneously your obligations under this
License and any other pertinent obligations, then as a consequence you may
not convey it at all.  For example, if you agree to terms that obligate you
to collect a royalty for further conveying from those to whom you convey
the Program, the only way you could satisfy both those terms and this
License would be to refrain entirely from conveying the Program.

  13. Use with the GNU Affero General Public License.

  Notwithstanding any other provision of this License, you have
permission to link or combine any covered work with a work licensed
under version 3 of the GNU Affero General Public License into a single
combined work, and to convey the resulting work.  The terms of this
License will continue to apply to the part which is the covered work,
but the special requirements of the GNU Affero General Public License,
section 13, concerning interaction through a network will apply to the
combination as such.

  14. Revised Versions of this License.

  The Free Software Foundation may publish revised and/or new versions of
the GNU General Public License from time to time.  Such new versions will
be similar in spirit to the present version, but may differ in detail to
address new problems or concerns.

  Each version is given a distinguishing version number.  If the
Program specifies that a certain numbered version of the GNU General
Public License \"or any later version\" applies to it, you have the
option of following the terms and conditions either of that numbered
version or of any later version published by the Free Software
Foundation.  If the Program does not specify a version number of the
GNU General Public License, you may choose any version ever published
by the Free Software Foundation.

  If the Program specifies that a proxy can decide which future
versions of the GNU General Public License can be used, that proxy\'s
public statement of acceptance of a version permanently authorizes you
to choose that version for the Program.

  Later license versions may give you additional or different
permissions.  However, no additional obligations are imposed on any
author or copyright holder as a result of your choosing to follow a
later version.

  15. Disclaimer of Warranty.

  THERE IS NO WARRANTY FOR THE PROGRAM, TO THE EXTENT PERMITTED BY
APPLICABLE LAW.  EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT
HOLDERS AND/OR OTHER PARTIES PROVIDE THE PROGRAM \"AS IS\" WITHOUT WARRANTY
OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE.  THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM
IS WITH YOU.  SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF
ALL NECESSARY SERVICING, REPAIR OR CORRECTION.

  16. Limitation of Liability.

  IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MODIFIES AND/OR CONVEYS
THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY
GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE
USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED TO LOSS OF
DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD
PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER PROGRAMS),
EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

  17. Interpretation of Sections 15 and 16.

  If the disclaimer of warranty and limitation of liability provided
above cannot be given local legal effect according to their terms,
reviewing courts shall apply local law that most closely approximates
an absolute waiver of all civil liability in connection with the
Program, unless a warranty or assumption of liability accompanies a
copy of the Program in return for a fee.

                     END OF TERMS AND CONDITIONS

            How to Apply These Terms to Your New Programs

  If you develop a new program, and you want it to be of the greatest
possible use to the public, the best way to achieve this is to make it
free software which everyone can redistribute and change under these terms.

  To do so, attach the following notices to the program.  It is safest
to attach them to the start of each source file to most effectively
state the exclusion of warranty; and each file should have at least
the \"copyright\" line and a pointer to where the full notice is found.

    <one line to give the program\'s name and a brief idea of what it does.>
    Copyright (C) <year>  <name of author>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

Also add information on how to contact you by electronic and paper mail.

  If the program does terminal interaction, make it output a short
notice like this when it starts in an interactive mode:

    <program>  Copyright (C) <year>  <name of author>
    This program comes with ABSOLUTELY NO WARRANTY; for details type `show w\'.
    This is free software, and you are welcome to redistribute it
    under certain conditions; type `show c\' for details.

The hypothetical commands `show w\' and `show c\' should show the appropriate
parts of the General Public License.  Of course, your program\'s commands
might be different; for a GUI interface, you would use an \"about box\".

  You should also get your employer (if you work as a programmer) or school,
if any, to sign a \"copyright disclaimer\" for the program, if necessary.
For more information on this, and how to apply and follow the GNU GPL, see
<http://www.gnu.org/licenses/>.

  The GNU General Public License does not permit incorporating your program
into proprietary programs.  If your program is a subroutine library, you
may consider it more useful to permit linking proprietary applications with
the library.  If this is what you want to do, use the GNU Lesser General
Public License instead of this License.  But first, please read
<http://www.gnu.org/philosophy/why-not-lgpl.html>.";
}
