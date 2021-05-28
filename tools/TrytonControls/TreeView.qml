//this file is part the thesa: tryton client based PySide2(qml2)
// view tree
//__author__ = "Numael Garay"
//__copyright__ = "Copyright 2020"
//__license__ = "GPL"
//__version__ = "1.8.0"
//__maintainer__ = "Numael Garay"
//__email__ = "mantrixsoft@gmail.com"

import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import "../thesatools"

//TODO  add type button

Control{
    id:control
    //    implicitWidth: 100
    //    implicitHeight: 100
    property bool activeFilters: true
    property bool activeStates: false
    property var modelStates: []//[{"name":"draft", "alias":"Borrador"}]
    property var domainState: []
    property bool activeAutoFields: false
    property bool editable: false//... for the moment not supported
    property bool lineOdd: true
    property real lineOddShine: 0.1//config
    property alias delegate: listview.delegate
    property alias contentWidth: listview.contentWidth
    property int maximumLineCount: 1
    property real heightHeader: 30
    property real heightField: 30
    property real heightFilter: 45
    property real heightStates: 35
   // property real heightStates: 40
    property bool verticalLine: true
    property bool horizontalLine: true
    property bool multiSelectItems: true
    property var listHead: []
    //    property bool useTableView: true
    property string modelName: ""
    property var fields: []
    property var fieldsFormatDecimal: []
    property var fieldsFormatDateTime: []
    property int limit: 500
    property int maximunItemView: 10000//config
    property int _cacheBuffer: maximunItemView*heightField
    property var order: []
    property var initOrder: []
    property var domain: []
    property var _models//: [null,null]
    property var _manager: null
    property string defaultFormatDatetime: "dd/MM/yy hh:mm:ss"
    property string defaultFormatDate: "dd/MM/yy"
    property real defaultColWidth: 100
    property string viewName: ""//name tryton model="ir.ui.view", type tree
    property bool isPresedExpand: false
    property var _repeaterHead: null
    property bool buttonRestart: true
    property var _defaultFilters: [{"field":"id","fieldalias":"ID","type":"numeric"}]
    property var filtersRecName: []//expand rec_name from client, idea for discuss
    property var filters: []
    property string placeholderText: "" ////expand rec_name from client
    signal doubleClick(int id)
    signal clicked(int id)
    Component.onCompleted: {
        for(var i=0,len=listHead.length;i<len;i++){
            fields.push(listHead[i].name);
            if(listHead[i].type==='numeric'){
                fieldsFormatDecimal.push(listHead[i].name);
            }
            if(listHead[i].type==='many2one'){
                fields.push(listHead[i].name+".rec_name");
            }
            if(listHead[i].type==='datetime' || listHead[i].type==='date'){
                if(listHead[i].hasOwnProperty("format")){
                    var format = listHead[i].format;
                }else{
                    if(listHead[i].type==='datetime'){
                        format = defaultFormatDatetime;
                    }else{
                        format = defaultFormatDate;
                    }
                }
                fieldsFormatDateTime.push([listHead[i].name, format]);
            }
        }
        _initModel();
        if(activeStates==true && modelStates.length>0){
            domainState = modelStates[0].name===""?[]:["state","=",modelStates[0].name];
        }
        initOrder = JSON.parse(JSON.stringify(order));
        initTextOrderHead();
        //filters
        _defaultFilters=_defaultFilters.concat(filters);
        filterin.setFilters(_defaultFilters);

        if(filtersRecName.length>0){
            filterin._defaultFilterRecName = filtersRecName;
        }
        if(placeholderText!=""){
            filterin.placeholderText=placeholderText;
        }
    }

    function initTextOrderHead(){
        var mapOrder={};
        for (var i=0, len=order.length;i<len;i++){
            mapOrder[order[i][0]]=order[i][1];
        }
        _repeaterHead.setTextInitOrder(mapOrder);
    }

    function updateRecords(ids){
        _models.model.updateRecords(ids);
       listview.reloadItem();
    }

    function setOrder(headOrder){//{"head":"","type": none, asc, desc
        var mapOrder={};
        for (var i=0, len=order.length;i<len;i++){
            mapOrder[order[i][0]]=order[i][1];
        }
        if (mapOrder.hasOwnProperty(headOrder.head)===false){
            if(headOrder.type !== null){
                order.unshift([headOrder.head, headOrder.type])
            }
        }else{
            var _norder=[];
            for (i=0, len=order.length;i<len;i++){ //[['invoice_date','DESC']]
                if (headOrder.head === order[i][0]){
                    if (headOrder.type !== null){
                        _norder.unshift([headOrder.head, headOrder.type]);
                    }
                }else{
                    _norder.push(order[i]);
                }
            }
            order = _norder;
        }
        _models.model.setOrder(order)
        find(filterin._getData());
    }

    function loadFieldsFromModel(){

    }

    function find(data){
        var domainplus = ['AND'];
        domainplus.push(domain);
        if(data==null){
            data=[];
        }
        if(data.length>0){
            domainplus.push(data);
        }
        domainplus.push([domainState]);
        _models.model.find(domainplus);
    }

    function _initModel(){
        _models = ModelManagerQml.addModel("_model"+_getNewNumber(), "_proxymodel"+_getNewNumber());
        if(_models.hasOwnProperty("model")){
            _models.model.setLanguage(planguage);
            _models.model.setModelMethod("model."+modelName);
            _models.model.setDomain(domain);
            _models.model.setMaxLimit(limit);
            _models.model.setOrder(order)
            _models.model.setFields(fields);
            _models.model.setPreferences(preferences);
            _models.model.addFieldFormatDecimal(fieldsFormatDecimal);// config .setLanguage(planguage);
            _models.model.addFieldFormatDateTime(fieldsFormatDateTime);//:
        }
    }

    function getIds(){
        var ids=[];
        var cindex = listview.currentIndex;
        if(multiSelectItems){
            for(var i=0,len=listview.count;i<len;i++){
                listview.currentIndex=i;
                if(listview.currentItem.isSelect()){
                    ids.push(listview.currentItem.getId());
                }
            }
            listview.currentIndex=cindex;
        }else{
            if(cindex!=-1){
                ids.push(listview.currentItem.getId());
            }
        }
        return ids;
    }

    function getId(){
        if(listview.currentIndex!=-1){
            return listview.currentItem.getId();
        }
        return -1;
    }



    function getObject(){
        if(listview.currentIndex!=-1){
            return listview.currentItem.getObject();
        }
        return {}
    }

    function _filterClear(){
        filterin.clear();
    }

    function _restart(){
        order = JSON.parse(JSON.stringify(initOrder));
        initTextOrderHead();
        _models.model.setOrder(order);
        find([]);
    }

    ButtonGroup {
        id: childGroup
        exclusive: false
    }
    Item{
        id:filsta
        width: parent.width
        height: ifilter.height+barStates.height
        Item {
            id: ifilter
            width: parent.width
            height: activeFilters?heightFilter:0
            visible: activeFilters
            z:12
            FiltersInput{
                id:filterin
                anchors.fill: parent
                buttonRestart:control.buttonRestart
                onExecuteFind:{
                    find(domain)
                }
                onDown:{
                    listview.forceActiveFocus();
                }
                onExecuteRestart:{
                    filterin.clear();
                    _restart();
                }
            }

        }
        TabBar{
            id:barStates
            width: parent.width
            visible:activeStates
            height: visible?heightStates:0
            anchors.top: ifilter.bottom
            clip:true
            Repeater {
                model: modelStates
                TabButton {
                    text: modelData.alias
                    width: 150
                    implicitHeight: heightStates
                    property bool booldife: false
                    onPressed: {
                        if(index == barStates.currentIndex){
                            booldife=true;
                        }
                    }
                    onClicked: {
                       if(booldife){
                           domainState = modelData.name===""?[]:["state","=",modelData.name];
                           find(filterin._getData());
                           booldife=false;
                       }
                    }
                }
            }
            onCurrentIndexChanged: {
                var mindex = barStates.currentIndex;
                if (mindex!==-1 && activeStates==true && (modelStates.length > 0)){
                    domainState = modelStates[mindex].name===""?[]:["state","=",modelStates[mindex].name];
                    if(_models!=null){
                        find(filterin._getData());
                    }
                }
            }
        }
    }

    Repeater {
        id: rep_column
        model: listHead
        Item {
            property real value: modelData.width
        }
    }
    ListView{
        id:listview
        anchors{fill: parent;topMargin: filsta.height+2}
        clip: true
        focus: true
        model:_models.model//proxy
        cacheBuffer: _cacheBuffer//contentHeight+heightField
        delegate: pdelegate
        ScrollBar.vertical: ScrollBar {policy: listview.contentHeight > height?ScrollBar.AlwaysOn:ScrollBar.AlwaysOff}
        ScrollBar.horizontal: ScrollBar {policy: listview.contentWidth > width?ScrollBar.AlwaysOn:ScrollBar.AlwaysOff}
        flickableDirection: Flickable.AutoFlickIfNeeded
        contentWidth: headerItem.width
        //keyNavigationWraps: true

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

        header:  Row{
            id:iph
            z:8
            //anchors{fill: parent;margins: 0}
            Rectangle{
                width: multiSelectItems?0:1
                height: heightHeader
                visible: !multiSelectItems
                color: mainroot.Material.accent
            }

            Row {
            id:mHeaderView
            z:8
            height: heightHeader
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
                Component.onCompleted: _repeaterHead=repeater
                model: listHead
                function setTextInitOrder(morder){
                    for(var i=0, len=listHead.length;i<len;i++){
                        if (morder.hasOwnProperty(listHead[i].name)){
                            repeater.itemAt(i).setTextOrder(morder[listHead[i].name])
                        }else{
                            repeater.itemAt(i).setTextOrder(null);
                        }
                    }
                }
                Label {
                    id:mll
                    text: modelData.alias
                    font.bold: true
                    width:  modelData.width<=20?20:modelData.width
                    height: heightHeader
                    elide: Label.ElideRight
                    padding: 4
                    background: Rectangle {color:mainroot.Material.accent }//Qt.lighter(mainroot.Material.accent)
                    horizontalAlignment: modelData.align
                    verticalAlignment: Label.AlignVCenter
                    z:100-index
                    Component.onCompleted: {
                        //width = Qt.binding(function(){var it=rep_column.itemAt(index); return it.value})
                    }
                    function setTextOrder(htype){
                        var text = "\uf141";
                        if(htype == "ASC"){
                            text = "\uf0d8";
                        }
                        if(htype == "DESC"){
                            text = "\uf0d7"
                        }
                        tbascdesc.text=text;
                    }

                    Rectangle{
                        id:rec_shadow
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
                        onEntered:  {rec_shadow.visible=true;rec_view_exp.width=2}
                        onExited:  {rec_shadow.visible=false;rec_view_exp.width=1}
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
                            height: listview.height
                            color: "grey"
                            visible: ma.pressed?1:0
                        }

                        MiniButton{
                            id:tbascdesc
                            anchors{right: parent.right;rightMargin: 2;verticalCenter: parent.verticalCenter}
                            width: height-12
                            height: parent.height+ 8
                            text: "\uf141"
                            font.pixelSize:16
                            visible: rec_shadow.visible
                            ToolTip.visible: false
                            onClicked: menu_order.open()
                            Menu {
                                id: menu_order
                                x: parent.width - width
                                y: parent.height
                                width: 40
                                padding: 0
                                transformOrigin: Menu.BottomRight
                                MenuItem {
                                    id: mi1
                                    width: 40
                                    height: 30
                                    contentItem:Text{
                                        text: "\uf141"
                                        font.family: fawesome.name
                                        font.italic: false
                                        color: mi1.down ? Material.hintTextColor:Material.primaryTextColor
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter

                                    }
                                    onTriggered: {
                                        var virtual = false;
                                        if (modelData.hasOwnProperty("virtual")){
                                            virtual = modelData.virtual;
                                        }
                                        if(virtual==false){
                                            setOrder({"head":modelData.name, "type":null});
                                            mll.setTextOrder(null);
                                        }
                                    }
                                }
                                MenuItem {
                                    id: mi2
                                    width: 40
                                    height: 30
                                    contentItem:Text{
                                        text: "\uf0d8 \uf15d"
                                        font.family: fawesome.name
                                        font.italic: false
                                        color: mi2.down ? Material.hintTextColor:Material.primaryTextColor
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter

                                    }
                                    onTriggered: {
                                        var virtual = false;
                                        if (modelData.hasOwnProperty("virtual")){
                                            virtual = modelData.virtual;
                                        }
                                        var fieldNameg=modelData.name;
                                        if(modelData.type=="many2one"){
                                            virtual = true;
                                        }
                                        if(virtual==false){setOrder({"head":fieldNameg, "type":"ASC"});mll.setTextOrder("ASC");}
                                    }
                                }
                                MenuItem {
                                    id: mi3
                                    width: 40
                                    height: 30
                                    contentItem:Text{
                                        text: "\uf0d7 \uf881"
                                        font.family: fawesome.name
                                        font.italic: false
                                        color: mi3.down ? Material.hintTextColor:Material.primaryTextColor
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter

                                    }
                                    onTriggered: {
                                        var virtual = false;
                                        if (modelData.hasOwnProperty("virtual")){
                                            virtual = modelData.virtual;
                                        }
                                        var fieldNameg=modelData.name;
                                        if(modelData.type=="many2one"){
                                            virtual = true;
                                        }
                                        if(virtual==false){setOrder({"head":fieldNameg, "type":"DESC"});mll.setTextOrder("DESC");}
                                    }
                                }
                            }

                        }
                    }
                }
            }
        }
            Rectangle{
                width: multiSelectItems?0:1
                height: heightHeader
                visible: !multiSelectItems
                color: mainroot.Material.accent
            }
        }
        headerPositioning:ListView.OverlayHeader
        onContentYChanged: {
            if (atYEnd){
                if(parseFloat(contentY).toFixed(5) == contentHeight - (height+heightHeader)){
                    _models.model.nextSearch();
                }
            }
        }
    }

    function finditemsField(ite){
        var result=[];
        for(var i = 0, len=ite.length;i<len;i++){
            var result2 = [];
            if(typeof ite[i].isField !== "undefined"){
                if(ite[i].isField == true){
                    result.push(ite[i]);
                }
            }
            if(ite[i].children.length>0){
                result2 = finditemsField(ite[i].children);
                result=result.concat(result2);
            }
        }
        return result;
    }

    Component{
        id:pdelegate
        ItemDelegate {
            id:itdele
            width: listview.contentWidth
            height: heightField
            property bool selectItem: false
            // property bool completed: false
            property var myobject: JSON.parse(JSON.stringify(object.json))// performance PySide
            function isSelect(){
                return selectItem;
            }
            function getId(){
                return myobject.id;
            }
            function checkItem(){
                selectItem = true;
            }
            function getObject(){
                return myobject;
            }

            function reloadItem(){//update
                myobject = JSON.parse(JSON.stringify(object.json));
                var itemstoreload = finditemsField(itdele.contentItem.children);
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
                                    width:  modelData.width//==-1?paintedWidth+20:modelData.width
                                    height: heightField
                                    maximumLineCount: control.maximumLineCount
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: modelData.align
                                    fontSizeMode: Text.Fit
                                    minimumPixelSize: 10
                                    padding: 4
                                    wrapMode: Label.Wrap

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
                                        if(myobject[modelData.name]===null){
                                            return "";
                                        }
                                        switch(type){
                                        case 'text':
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
                                        case 'numeric':
                                            return myobject[modelData.name+"_format"];
                                        case 'datetime':
                                            return myobject[modelData.name+"_format"];
                                        case 'date':
                                            return myobject[modelData.name+"_format"];
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
                                            if(myobject[modelData.name+".rec_name"]===null){
                                                return "";
                                            }
                                            return myobject[modelData.name+".rec_name"];
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
                listview.forceActiveFocus();
                listview.currentIndex = model.index;
                //check only this item
                childGroup.checkState=Qt.Unchecked;
                tcheckitem.restart();
                control.clicked(myobject.id);
            }
            onDoubleClicked: {
                listview.forceActiveFocus();
                listview.currentIndex = model.index;
                //check only this item
                childGroup.checkState=Qt.Unchecked;
                tcheckitem.restart();
                doubleClick(myobject.id)
            }

            Keys.onPressed: {
                if (event.key === Qt.Key_Return ) {
                    event.accepted = true;
                    listview.currentIndex = model.index;
                    childGroup.checkState=Qt.Unchecked;
                    tcheckitem.restart();
                    doubleClick(myobject.id)

                }
                if (event.key === Qt.Key_Enter ) {
                    event.accepted = true;
                    listview.currentIndex = model.index;
                    childGroup.checkState=Qt.Unchecked;
                    tcheckitem.restart();
                    doubleClick(myobject.id)

                }
            }
        }
    }

    Timer{
        id:tcheckitem
        interval: 120
        onTriggered: {
            if(listview.currentIndex!=-1){
                listview.currentItem.checkItem();
            }
        }
    }
}
