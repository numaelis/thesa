//this file is part the thesa: tryton client based PySide2(qml2)
// template One2Many
//__author__ = "Numael Garay"
//__copyright__ = "Copyright 2020-2021"
//__license__ = "GPL"
//__version__ = "1.0.0b"
//__maintainer__ = "Numael Garay"
//__email__ = "mantrixsoft@gmail.com"

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15
import "../thesatools"
import "../TrytonControls"

Pane{
    id:templateO2M
    property bool tryton: true
    property string labelAlias: ""
    property string fieldName: ""
    property string fieldOne2Many: ""
    property string type: "one2many"
    property string modelName: ""
    property string title: ""
    property bool required: false
    property bool readOnly: false
    enabled: !readOnly
    property bool isChange: false
    property alias contentItemForm: pform.contentItem
    signal change(var lines)
    property int idRecordParent: -1
    property var myParent: -1
    property var itemsField:[]
    property var mapFieldItem: ({})//form

    property bool oneItemDefault: false
    property bool activeMenu: false
    //menu
    property bool isMenuSwitch: true
    property bool isMenuOpen: true
    property bool isMenuRemove: true
    property bool isMenuNew: true
    property bool noItemAdd: false
    property bool isMenuBackForward: true
    property bool isOpenDialogEdit: false

    property bool readOnlyChild: false
    property bool visiblePaneColButton: false
    property real paneColButtonWidth: 150
    property bool visibleHeader: true
    property bool visiblePanelButtonDownload: false
    property bool visiblePanelButtonRemove: false
    property bool visibleButtonAddShop: false
    property string textButtonAddShop: "Nuevo"
    signal clickPanelButtons(int id, string btype)
    signal clickButtonAddShop()


    onReadOnlyChildChanged: {
        checkReadOnlyChild()
    }
    function checkReadOnlyChild(){
        if(readOnlyChild){
            isMenuSwitch=false;
            isMenuOpen=false;
            isMenuRemove=false;
            isMenuNew=false;
            mode="tree";
        }else{
            isMenuSwitch=true;
            isMenuOpen=true;
            isMenuRemove=true;
            if(!noItemAdd){
                isMenuNew=true;
            }
        }
    }
    property QtObject dialogForm
    property var listRecords: []// lines json
    //    property real heightField: 60
    property int currentIndex: -1
    property int maxItem: -1

    property bool isSequence: false
    property string fieldSequence: "sequence"
    //property bool autoRecord: true
    property string mode: "form" //tree
    property string mode_init: "form"
    property var listHead: [] //tree
    property var listNameHead: [] //tree
    property real heightField: 30
    property real heightHeader: 30
    property int maximumLineCount: 2
    property bool isPresedExpand: false
    property bool isShadowExpand: false
    property bool verticalLine: true
    property bool multiSelectItems: true
    property bool lineOdd: true
    property real lineOddShine: 0.1//config
    property bool horizontalLine: true
    property string defaultFormatDatetime: "dd/MM/yy hh:mm:ss"
    property string defaultFormatDate: "dd/MM/yy"
    property int typelogin: 1
    property bool hasItems: false
    property int total_count: modelLinesOM.count
    property var paramsPlusCreate: ({})
    property bool addMemoryFields: true
    property var fieldsConfig: []
    property var order:[]
    signal doubleClick(int id)
    signal clicked(int id)
    padding: 0

    ListModel{
        id:modelLinesOM
    }

    ButtonGroup {
        id: childGroup
        exclusive: false
    }

    Component.onCompleted: {
        templateO2M.objectName="tryton_"+fieldName+"_"+_getNewNumber();
        _initFields();
        clearValues();
        checkReadOnlyChild();
        if(noItemAdd){
            isMenuNew=false;
        }
    }

    function getWidthContentView(){
        var w = 0.0;
        for(var i=0, len = listHead.length;i<len;i++){
            w+=listHead[i].width;
        }
        return w
    }

    function _initFields(){
        itemsField = finditemsField(templateO2M.contentItem.children);
        _initMapFields();
        setItemParent();
        setListNameHead();
        setRequired();
        mode_init = mode;
        typelogin=setting.typelogin;
    }

    function setListNameHead(){
        for(var i = 0, len=listHead.length;i<len;i++){
            listNameHead.push(listHead[i].name);
        }

    }

    function setItemParent(){
        for(var i = 0, len=itemsField.length;i<len;i++){
            itemsField[i].itemParent = templateO2M;
        }
    }

    function setRequired(){
        for(var i = 0, len=itemsField.length;i<len;i++){
            if(itemsField[i].required == true){
                required=true;
                break;
            }
        }
    }

    function getIds(){
        var ids=[];
        var cindex = viewLinesOM.currentIndex;
        if(multiSelectItems){
            for(var i=0,len=viewLinesOM.count;i<len;i++){
                viewLinesOM.currentIndex=i;
                if(viewLinesOM.currentItem.isSelect()){
                    ids.push(viewLinesOM.currentItem.getId());
                }
            }
            viewLinesOM.currentIndex=cindex;
        }else{
            if(cindex!=-1){
                ids.push(viewLinesOM.currentItem.getId());
            }
        }
        return ids;
    }

    function getIndexIds(){
        var ids=[];
        var cindex = viewLinesOM.currentIndex;
        if(multiSelectItems){
            for(var i=0,len=viewLinesOM.count;i<len;i++){
                viewLinesOM.currentIndex=i;
                if(viewLinesOM.currentItem.isSelect()){
                    ids.push(i);
                }
            }
            viewLinesOM.currentIndex=cindex;
        }else{
            if(cindex!=-1){
                ids.push(cindex);
            }
        }
        return ids;
    }

    function getIndexCheckIds(){//delete only checks
        var ids=[];
        var cindex = viewLinesOM.currentIndex;
        for(var i=0,len=viewLinesOM.count;i<len;i++){
            viewLinesOM.currentIndex=i;
            if(viewLinesOM.currentItem.isSelect()){
                ids.push(i);
            }
        }
        viewLinesOM.currentIndex=cindex;
        return ids;
    }

    function getId(){
        if(viewLinesOM.currentIndex!=-1){
            return viewLinesOM.currentItem.getId();
        }
        return -1;
    }

    contentItem: ColumnLayout{
        Layout.fillWidth: true
        Layout.fillHeight: true
        RowLayout{
                        Layout.fillWidth: true
                        Layout.preferredHeight: 20
//            width: parent.width
            Label{
                id:lbtitle
                text:title
                visible: title==""?false:true
                Layout.preferredHeight: 20
                font.bold: true
                font.italic: true
                color: "grey"
                elide: Label.ElideRight
                //                fontSizeMode: Label.Fit
                Layout.fillWidth: true
                //                Layout.preferredWidth: paintedWidth
            }
            Label{
                id:lbitem
                text:isMobile?"":"  <"+qsTr("No items")+">  "
                visible: mode=="form"?hasItems?false:true:false
                Layout.preferredHeight: 20
                font.bold: true
                font.italic: true
                color: "grey"
                elide: Label.ElideRight
                //                fontSizeMode: Label.Fit
                Layout.fillWidth: true
                //                Layout.preferredWidth: paintedWidth

            }
            Button{
//                                                     Layout.preferredWidth: 70
                Layout.preferredHeight: 35
                visible: visibleButtonAddShop
                enabled: isMenuNew
                Material.background: setting.accent//Material.Green//setting_accent
                onClicked: {
                    clickButtonAddShop()
                }
                topPadding:0
                bottomPadding:0
                contentItem: RowLayout{
                    Text {
                        text: "\uf067"
                        font.family:fawesome.name
                        font.bold: false
                        font.italic: false
                        opacity: enabled ? 1.0 : 0.3
                        color: Qt.darker(mainroot.Material.accent)
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                        padding: 0
                    }
                    Text {
                        text: textButtonAddShop
                        opacity: enabled ? 1.0 : 0.3
                        color: Qt.darker(mainroot.Material.accent)
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                        padding: 0
                    }
                }
            }

            RowLayout{
                id:rww
                //                    width: buttonsw.width *6
                visible: activeMenu
                width: 30*6
//                Layout.alignment: Qt.AlignRight
                ButtonAwesome{
                    id:buttonsw
                    flat: true
                    text: "\uf065"
                    textToolTip: qsTr("switch")
                    enabled: isMenuSwitch
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 35
                    Material.foreground: mainroot.Material.accent
                    font.pixelSize: 18

                    onClicked: {
                        if(mode==="form"){
                            mode="tree";
                        }else{
                            if(modelLinesOM.count>0){
                                mode="form";
                            }
                            if(currentIndex>=0){
                                setCurrentIndexForm();
                            }else{
                                enabledFields(false);
                                clearItemsForm();
                            }
                        }
                    }
                }
                ButtonAwesome{
                    id:buttonleft
                    flat: true
                    text: "\uf053"
                    textToolTip: qsTr("back")
                    visible: isMenuBackForward
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 35
                    enabled: hasItems
                    Material.foreground: mainroot.Material.accent
                    font.pixelSize: 18
                    onClicked: {
                        if(currentIndex>0){
                            currentIndex-=1;
                            viewLinesOM.currentIndex=currentIndex;
                            childGroup.checkState=Qt.Unchecked;
                            tcheckitem.restart();
                            if(mode=="form"){
                                setCurrentIndexForm();
                            }
                        }

                    }
                }
                Label{
                    text: (currentIndex + 1).toString()+"/"+total_count.toString()
                    padding: 0
                    visible: isMenuBackForward
                    Layout.preferredWidth: 30
                    verticalAlignment: Label.AlignVCenter
                    horizontalAlignment: Label.AlignHCenter

                    color: "grey"
                    fontSizeMode: Label.Fit
                }
                ButtonAwesome{
                    id:buttonright
                    flat: true
                    text: "\uf054"
                    textToolTip: qsTr("forward")
                    visible: isMenuBackForward
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 35
                    enabled: hasItems
                    Material.foreground: mainroot.Material.accent
                    font.pixelSize: 18
                    onClicked: {
                        if(currentIndex<modelLinesOM.count-1){
                            currentIndex+=1;
                            viewLinesOM.currentIndex=currentIndex;
                            childGroup.checkState=Qt.Unchecked;
                            tcheckitem.restart();
                            if(mode=="form"){
                                setCurrentIndexForm();
                            }
                        }
                    }
                }

                ButtonAwesome{
                    id:buttonopen
                    flat: true
                    text: "\uf35d"
                    textToolTip: qsTr("open")
                    enabled: isMenuOpen
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 35
                    Material.foreground: mainroot.Material.accent
                    font.pixelSize: 18
                    onClicked: {
                        if(isOpenDialogEdit){

                        }else{
                            if(modelLinesOM.count>0){
                                mode="form";
                            }
                            if(currentIndex>=0){
                                setCurrentIndexForm();
                            }else{
                                enabledFields(false);
                                clearItemsForm();
                            }
                        }

                    }
                }
                ButtonAwesome{
                    id:buttonnew
                    flat: true
                    text: "\uf067"
                    textToolTip: qsTr("new")
                    enabled: isMenuNew
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 35
                    Material.foreground: mainroot.Material.accent
                    font.pixelSize: 18
                    onClicked: {
                        if(isOpenDialogEdit){

                        }else{
                            if(mode=="form"){
                                clearItemsForm();
                            }else{
                                clearItemsForm();
                            }
                            addRecordBlank(true);
                        }
                    }
                }
                ButtonAwesome{
                    id:buttondel
                    flat: true
                    text: "\uf2ed"
                    textToolTip: qsTr("remove")
//                    visible: isMenuRemove
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 35

                    enabled: hasItems && isMenuRemove
                    Material.foreground: mainroot.Material.accent
                    font.pixelSize: 18
                    onClicked: {
                        if(multiSelectItems==true){
                            var listIndex = getIndexCheckIds();
                            if(listIndex.length>0){
                                deleteRecordsIndex(listIndex);
                            }
                        }else{
                            if(currentIndex!=-1){
                                deleteRecord();
                            }
                        }

                        //                            if(currentIndex >= 0){
                        //                                if(childGroup.checkState!=0){
                        //                                    var listIndex = getIndexIds();
                        //                                    if(listIndex.length>1){
                        //                                        deleteRecordsIndex(listIndex);
                        //                                    }else{
                        //                                        deleteRecord();
                        //                                    }
                        //                                }
                        //                            }
                    }
                }
            }

            //            Flickable {//TODO MENU
            //                id: itoolmenu
            //                visible: activeMenu
            //                Layout.fillWidth: true
            //                Layout.preferredHeight: 35
            //                clip: true
            //                contentWidth: rww.width
            //                boundsBehavior: Flickable.StopAtBounds
            //                Layout.alignment: Qt.AlignRight

            //            }
        }

//        Item {
//            Layout.fillHeight: true
//            Layout.fillWidth: true
            ListView{
                id:viewLinesOM
                visible: !pform.visible//mode=="tree"?true:false
                property int countMini: -1
//                anchors.fill: parent
                Layout.fillHeight: true
                Layout.fillWidth: true
                clip: true
                model: modelLinesOM
                delegate: pdelegate
                ScrollBar.vertical: ScrollBar {policy: viewLinesOM.contentHeight > height?ScrollBar.AlwaysOn:ScrollBar.AsNeeded}
                ScrollBar.horizontal: ScrollBar {policy: viewLinesOM.contentWidth > width?ScrollBar.AlwaysOn:ScrollBar.AlwaysOff}
                flickableDirection: isMobile?Flickable.HorizontalAndVerticalFlick:Flickable.AutoFlickIfNeeded
                contentWidth: visibleHeader?headerItem.width:getWidthContentView()
                headerPositioning:isMobile?ListView.InlineHeader:ListView.OverlayHeader

                function getId(){
                    if(currentIndex!=-1){
                        var mid = currentItem.getId();
                        return mid;
                    }
                }

                function getObject(){
                    if(currentIndex!=-1){
                        return currentItem.getObject();
                    }
                }

                function reloadItem(){
                    if(currentIndex!=-1){
                        currentItem.reloadItem();
                    }
                }
                header: Row{
                    id:iph
                    visible: visibleHeader
                    z:8
                    Rectangle{
                        width: multiSelectItems?0:1
                        height: visibleHeader?heightHeader:0
                        visible: !multiSelectItems
                        color: mainroot.Material.accent
                    }
                    Row {
                        id:mHeaderView
                        z:8
                        height:visibleHeader? heightHeader:0
                        spacing: 1
                        function itemAt(index) { return repeater.itemAt(index) }
                        Label{
                            width: multiSelectItems?heightField+1:0
                            height: heightHeader
                            visible: multiSelectItems
                            padding: 4
                            text:" "
                            background: Rectangle {color:Qt.lighter(mainroot.Material.accent) }
                            CheckBox {
                                id: parentBox
                                checked: false
                                width: heightField
                                height: heightHeader
                                checkState: childGroup.checkState
                                Component.onCompleted: {if(multiSelectItems){childGroup.checkState=parentBox.checkState;}}
                                anchors.centerIn: parent
                                onClicked:  {
                                    if(checkState === Qt.Unchecked){
                                        childGroup.checkState=Qt.Unchecked;
                                    }else{
                                        childGroup.checkState=Qt.Checked;
                                    }
                                }
                                text: ""

                            }
                            Rectangle{
                                width: 1
                                height: parent.height
                                color: setting.theme == Material.Dark?Qt.darker(mainroot.Material.accent):"white"
                                x:parent.width
                            }
                        }

                        Repeater {
                            id: repeater
                            model: listHead
                            Label {
                                id:mll
                                text: modelData.alias
                                font.bold: true
                                width:  modelData.width<=20?20:modelData.width
                                height: 30
                                elide: Label.ElideRight
                                padding: 4
                                background: Rectangle {color:mainroot.Material.accent }//Qt.lighter(mainroot.Material.accent)
                                horizontalAlignment: modelData.align
                                verticalAlignment: Label.AlignVCenter
                                z:100-index
                                Rectangle{
                                    id:rec_shadow
                                    objectName: "rec_shadow"
                                    anchors.fill: parent
                                    opacity: 0.5
                                    color: "white"//setting.theme == Material.Dark?"white":"grey"//mainroot.Material.accent//"grey"
                                    visible: false
                                }
                                Rectangle{
                                    id:rec_view_exp
                                    width: 1
                                    height: parent.height
                                    color: setting.theme == Material.Dark?Qt.darker(mainroot.Material.accent):"white"
                                    x:parent.width
                                }
                                MouseArea{
                                    id:pmap
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered:  {if(isShadowExpand){rec_shadow.visible=true;}rec_view_exp.width=2;}
                                    onExited:  {if(isShadowExpand){rec_shadow.visible=false;}rec_view_exp.width=1;}
                                    cursorShape: isPresedExpand?Qt.SizeHorCursor:Qt.ArrowCursor

                                    Rectangle{
                                        id:rec_right
                                        width: 2
                                        height: parent.height
                                        color: "grey"
                                        x:parent.width
                                        opacity: 0
                                        MouseArea{
                                            id:ma
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape : Qt.SizeHorCursor
                                            onPressed:{isPresedExpand=true}// { map.cursorShape = Qt.SizeHorCursor; pmap.cursorShape = Qt.SizeHorCursor}
                                            onEntered: {rec_right.opacity=1}
                                            onExited: {rec_right.opacity=0}
                                            drag.target: rec_right
                                            drag.axis: Drag.XAxis
                                            drag.minimumX: 20
                                            drag.filterChildren: true
                                            onReleased: {
                                                modelData.width = rec_right.x;
                                                mll.width = rec_right.x;
                                                var pi = rep_column.itemAt(index);
                                                pi.value = rec_right.x;
                                                isPresedExpand=false;
                                            }

                                        }
                                    }
                                    Rectangle{
                                        id:rec_view_line
                                        x:rec_right.x
                                        width: 2
                                        height: viewLinesOM.height
                                        color: "grey"
                                        visible: ma.pressed?1:0
                                    }

                                }
                            }
                        }
                    }
                    Rectangle{
                        width: multiSelectItems?0:1
                        height: visibleHeader?heightHeader:0
                        visible: !multiSelectItems
                        color: mainroot.Material.accent
                    }

                }

            }
            Pane{
                id:pform
                padding: 0
//                anchors.fill: parent
                Layout.fillHeight: true
                Layout.fillWidth: true
                visible: mode=="form"?true:false
            }
//        }



    }
    Repeater {
        id: rep_column
        model: listHead
        Item {
            property real value: modelData.width
        }
    }
    Timer{
        id:tcheckitem
        interval: 120
        onTriggered: {
            if(viewLinesOM.currentIndex!=-1){
                viewLinesOM.currentItem.checkItem();
            }
        }
    }


    Component{
        id:pdelegate
        ItemDelegate {
            id:itdele
            width: viewLinesOM.contentWidth
            height: heightField
            property bool selectItem: false
            property var myobject: viewLinesOM.model.get(index)
            function getId(){
                return myobject["id"];
            }
            function isSelect(){
                return selectItem;
            }
            function checkItem(){
                selectItem = true;
            }
            function getObject(){
                return myobject;
            }
            function reloadItem(){//update
                myobject = viewLinesOM.model.get(index);
                var itemstoreload = finditemsFieldTree(itdele.contentItem.children);
                for(var i=0, len= itemstoreload.length;i<len;i++){
                    itemstoreload[i].setValue();
                }

            }
            contentItem: Item{
                id:pit
                anchors{fill: parent;margins: 0}
                Rectangle{
                    anchors.fill: parent
                    visible: lineOdd?index%2:0
                    color: setting.theme == Material.Dark?Qt.darker(mainroot.Material.accent):Qt.darker(mainroot.Material.accent)
                    opacity: lineOddShine
                }
                Column{
                    Row{
                        Rectangle {
                            color: mainroot.Material.accent
                            height: itdele.height
                            width: multiSelectItems?1:0//1
                            opacity: verticalLine?1:0
                            visible: multiSelectItems
                        }
                        CheckBox {
                            id:chitem
                            ButtonGroup.group: multiSelectItems?childGroup:null
                            checked: selectItem
                            width: multiSelectItems?height:-1
                            height: heightField
                            visible: multiSelectItems
                            text: ""
                            onClicked: {
                                templateO2M.currentIndex = index;
                                viewLinesOM.currentIndex = index;
                            }
                            onCheckedChanged: {
                                if(checked){
                                    selectItem=true;
                                }else{
                                    selectItem=false;
                                }
                            }
                        }
                        Rectangle {
                            color: mainroot.Material.accent
                            height: itdele.height
                            width: 1
                            opacity: verticalLine?1:0

                        }
                        Repeater {
                            model: listHead
                            Row{
                                Label {
                                    id:label
                                    property var imageId
                                    property bool isField: true
                                    color: mainroot.Material.foreground
                                    elide: Text.ElideRight
                                    width:  modelData.width
                                    height: heightField
                                    maximumLineCount: templateO2M.maximumLineCount
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: modelData.align
                                    fontSizeMode: Text.Fit
                                    minimumPixelSize: 10
                                    padding: 4
                                    wrapMode: Label.Wrap
                                    // text:myobject[modelData.name]//modelData.width.toString()//viewLinesOM.model.modelData[modelData.name]
                                    Component.onCompleted: {
                                        width = Qt.binding(function(){
                                            var it=rep_column.itemAt(index);
                                            if(it.value>20){
                                                return it.value;
                                            }
                                            return 20;
                                        });
                                        setValue();
                                    }

                                    function setValue(){
                                        if(modelData.type==="image"){
                                            var imageQmlObject = Qt.createQmlObject('import QtQuick 2.9;
                                                                        Image{
                                                                              asynchronous: true;
                                                                              cache: false;
                                                                              anchors.fill:parent;
                                                                              fillMode: Image.PreserveAspectFit;
                                                                        }', label, "dynamicSnippet1");
                                            imageId=imageQmlObject;
                                            if(myobject[modelData.name] !== null){
                                                if(myobject[modelData.name]["__class__"] === "bytes"){
                                                    imageQmlObject.source = "data:image/"+modelData.format+";base64,"+myobject[modelData.name]["base64"];
                                                }else{
                                                    imageQmlObject.source="";
                                                }
                                            }else{
                                                imageQmlObject.source="";
                                            }
                                        }else{
                                            text = parseData(modelData.type);
                                        }
                                    }

                                    function myformatDecimal(value){
                                        return myformatDecimalPlaces(value,2);
                                    }
                                    function myformatDecimalPlaces(value, mplaces){
                                        //                                        if(value==null){
                                        //                                            return "";
                                        //                                        }

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
                                    function parseObject(schema){
                                        var value="";
                                        if(schema.hasOwnProperty('__class__')){
                                            if(schema['__class__'] === 'Decimal'){
                                                value = myformatDecimal(schema['decimal']);
                                            }else{
                                                if(schema['__class__']==="date"){
                                                    value = Qt.formatDateTime(new Date(schema.year, schema.month-1, schema.day), defaultFormatDate);
                                                }else{
                                                    if(schema['__class__']==="datetime"){
                                                        value = Qt.formatDateTime(new Date(schema.year, schema.month-1, schema.day, schema.hour, schema.minute, schema.second), defaultFormatDatetime);
                                                    }else{
                                                        value="";
                                                        //                                                        '__class__': 'time'
                                                        //                                                        '__class__': 'timedelta'
                                                        //                                                        '__class__': 'bytes'

                                                    }
                                                }
                                            }
                                        }
                                        return value;
                                    }

                                    function parseData(type){
                                        if(myobject[modelData.name]==null){
                                            return "";
                                        }
                                        switch(type){
                                        case 'text'://
                                            if(typeof myobject[modelData.name] === 'string'||typeof myobject[modelData.name] === 'number'){
                                                return myobject[modelData.name];
                                            }else{// WARNING this should not happen, use type numeric or date
                                                if(typeof myobject[modelData.name] === 'object'){
                                                    if (Array.isArray(myobject[modelData.name])){
                                                        return "("+myobject[modelData.name].length+")";
                                                    }else{
                                                        return parseObject(myobject[modelData.name]);
                                                    }
                                                }else{
                                                    return "";
                                                }
                                            }
                                        case 'integer':
                                            return myobject[modelData.name];
                                        case 'numeric':
                                            var value_de = myobject[modelData.name].decimal;
                                            if(typeof value_de === "undefined"){
                                                value_de = myobject[modelData.name];
                                            }
                                            if(typeof modelData.decimals !== "undefined"){
                                                return myformatDecimalPlaces(value_de, modelData.decimals);
                                            }
                                            return myformatDecimal(value_de);
                                        case 'float':
                                            if(typeof modelData.decimals !== "undefined"){
                                                return myformatDecimalPlaces(myobject[modelData.name], modelData.decimals);
                                            }
                                            return myformatDecimal(myobject[modelData.name]);
                                        case 'datetime':
                                            var format_dt = modelData.format
                                            if(typeof format_dt === "undefined"){
                                                format_dt = defaultFormatDatetime;
                                            }
                                            var value_dt = myobject[modelData.name];
                                            if(typeof value_dt.hour !== "undefined"){
                                                return Qt.formatDateTime(new Date(value_dt.year, value_dt.month-1, value_dt.day, value_dt.hour, value_dt.minute, value_dt.second), format_dt);
                                            }
                                            return value_dt;
                                        case 'date':
                                            var format_d = modelData.format
                                            if(typeof format_d === "undefined"){
                                                format_d = defaultFormatDate;
                                            }
                                            var value_d = myobject[modelData.name];
                                            if(typeof value_d.year !== "undefined"){
                                                return Qt.formatDateTime(new Date(value_d.year, value_d.month-1, value_d.day), format_d);
                                            }
                                            return value_d;
                                        case 'selection':
                                            if(modelData.hasOwnProperty("selectionalias")){
                                                if (modelData.selectionalias.hasOwnProperty(myobject[modelData.name])){
                                                    return modelData.selectionalias[myobject[modelData.name]]
                                                }
                                            }
                                            return myobject[modelData.name];
                                        case 'one2many':
                                            if (Array.isArray(myobject[modelData.name])){
                                                return "("+myobject[modelData.name].length+")";
                                            }
                                            return "";
                                        case 'many2many':
                                            if (Array.isArray(myobject[modelData.name])){
                                                return "("+myobject[modelData.name].length+")";
                                            }
                                            return "";
                                        case 'many2one':
                                            if(myobject[modelData.name]===null || myobject[modelData.name]===-1){
                                                return "";
                                            }
                                            var rnm = "";
                                            if(typelogin===0){
                                                rnm = myobject[modelData.name+".rec_name"];
                                            }else{
                                                rnm = myobject[modelData.name+"."]["rec_name"];
                                            }

                                            if(typeof rnm === "undefined"){
                                                return "";
                                            }
                                            return rnm;
                                        case 'boolean':
                                            if(myobject[modelData.name]==true){
                                                label.font.family=fawesome.name;
                                                return "\uf00c";
                                            }
                                            return "";
                                        default:
                                            return "";
                                        }
                                    }
                                }
                                Rectangle {
                                    color: mainroot.Material.accent
                                    height: itdele.height
                                    width: 1
                                    opacity: verticalLine?1:0
                                }
                            }
                        }
                        Pane{
                            id:paneColButton
                            padding: 0
                            width:  paneColButtonWidth
                            visible:visiblePaneColButton
                            height: heightField

                            RowLayout{
//                                anchors.fill: parent
                                ButtonAwesome{
                                    id:bview
                                    flat: true
                                    text: "\uf019"
                                    visible: visiblePanelButtonDownload
                                    textToolTip: qsTr("Download")
                                    Layout.preferredWidth: 30
                                    Layout.preferredHeight: heightField
                                    Material.foreground: mainroot.Material.accent
                                    font.pixelSize: 16
                                    onClicked: {
                                        viewLinesOM.forceActiveFocus();
                                        viewLinesOM.currentIndex = model.index;
                                        templateO2M.currentIndex = model.index;
                                        if(multiSelectItems==true){
                                            childGroup.checkState=Qt.Unchecked;
                                            tcheckitem.restart();
                                        }
                                        clickPanelButtons(itdele.getId(),"download");
                                    }
                                }
                                ButtonAwesome{
                                    id:bremove
                                    flat: true
                                    text: "\uf2ed"
                                    visible: visiblePanelButtonRemove
                                    enabled: isMenuRemove
                                    textToolTip: qsTr("Remove")
                                    Layout.preferredWidth: 30
                                    Layout.preferredHeight: heightField
                                    Material.foreground: mainroot.Material.accent
                                    font.pixelSize: 16
                                    onClicked: {
                                        viewLinesOM.forceActiveFocus();
                                        viewLinesOM.currentIndex = model.index;
                                        templateO2M.currentIndex = model.index;
                                        if(multiSelectItems==true){
                                            childGroup.checkState=Qt.Unchecked;
                                            tcheckitem.restart();
                                        }
                                        if(currentIndex!=-1){
                                            deleteRecord();
                                        }

                                    }
                                }
                            }
                        }

                    }
                }
                Rectangle {
                    color: mainroot.Material.accent
                    width: parent.width
                    height: 1
                    visible: horizontalLine
                    anchors.bottom: parent.bottom
                }
            }
            highlighted: ListView.isCurrentItem
            onClicked: {
                viewLinesOM.forceActiveFocus();
                viewLinesOM.currentIndex = model.index;
                templateO2M.currentIndex = model.index;
                //check only this item
                childGroup.checkState=Qt.Unchecked;
                tcheckitem.restart();
            }
            onDoubleClicked: {
                viewLinesOM.forceActiveFocus();
                viewLinesOM.currentIndex = model.index;
                templateO2M.currentIndex = model.index;
                //check only this item
                childGroup.checkState=Qt.Unchecked;
                tcheckitem.restart();
                doubleClick(itdele.getId())
                if(isOpenDialogEdit){

                }
            }

            Keys.onPressed: {
                if (event.key === Qt.Key_Return ) {
                    event.accepted = true;
                    viewLinesOM.currentIndex = model.index;
                    templateO2M.currentIndex = model.index;
                    if(isOpenDialogEdit){

                    }
                }
                if (event.key === Qt.Key_Enter ) {
                    event.accepted = true;
                    viewLinesOM.currentIndex = model.index;
                    templateO2M.currentIndex = model.index;
                    if(isOpenDialogEdit){

                    }
                }
            }
        }
    }


    function exChange(){
        change(listRecords);
    }

    function changeField(field, value){
        var index_real = findIndexReal(currentIndex);
        listRecords[index_real][field]=value;
        listRecords[index_real]["change"][field]=field;
        listRecords[index_real]["action"]="write";
        var type = mapFieldItem[field].type;
        if(type==="many2one"){
            if(value !== null){
                var item = mapFieldItem[field];
                var value_rec = {"id":value, "rec_name":item.getValueName()};
                if(setting.typelogin===0){
                    listRecords[index_real][field+".rec_name"]=item.getValueName();
                }else{
                    listRecords[index_real][field+"."]=value_rec;
                }
            }else{
                //delete
            }
        }
        isChange = true;
        change(listRecords);
        changeInModel(field, value);
    }

    function changeInModel(field, value){
        var index_real = findIndexReal(currentIndex);
        if(listNameHead.indexOf(field)!=-1){
            var jsondata = listRecords[index_real];
            jsondata[field] = value;
            var type = mapFieldItem[field].type;
            modelLinesOM.set(currentIndex,fixValuesNull(jsondata));
            viewLinesOM.reloadItem();
        }
    }

    function finditemsFieldTree(ite){
        var result=[];
        for(var i = 0, len=ite.length;i<len;i++){
            var result2 = [];
            if(typeof ite[i].isField !== "undefined"){
                if(ite[i].isField == true){
                    result.push(ite[i]);
                }
            }
            if(ite[i].children.length>0){
                result2 = finditemsFieldTree(ite[i].children);
                result=result.concat(result2);
            }
        }
        return result;
    }

    function clearValue(){
        clearValues();
    }

    function deleteAllRecords(){
        var countm = modelLinesOM.count;
        var listin=[];
        for(var i=0,len=countm;i<len;i++){
            listin.push(i);
        }

        deleteRecordsIndex(listin);
    }

    function clearValues(){
        currentIndex = -1;
        listRecords=[];
        hasItems=false
        modelLinesOM.clear();
        clearItemsForm();
        if(oneItemDefault){
            addRecordBlank(false);
        }else{
            isChange=false;
            // if(mode=="form"){
            enabledFields(false);
            // }
        }
        mode = mode_init;
    }

    function enabledFields(active){
        for(var i=0,len=itemsField.length;i<len;i++){
            if(itemsField[i].readOnly==false){
                itemsField[i].enabled=active;
            }
        }
        hasItems = active;
    }

    function addRecordBlank(echange){
        var values = getFieldsInitValues(false);
        values["id"]=-1;
        if(isSequence){
            values["sequence"]=null;
        }
        values["action"]="";
        values["change"]={};
        values = Object.assign(values, paramsPlusCreate)
        addRecord(values, echange);
    }

    function fixValuesNull(values){
        var listF = Object.keys(values);
        var _values={};
        //        for(var i in values){

        //        }
        for(var i=0,len=listF.length;i<len;i++){
            var nfield = listF[i]
            if(values[nfield]===null){
                _values[nfield] = "";
                if(mapFieldItem[nfield]){
                    var type = mapFieldItem[nfield].type;
                    if(type==="many2one"){
                        _values[nfield] = -1;
                    }
                    if(type==="text"){
                        _values[nfield] = "";
                    }
                    if(type ==="integer" || type ==="float"){
                        _values[nfield] = 0;
                    }
                    if(type==="numeric"){
                        _values[nfield] = {"__class__":"Decimal","decimal":""}
                    }
                    if(type==="binary"){
                        _values[nfield] = {"__class__":"bytes","base64":""};
                    }
                }
            }else{
                _values[nfield] = values[nfield];
            }
        }
        return _values;
    }
    function addRecords2(list_values){
        var template = JSON.stringify(getFieldsInitValues())
        for(var i = 0, len=list_values.length;i<len;i++){
            var values_data = list_values[i];//getFieldsInitValues(false);
            var values = JSON.parse(template);
            for(var itemt in values_data){
                values[itemt] = values_data[itemt];
            }
            values["id"]=-1;
            if(isSequence){
                values["sequence"]=null;
            }
            values["action"]="write";
            values["change"]={};
            for(var item in values){
                if(values[item]){
                    values["change"][item]=item;
                }
            }


            values = Object.assign(values, paramsPlusCreate)
//            addRecord(values, true);
//            console.log(JSON.stringify(values))
            listRecords.push(values);
//            var countm =  modelLinesOM.count;
            modelLinesOM.append(fixValuesNull(values));
            isChange=true;
            change(listRecords);

//            if(echange){
//                change(listRecords);
//            }


        }
        if(list_values.length>0){
            currentIndex=0;
        }
//        currentIndex=countm;
        setCurrentIndexForm();
        isChange = true;
        viewLinesOM.currentIndex=currentIndex;
        childGroup.checkState=Qt.Unchecked;
        tcheckitem.restart();
    }

    function addRecords(list_values){
        var countm =  modelLinesOM.count;
        for(var i = 0, len=list_values.length;i<len;i++){
            listRecords.push(list_values[i]);
            modelLinesOM.append(fixValuesNull(list_values[i]));
        }
        if(list_values.length>0){
            countm=0;
            currentIndex = 0;
            if(mode=="form"){
                setCurrentIndexForm();
            }else{
                hasItems=true;
            }
        }

        viewLinesOM.currentIndex=currentIndex;
        childGroup.checkState=Qt.Unchecked;
        tcheckitem.restart();
        isChange=true;
//        currentIndex=countm;
//        setCurrentIndexForm();
//        isChange = true;
//        viewLinesOM.currentIndex=currentIndex;
//        childGroup.checkState=Qt.Unchecked;
//        tcheckitem.restart();
//        isChange=false;
//        if(echange){
//            change(listRecords);
//        }

        viewLinesOM.currentIndex=currentIndex;
        childGroup.checkState=Qt.Unchecked;
//        tcheckitem.restart();
    }

    function addRecord(values, echange){
        listRecords.push(values);
        var countm =  modelLinesOM.count;
        modelLinesOM.append(fixValuesNull(values));
        currentIndex=countm;
        setCurrentIndexForm();
        isChange = true;
        if(echange){
            change(listRecords);
        }
        viewLinesOM.currentIndex=currentIndex;
        childGroup.checkState=Qt.Unchecked;
        tcheckitem.restart();
    }

    function findIndexReal(index){
        var i_real=index;
        var suma=-1;
        for(var i=0,len=listRecords.length;i<len;i++){
            if(listRecords[i].action !== 'delete'){
                suma+=1;
                if(suma == index){
                    i_real = i;
                    break;
                }
            }
        }
        return i_real;
    }

    function deleteRecordsIndex(listIndex){
        listIndex.sort(function(a, b) {
            return b - a;
        });
        for(var i = 0, len = listIndex.length;i<len;i++){
            var index = listIndex[i];
            var index_real = findIndexReal(index);
            if(listRecords[index_real].id!==-1){
                listRecords[index_real].action="delete";
            }else{
                listRecords.splice(index_real, 1);
            }
            modelLinesOM.remove(index);
        }
        isChange = true;
        change(listRecords);
        if(modelLinesOM.count>0){
            currentIndex = 0;
            if(mode=="form"){
                setCurrentIndexForm();
            }
        }else{
            currentIndex = -1;
            hasItems=false;
            if(mode=="form"){
                enabledFields(false);
                clearItemsForm();
            }
        }
        viewLinesOM.currentIndex=currentIndex;
        childGroup.checkState=Qt.Unchecked;
        tcheckitem.restart();
        if(modelLinesOM.count==0){
            mode="tree";
        }
    }

    function deleteRecord(){
        var index_real = findIndexReal(currentIndex);
        if(listRecords[index_real].id!==-1){
            listRecords[index_real].action="delete";
        }else{
            listRecords.splice(index_real, 1);
        }
        isChange = true;
        change(listRecords);
        modelLinesOM.remove(currentIndex);
        selectIndexBack();
        if(modelLinesOM.count==0){
            mode="tree";
        }
    }

    function selectIndexBack(){
        if(currentIndex>0){
            currentIndex-=1;
            if(mode=="form"){
                setCurrentIndexForm();
            }
        }else{
            if(modelLinesOM.count>0){
                currentIndex = 0;
                if(mode=="form"){
                    setCurrentIndexForm();
                }
            }else{
                currentIndex = -1;
                hasItems=false;
                if(mode=="form"){
                    enabledFields(false);
                    clearItemsForm();
                }
            }

        }
        checkOnlyCurrentIndex();
    }

    function checkOnlyCurrentIndex(){
        viewLinesOM.currentIndex=currentIndex;
        childGroup.checkState=Qt.Unchecked;
        tcheckitem.restart();
    }

    function clearItemsForm(){
        for(var i=0,len=itemsField.length;i<len;i++){
            itemsField[i].clearValue();
        }
    }

    function changeToParent(field){
        isChange = true;
        change(listRecords);
    }

    function setValueTryton40(ids){
        if(ids.length>0){
            _read(ids);
        }else{
            setValue([]);
        }
        if(modelLinesOM.count>0){
            hasItems=true;
        }
    }

    function _read(ids){
        var params = getFieldsNamesTryton40();
        openBusy();

        var r_params = prepareParamsLocal("model."+modelName+".read",
                                          [
                                              ids,
                                              params,
                                              preferences
                                          ]);
        var url = getUrl();
        var http = getHttpRequest(url, r_params, "");

        http.onreadystatechange = function() { // Call a function when the state changes.
            if (http.readyState == 4) {
                if (http.status == 200) {
                    closeBusy();
                    //                    console.log(http.responseText);
                    var response = JSON.parse(http.responseText.toString());
                    if(response.hasOwnProperty("result")){
                        if(response.result.length>0){
                            var obj = response.result;
                            setValue(obj);
                        }
                    }else{
                        analizeErrors(response);
                    }

                } else {
                    MessageLib.showMessage("error: "+http.status,mainroot);
                    closeBusy();
                }
            }
        }
        http.send(JSON.stringify(r_params));


        //        var data = QJsonNetworkQml.recursiveCall("sread","model."+modelName+".read",
        //                                                 [
        //                                                     ids,
        //                                                     params,
        //                                                     preferences
        //                                                 ]);
        //        closeBusy();
        //        if(data.data!=="error"){
        //            if(data.data.result.length>0){
        //                var obj = data.data.result;
        //                setValue(obj);
        //            }
        //        }
    }

    function setValue(values){//TODO order
        listRecords=[];
        modelLinesOM.clear();
        currentIndex = -1;
        if(isSequence){
            //order list values
        }
        for(var i = 0, len=values.length;i<len;i++){
            var data = values[i];
            data["action"]="ready";
            data["change"]={};
            data = Object.assign(data, paramsPlusCreate)
            listRecords.push(data);
            modelLinesOM.append(fixValuesNull(data));
        }
        isChange=false;
        if(listRecords.length>0){
            currentIndex = 0;
            if(mode=="form"){
                setCurrentIndexForm();
            }else{
                hasItems=true;
            }
            viewLinesOM.currentIndex=currentIndex;
            childGroup.checkState=Qt.Unchecked;
            tcheckitem.restart();
            isChange=false;
        }else{
            if(oneItemDefault){
                addRecordBlank(false);
            }else{
                if(mode=="form"){
                    enabledFields(false);
                }
            }
        }

    }
    function _forceActiveFocus(){
        focusFieldForm();
    }

    function focusFieldForm(){
        if(itemsField.length>0){
            itemsField[0]._forceActiveFocus();
        }
    }

    function setCurrentIndexForm(){
        if(modelLinesOM.count>0){
            enabledFields(true);
            checkOnlyCurrentIndex();
            var datacurrentIndex = listRecords[findIndexReal(currentIndex)];
            for(var i = 0, len=itemsField.length;i<len;i++){
                if(itemsField[i].type==="many2one"){
                    if(datacurrentIndex[itemsField[i].fieldName]!==null){
                        if(setting.typelogin==0){//Tryton 4
                            itemsField[i].setValue({"id":datacurrentIndex[itemsField[i].fieldName],"name":datacurrentIndex[itemsField[i].fieldName+".rec_name"]});
                        }else{
                            itemsField[i].setValue({"id":datacurrentIndex[itemsField[i].fieldName+"."]["id"],"name":datacurrentIndex[itemsField[i].fieldName+"."]["rec_name"]});
                        }
                    }else{
                        itemsField[i].setValue({"id":-1,"name":""})
                    }

                }else{

                    if(itemsField[i].fieldName.indexOf(".")===-1){
                        itemsField[i].setValue(datacurrentIndex[itemsField[i].fieldName]);
                    }else{
                        //TODO
                    }
                }
            }
            focusFieldForm();

        }else{
            enabledFields(false);
        }

    }

    function get_context_timestamp(){
        var ocontext={};
        for(var i=0,len=listRecords.length;i<len;i++){
            var data = JSON.parse(JSON.stringify(listRecords[i]));
            if(data.id!=-1){
                if(data.hasOwnProperty("_timestamp") && (data.action==='write' || data.action==='delete')){
                    if(data._timestamp!=null){
                        var itemTimeStamp = JSON.parse('{"'+modelName+','+data.id.toString()+'":"'+data._timestamp+'"}');
                        //add one2many timestamp
                        ocontext = Object.assign(JSON.parse(JSON.stringify(ocontext)), itemTimeStamp)
                    }
                }
            }
        }
        return ocontext;
    }

    function getValue(){
        var lines =[];
        var add = [];
        var deleteItem = [];
        var create = [];
        var write = [];
        //        var indexDelete=[];
        for(var i=0,len=listRecords.length;i<len;i++){
            var record = JSON.parse(JSON.stringify(listRecords[i]));
            var data = JSON.parse(JSON.stringify(listRecords[i]));
            if(data.id==-1){
                delete record.action;
                delete record.id;
                delete record.change;
                if(isSequence){
                    //    delete record.sequence;
                }
                var _recordfix = {};
                for(var nf in record){
                    if(nf.indexOf(".")<0){
                        if(mapFieldItem.hasOwnProperty(nf)==true){
//                            if(mapFieldItem[nf].readOnly==false){
                                _recordfix[nf] = record[nf];
//                            }
                        }else{
                            if(addMemoryFields){
                                _recordfix[nf] = record[nf];
                            }
                        }
                    }

                }
                create.push(_recordfix);
            }else{
                if(data.action==='delete'){
                    deleteItem.push(record.id);
                }else{
                    if(data.action==='write'){
                        add.push(record.id);
                        write.push([record.id]);
                        var fis = Object.keys(record.change);
                        var paramw={}
                        for(var ii=0,lenf=fis.length;ii<lenf;ii++){
                            paramw[fis[ii]]=record[fis[ii]];
                        }

                        write.push(paramw);
                    }
                }
            }
        }
        if(add.length>0){
            lines.push(["add",add]);
        }
        if(create.length>0){
            lines.push(["create", create]);
        }
        if(write.length>0){
            var rwrite=["write"];
            for(var iw=0,lenw=write.length;iw<lenw;iw++){
                rwrite.push(write[iw]);
            }

            lines.push(rwrite);
        }
        if(deleteItem.length>0){
            lines.push(["delete", deleteItem]);
        }
        // setChangeOff();
        return lines;
    }

    function finditemsField(ite){
        var result=[];
        for(var i = 0, len=ite.length;i<len;i++){
            var result2 = [];
            if(typeof ite[i].objectName !== "undefined"){
                if(ite[i].objectName.indexOf("tryton")>-1){
                    if(ite[i].tryton == true){
                        result.push(ite[i]);
                    }
                }
            }
            if(ite[i].children.length>0){
                if(typeof ite[i].objectName !== "undefined"){
                    if(ite[i].objectName.indexOf("tryton")>-1){
                        if(ite[i].type!=="one2many"){
                            result2 = finditemsField(ite[i].children);
                            result=result.concat(result2);
                        }
                    }else{
                        result2 = finditemsField(ite[i].children);
                        result=result.concat(result2);
                    }
                }else{
                    result2 = finditemsField(ite[i].children);
                    result=result.concat(result2);
                }
            }
        }
        return result;
    }

    function _initMapFields(){
        for(var i = 0, len=itemsField.length;i<len;i++){
            mapFieldItem[itemsField[i].fieldName]=itemsField[i];
        }
    }

    function setChangeOff(){
        for(var i=0,len=itemsField.length;i<len;i++){
            itemsField[i].clearValue();
        }
    }
    function addTempM2O(params, fieldName){
        if(setting.typelogin===0){
            params[fieldName+".rec_name"]="";
        }else{
            params[fieldName+"."]={"id":-1, "rec_name":""};
        }
        return params;
    }

    function getFieldsInitValues(onlyChange){
        var params={};
        for(var i=0,len=itemsField.length;i<len;i++){
            if(onlyChange==true){
                if(itemsField[i].isChange){
                    params[itemsField[i].fieldName]=itemsField[i].getValue();
                    params = addTempM2O(params, itemsField[i].fieldName);
                }
            }else{
                params[itemsField[i].fieldName]=itemsField[i].getValue();
                if(itemsField[i].type === "many2one"){
                    params = addTempM2O(params, itemsField[i].fieldName);
                }
            }
        }
        //tree
        for(i=0,len=listHead.length;i<len;i++){
            var nameFieldHead = listHead[i].name;
            if(params.hasOwnProperty(nameFieldHead)==false){
                params[nameFieldHead]="";
                var type = listHead[i].type;
                if(type==="many2one"){
                    params[nameFieldHead]=-1;
                    if(setting.typelogin===0){
                        params[nameFieldHead+".rec_name"]="";
                    }else{
                        params[nameFieldHead+"."]={"id":-1, "rec_name":""};
                    }
                }
                if(type==="text"){
                    params[nameFieldHead] = "";
                }
                if(type ==="integer" || type ==="float"){
                    params[nameFieldHead] = "";
                }
                if(type==="numeric"){
                    params[nameFieldHead] = {"__class__":"Decimal","decimal":""}
                }
                if(type==="binary"){
                    params[nameFieldHead] = {"__class__":"bytes","base64":""};
                }
            }
        }
        return params;
    }


    function _preValidRequired(){
        for(var i=0,len=itemsField.length;i<len;i++){
            if(itemsField[i].required === true){
                for(var j=0,lenj=listRecords.length;j<lenj;j++){
                    if(listRecords[j].action!="delete"){
                        var value = listRecords[j][itemsField[i].fieldName]
                        if(value === "" || value === -1 || value === null){
                            currentIndex=j;
                            viewLinesOM.currentIndex=currentIndex;
                            childGroup.checkState=Qt.Unchecked;
                            tcheckitem.restart();
                            mode="form";
                            setCurrentIndexForm();
                            itemsField[i]._forceActiveFocus();
                            MessageLib.showMessage(itemsField[i].labelAlias+ " "+qsTr("Required"), mainroot);
                            return false;
                        }
                    }
                }
            }
        }
        return true;
    }

    function getFieldsNames(){
        var params=[];
        for(var i=0,len=itemsField.length;i<len;i++){
            params.push(fieldName+"."+itemsField[i].fieldName)
            if(itemsField[i].type=="many2one"){
                params.push(fieldName+"."+itemsField[i].fieldName+".rec_name");
            }
        }
        for(i=0,len=listHead.length;i<len;i++){
            var nameFieldHead = fieldName+"."+listHead[i].name;
            if(params.indexOf(nameFieldHead)==-1){
                params.push(nameFieldHead)
                if(listHead[i].type=="many2one"){
                    params.push(nameFieldHead+".rec_name");
                }
            }
        }
        params.push(fieldName+"."+"id");
        if(isSequence){
            params.push(fieldName+"."+fieldSequence);
        }
        return params;
    }

    function getFieldsNamesTryton40(){
        var params=[];
        for(var i=0,len=itemsField.length;i<len;i++){
            params.push(itemsField[i].fieldName)
            if(itemsField[i].type=="many2one"){
                params.push(itemsField[i].fieldName+".rec_name");
            }
        }
        for(i=0,len=listHead.length;i<len;i++){
            var nameFieldHead = listHead[i].name;
            if(params.indexOf(nameFieldHead)==-1){
                params.push(nameFieldHead)
                if(listHead[i].type=="many2one"){
                    params.push(nameFieldHead+".rec_name");
                }
            }
        }
        params.push("id");
        params.push("rec_name");
        params.push("_timestamp");
        return params;
    }

    function getFieldsNamesO2M(){
        var listParentNames = [];
        var listNames = getFieldsNames();
        for(var i=0,len=listNames.length;i<len;i++){
            listParentNames.push(fieldName+"."+listNames[i]);
        }
        return listParentNames;
    }


    function setValues(values){
        for(var i=0,len=itemsField.length;i<len;i++){
            itemsField[i].setValue(values[itemsField[i].fieldName]);
        }
    }
}
