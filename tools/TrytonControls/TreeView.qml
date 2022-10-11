//this file is part the thesa: tryton client based PySide2(qml2)
// view tree
//__author__ = "Numael Garay"
//__copyright__ = "Copyright 2020-2022"
//__license__ = "GPL"
//__version__ = "1.8.0"
//__maintainer__ = "Numael Garay"
//__email__ = "mantrixsoft@gmail.com"

import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import "../thesatools"
import "../thesatools/messages.js" as MessageLib
import "../thesatools/conections.js" as ConectionLib
//TODO  add type button, type ext file

Control{
    id:control
    //    implicitWidth: 100
    //    implicitHeight: 100
    property bool activeFilters: true
    property bool activeStates: false
    property var modelStates: []//[{"name":"draft", "alias":"Borrador"}]
    property var domainState: []
    property string filterState: "state"
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
    property real widthStates: 150
    // property real heightStates: 40
    property bool verticalLine: true
    property bool horizontalLine: true
    property bool multiSelectItems: true
    property var listHead: []
    //    property bool useTableView: true

    //    property var fields: []
    property var fieldsFormatDecimal: []
    property var fieldsFormatDateTime: []

    property int maximunItemView: 10000//config
    property int _cacheBuffer: maximunItemView*heightField
    //    property var order: []
    property var initOrder: []

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

    property var domain:[]
    property var domainFind: []
    property int limit: 100
    property var order:[]// [['name', 'ASC']]
    property var fields:[]// ["rec_name", "name", "lang", "phone"]
    property int _count: -1
    property var context: ({})
    property string modelName: ""
    property var _hashIndexOfId: ({})
    property var _fieldsPoint: []

    Component.onCompleted: {
        for(var i=0,len=listHead.length;i<len;i++){
            fields.push(listHead[i].name);
            if(listHead[i].name.indexOf(".")!=-1){
                _fieldsPoint.push(listHead[i].name);
            }
            if(listHead[i].type==='numeric' || listHead[i].type==='float'){
                var decimals = 2;
                if(listHead[i].hasOwnProperty("decimals")){//warning quantity
                    decimals = listHead[i].decimals;
                }
                fieldsFormatDecimal.push([listHead[i].name, decimals]);
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
                //                fieldsFormatDateTime.push([listHead[i].name, format]);
            }
        }

        //        _initModel();
        if(activeStates==true && modelStates.length>0){
            domainState = modelStates[0].name===""?[]:[filterState,"=",modelStates[0].name];
        }
        initOrder = JSON.parse(JSON.stringify(order));
        initTextOrderHead();
        //        //filters
        _defaultFilters=_defaultFilters.concat(filters);
        filterin.setFilters(_defaultFilters);

        if(filtersRecName.length>0){
            filterin._defaultFilterRecName = filtersRecName;
        }
        if(placeholderText!=""){
            filterin.placeholderText=placeholderText;
        }
        if(modelStates.length==0){
            activeStates=false
        }else{
            activeStates=true
        }

    }


    function initTextOrderHead(){
        var mapOrder={};
        for (var i=0, len=order.length;i<len;i++){
            mapOrder[order[i][0]]=order[i][1];
        }
        _repeaterHead.setTextInitOrder(mapOrder);
    }
    //prevent false shadow on the head
    function shadowOff(){
        _repeaterHead.shadowOff();
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
        //        _models.model.setOrder(order)
        find(filterin._getData());
    }

    function loadFieldsFromModel(){

    }

    function _forceActiveFocus(){
        listview.forceActiveFocus();
    }

    ///////////////////
    ListModel{
        id:mymodel
    }

    function getDataModel(){
        var data=[];
        for(var i=0,len=mymodel.count; i<len;i++){
            data.push(mymodel.get(i));
        }
        return data;
    }

    function _find(dom){
        domainFind = dom;
        initSearch(-1);
    }

    function initSearch(maxlimit){
        ids_temp=[];
        mymodel.clear();
        _count = 0;
        _hashIndexOfId={};
        nextSearch(maxlimit);
    }

    //TODO
    function _recusivepoint(doc){
        for(var i=0, len=_fieldsPoint.length;i<len;i++){
            var list_names = _fieldsPoint[i].split(".");
            for(var j=0, lenj=list_names.length-1;j<lenj;j++){
                list_names[j]=list_names[j]+".";
            }
            var temp =doc[list_names[0]];
            for(var jj=1, lenjj=list_names.length;jj<lenjj;jj++){
                if(temp!="undefined" && temp!=null){
                    if(temp[list_names[jj]]!="undefined"){
                        temp = temp[list_names[jj]];
                    }
                }
            }
            doc[_fieldsPoint[i]]=temp;
        }
        return doc;
    }

    function checkData(list_data){
        var new_list_data=[];
        if(setting.typelogin===0){
            return list_data;
        }else{
            if(_fieldsPoint.length<=0){
                return list_data;
            }else{
                for(var i=0, len=list_data.length;i<len;i++){
                    new_list_data.push(_recusivepoint(list_data[i]));
                }
            }
        }
        return new_list_data;
    }

    function addResult(result, update){
        var data_check = checkData(result);
        for(var i=0, len=data_check.length;i<len;i++){
            if(update==false){
                mymodel.append({"id":result[i]["id"], "json":result[i]});
                _hashIndexOfId[result[i].id] = _count;
                _count+=1;
            }else{
                var index = _hashIndexOfId[result[i]["id"]];
                if (index!="undefined" || index!=null || index>-1){
                    if(mymodel.count>=index){
                        mymodel.set(index,{"id":result[i]["id"], "json":result[i]});
                        listview.reloadIndex(index);
                    }
                }
            }
        }
    }

    function nextSearch(maxlimit){
        openBusy();
        var methodlocal="model."+modelName+".search_read";
        var step = limit;
        if(maxlimit!=-1){
            limit = maxlimit;
        }
        var paramslocal=[domainFind, _count, step, order, fields, contextPreferences(context)];

        //        var params = prepareParams();
        var params = prepareParamsLocal(methodlocal, paramslocal);
        var url = getUrl();
        var http = getHttpRequest(url, params, "");

        http.onreadystatechange = function() { // Call a function when the state changes.
            if (http.readyState == 4) {
                if (http.status == 200) {
                    closeBusy();
                    var response = JSON.parse(http.responseText.toString());
                    if(response.hasOwnProperty("result")){
                        addResult(response["result"], false);
                    }else{
                        analizeErrors(response);
                    }

                } else {
                    analizeErrorsStatus(http.status);
                    closeBusy();
                }
            }
        }
        http.send(JSON.stringify(params));
    }
    /////////////////////
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
        //        _models.model.find(domainplus);
        _find(domainplus);
    }

    function updateRecords(ids){
        if(ids.length>0){
            _updateRecords(ids);
        }
    }
    function _updateRecords(ids){
        openBusy();
        var methodlocal="model."+modelName+".read";
        var paramslocal=[ids, fields, contextPreferences(context)];
        var params = prepareParamsLocal(methodlocal, paramslocal);
        var url = getUrl();
        var http = getHttpRequest(url, params, "");

        http.onreadystatechange = function() { // Call a function when the state changes.
            if (http.readyState == 4) {
                if (http.status == 200) {
                    closeBusy();
                    var response = JSON.parse(http.responseText.toString());
                    if(response.hasOwnProperty("result")){
                        addResult(response["result"], true);

                    }else{
                        analizeErrors(response);
                    }

                } else {
                    analizeErrorsStatus(http.status);
                    closeBusy();
                }
            }
        }
        http.send(JSON.stringify(params));
    }

    function updateHashIndexes(){
        _hashIndexOfId={}
        _count=0;
        for(var i=0, len = mymodel.count;i<len;i++){
            _hashIndexOfId[mymodel.get(i).id]=_count;
            _count+=1;
        }
    }

    function _removeItems(ids){
        var indexes = [];
        for(var i=0, len=ids.length;i<len;i++){
            var index = _hashIndexOfId[ids[i]];
            if (index!="undefined" || index!=null || index>-1){
                indexes.push(index);
            }
        }
        indexes.sort(function(a, b) {
            return b - a;
        });
        for( i=0, len=indexes.length;i<len;i++){
            mymodel.remove(indexes[i]);
        }
        if(ids.length==0){
            //get position view
            find(domain);
        }
        updateHashIndexes();

    }

    property var ids_temp: []
    function removeItems(){
        var ids = getIds();
        ids_temp=ids;
        if(ids.length>0){
            var methodlocal="model."+modelName+".delete";
            var paramslocal=[ids, contextPreferences(context)];
            var params = prepareParamsLocal(methodlocal, paramslocal);

            ConectionLib.jsonRpcAction(control,params,context,
                                       "control._removeItemsOk(response)",
                                       "control._removeItemsBack()",
                                       "control._removeItemsError()");
        }
    }
    function _removeItemsOk(response){
        MessageLib.showToolTip(qsTr("Removed"),16,3000,"white","red", mainroot);
        _removeItems(ids_temp)
    }
    function _removeItemsBack(){
        ids_temp=[];
    }
    function _removeItemsError(){
        ids_temp=[];
    }


    function removeItemsLast(){
        var ids = getIds();
        if(ids.length>0){
            var methodlocal="model."+modelName+".delete";

            var paramslocal=[ids, contextPreferences(context)];

            //        var params = prepareParams();
            var params = prepareParamsLocal(methodlocal, paramslocal);
            var url = getUrl();
            var http = getHttpRequest(url, params, "");

            http.onreadystatechange = function() { // Call a function when the state changes.
                if (http.readyState == 4) {
                    if (http.status == 200) {
                        closeBusy();
                        var response = JSON.parse(http.responseText.toString());
                        if(response.hasOwnProperty("result")){
                            MessageLib.showToolTip(qsTr("Removed"),16,3000,"white","red", mainroot);
                            _removeItems(ids)
                        }else{
                            analizeErrors(response);
                        }

                    } else {
                        analizeErrorsStatus(http.status);
                        closeBusy();
                    }
                }
            }
            http.send(JSON.stringify(params));
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
        if(multiSelectItems){
            var cindex = listview.currentIndex;
            if(cindex!=-1){
                listview.currentIndex=cindex;
                if(listview.currentItem.isSelect()){
                    return listview.currentItem.getId();
                }
            }
            for(var i=0,len=listview.count;i<len;i++){
                listview.currentIndex=i;
                if(listview.currentItem.isSelect()){
                    return listview.currentItem.getId();
                }
            }
        }else{
            if(listview.currentIndex!=-1){
                return listview.currentItem.getId();
            }
        }

        return -1;
    }

    function getFirstId(){
        if(listview.count>0){
            listview.currentIndex=0;
            listview.currentItem.checkItem();
            return listview.currentItem.getId();
        }
        return -1
    }

    function getIdOrFisrt(){
        var mid = getId();
        if(mid!=-1){
            return mid
        }else{
            return getFirstId();
        }
    }

    function getCurrentId(){
        return listview.currentItem.getId();
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

    function _initIndex(){
        if(multiSelectItems){
            for(var i=0,len=listview.count;i<len;i++){
                listview.currentIndex=i;
                listview.currentItem.unCheckItem();
            }
        }
        listview.currentIndex=-1;

    }

    function _restart(){
        order = JSON.parse(JSON.stringify(initOrder));
        initTextOrderHead();
        //        _models.model.setOrder(order);
        //find([]);
        timerfindblank.restart();
    }

    Timer{
        id:timerfindblank
        interval: 200
        onTriggered: {
            find([]);
        }
    }

    Timer{
        id:timerfind
        interval: 180
        onTriggered: {
            find(filterin._getData());
        }
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
                    width: widthStates
                    implicitHeight: heightStates
                    property bool booldife: false
                    onPressed: {
                        if(index == barStates.currentIndex){
                            booldife=true;
                        }
                    }
                    onClicked: {
                        if(booldife){
                            domainState = modelData.name===""?[]:[filterState,"=",modelData.name];
                            //                           find(filterin._getData());
                            timerfind.restart();
                            booldife=false;
                        }
                    }
                }
            }
            onCurrentIndexChanged: {
                var mindex = barStates.currentIndex;
                if (mindex!==-1 && activeStates==true && (modelStates.length > 0)){
                    domainState = modelStates[mindex].name===""?[]:[filterState,"=",modelStates[mindex].name];
                    //if(_models!=null){
                    //                        find(filterin._getData());
                    timerfind.restart();
                    // }
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
        model:mymodel//_models.model//proxy
        cacheBuffer: _cacheBuffer//contentHeight+heightField
        delegate: pdelegate
        ScrollBar.vertical: ScrollBar {policy: listview.contentHeight > height?ScrollBar.AlwaysOn:ScrollBar.AlwaysOff}
        ScrollBar.horizontal: ScrollBar {policy: listview.contentWidth > width?ScrollBar.AlwaysOn:ScrollBar.AlwaysOff}
        flickableDirection: Flickable.HorizontalAndVerticalFlick//isMobile?Flickable.HorizontalAndVerticalFlick:Flickable.AutoFlickIfNeeded
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

        function reloadIndex(index){
            if(index!=-1){
                listview.currentIndex = index;
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
                    function shadowOff(){
                        for(var i=0, len=listHead.length;i<len;i++){
                            repeater.itemAt(i).shadowOff();
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
                        function shadowOff(){
                            rec_shadow.visible=false;
                            rec_view_exp.width=1;
                        }

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
                                            if(modelData.type=="many2one" || modelData.type=="one2many"){
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
                                            if(modelData.type=="many2one" || modelData.type=="one2many"){
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
        headerPositioning:isMobile?ListView.InlineHeader:ListView.OverlayHeader
        //TODO: create new header for mobile
        onContentYChanged: {
            if (atYEnd){
                if(parseFloat(contentY).toFixed(5) == contentHeight - (height+heightHeader)){
                    nextSearch(-1);
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
            //            property var myobject: JSON.parse(JSON.stringify(object.json))// performance PySide
            property var myobject: listview.model.get(index)
            function isSelect(){
                return selectItem;
            }
            function getId(){
                return myobject.id;
            }
            function checkItem(){
                selectItem = true;
            }
            function unCheckItem(){
                selectItem = false;
            }
            function getObject(){
                var fields = myobject.json;
                fields.id = myobject.id
                return fields;
            }

            function reloadItem(){//update
                myobject = listview.model.get(index)//JSON.parse(JSON.stringify(object.json));
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
                            onClicked: {
                                listview.currentIndex = index;
                                control.clicked(myobject.id);
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
                                            if(myobject["json"][modelData.name] !== null){
                                                if(myobject["json"][modelData.name]["__class__"] === "bytes"){
                                                    imageQmlObject.source = "data:image/"+modelData.format+";base64,"+myobject["json"][modelData.name]["base64"];
                                                }else{
                                                    imageQmlObject.source="";
                                                }
                                            }else{
                                                imageQmlObject.source="";
                                            }
                                        }else{
                                            text = parseData(modelData.type);//.toString();
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
                                        if(myobject["json"][modelData.name]===null){
                                            return "";
                                        }
                                        switch(type){
                                        case 'text'://

                                            if(typeof myobject["json"][modelData.name] == 'string'||typeof myobject["json"][modelData.name] == 'number'){
                                                return myobject["json"][modelData.name];
                                            }else{// WARNING this should not happen, use type numeric or date
                                                if(typeof myobject["json"][modelData.name] === 'object'){
                                                    if (Array.isArray(myobject["json"][modelData.name])){
                                                        return "("+myobject["json"][modelData.name].length+")";
                                                    }else{
                                                        return parseObject(myobject["json"][modelData.name]);
                                                    }
                                                }else{
                                                    return "";
                                                }
                                            }
                                        case 'integer':
                                            return myobject["json"][modelData.name];
                                        case 'numeric':
                                            var value_de = myobject["json"][modelData.name].decimal;
                                            if(typeof value_de === "undefined"){
                                                value_de = myobject["json"][modelData.name];
                                            }
                                            if(typeof modelData.decimals !== "undefined"){
                                                return myformatDecimalPlaces(value_de, modelData.decimals);
                                            }
                                            return myformatDecimal(value_de);
                                        case 'float':
                                            if(typeof modelData.decimals !== "undefined"){
                                                return myformatDecimalPlaces(myobject["json"][modelData.name], modelData.decimals);
                                            }
                                            return myformatDecimal(myobject["json"][modelData.name]);
                                        case 'datetime':
                                            var format_dt = modelData.format;
                                            if(typeof format_dt === "undefined"){
                                                format_dt = defaultFormatDatetime;
                                            }
                                            var value_dt = myobject["json"][modelData.name];
                                            if(typeof value_dt.hour !== "undefined"){
                                                return Qt.formatDateTime(new Date(value_dt.year, value_dt.month-1, value_dt.day, value_dt.hour, value_dt.minute, value_dt.second), format_dt);
                                            }
                                            if(typeof value_dt.year !== "undefined"){
                                                return Qt.formatDateTime(new Date(value_dt.year, value_dt.month-1, value_dt.day), defaultFormatDatetime);
                                            }
                                            return "";
                                        case 'date':
                                            var format_d = modelData.format
                                            if(typeof format_d === "undefined"){
                                                format_d = defaultFormatDate;
                                            }
                                            var value_d = myobject["json"][modelData.name];
                                            if(typeof value_d.year !== "undefined"){
                                                return Qt.formatDateTime(new Date(value_d.year, value_d.month-1, value_d.day), format_d);
                                            }
                                            return "";
                                        case 'selection':
                                            if(modelData.hasOwnProperty("selectionalias")){
                                                if (modelData.selectionalias.hasOwnProperty(myobject["json"][modelData.name])){
                                                    return modelData.selectionalias[myobject["json"][modelData.name]]
                                                }
                                            }
                                            return myobject["json"][modelData.name];
                                        case 'one2many':
                                            if (Array.isArray(myobject["json"][modelData.name])){
                                                return "("+myobject["json"][modelData.name].length+")";
                                            }
                                            return "";
                                        case 'many2many':
                                            if (Array.isArray(myobject["json"][modelData.name])){
                                                return "("+myobject["json"][modelData.name].length+")";
                                            }
                                            return "";
                                        case 'many2one':
                                            if(myobject["json"][modelData.name]===null || myobject["json"][modelData.name]===-1){
                                                return "";
                                            }
                                            var rnm = "";
                                            if(setting.typelogin===0){
                                                rnm = myobject["json"][modelData.name+".rec_name"];
                                            }else{
                                                rnm = myobject["json"][modelData.name+"."]["rec_name"];
                                            }

                                            if(typeof rnm === "undefined"){
                                                return "";
                                            }
                                            return rnm;
                                        case 'boolean':
                                            if(myobject["json"][modelData.name]==true){
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
