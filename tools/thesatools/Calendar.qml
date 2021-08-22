//this file is part the thesa: tryton client based PySide2(qml2)
// tools Calendar, need to functions tools.calendar
//__author__ = "Numael Garay"
//__copyright__ = "Copyright 2020-2021"
//__license__ = "GPL"
//__version__ = "1.1.0"
//__maintainer__ = "Numael Garay"
//__email__ = "mantrixsoft@gmail.com"

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3

Item {
    id:mainCaDes
    width: gdays.width
    height: ibody.height+barra.height
    property real widthGrid: 28
    property real heightGrid: 30
    //property real heightBarra: 20
    property int fontPixel: 16

    property bool boolFocus: false

    property int currentDay: 1
    property int currentYear: 2020
    property int currentMonth: 1
    property bool boolFitText: true
    property var namesDays: []
    property var namesMonths: []
    property bool boolEscChangue: false

    signal clickDay( date datesis)

    Keys.onPressed: {
        if (event.key == Qt.Key_Back) {
            signalClose();
            event.accepted = true;
        }
        if (event.key == Qt.Key_Escape) {
            signalClose();
            event.accepted = true;
        }

    }
    signal signalClose();
    Component.onCompleted: {
        calculateCurrentDate();
        loadNames();
        reload();
    }

    function forceF(){
        inputYear.forceActiveFocus()
    }
    function calculateCurrentDate(){
        var dataNow = new Date();
        currentDay = dataNow.getDate();
        currentMonth = dataNow.getMonth()+1;
        currentYear = dataNow.getFullYear();
    }
    function hayFoco(){

        return false;
    }
    function enterYear(){
        currentYear=inputYear.text;
        reload();
    }
    function back(){
        if(currentMonth==1){
            currentYear-=1;
            currentMonth=12;
        }else{
            currentMonth-=1;
        }
        reload();
    }
    function forward(){
        if(currentMonth==12){
            currentYear+=1;
            currentMonth=1;
        }else{
            currentMonth+=1;
        }
        reload();
    }

    function checkYear(){
        var texto = inputYear.text.toString();
        if(texto.length<4){
            inputYear.text=currentYear.toString();
        }
    }
    function loadNames(){
        namesDays = nameShortDays;//Tools.calendarNamesDays()
        namesMonths = nameLongMonths;//Tools.calendarNamesMonths()
    }

    ListModel{
        id:modelmonth
    }

    function setDate(year,month){
        currentMonth=month;
        currentYear=year;
        reload();
    }
    property int indexCurrentDay: -1

    function checkCurrentDay(){
        if(indexCurrentDay!=-1){
            gdays.currentIndex = indexCurrentDay;
            gdays.currentItem.isCurrentDay = true;
        }
    }

    function reload(){
        modelmonth.clear()
        indexCurrentDay = -1;
        var dataNow = new Date();
        var _currentMonth = dataNow.getMonth()+1;
        var _currentYear = dataNow.getFullYear();
        var lista = Tools.calendarMonth(currentYear, currentMonth);
        for(var i = 0, len = lista.length; i < len; i++){
            modelmonth.append(lista[i]);
            if(lista[i].dia == currentDay){
                if(_currentMonth==currentMonth && _currentYear==currentYear && lista[i].type==0){
                    indexCurrentDay = i;
                }
            }
        }
        nameMonth.text=namesMonths[currentMonth-1];
        boolEscChangue=true;
        inputYear.text=currentYear;
        boolEscChangue=false;
        checkCurrentDay();
    }

    Item{
        id:barra
        width: gdays.width
        height: inputYear.height
        anchors{top:parent.top}

        Button{
            id:bleft
            width: height-dpis*4
            height: parent.height
            anchors{left: parent.left;}
            onClicked: {back()}
            //display: Button.TextOnly
            font.family: fawesome.name
            font.italic: false
            font.pixelSize: 18
            text: "\uf104"
        }

        Button{
            id:bright
            width: height-dpis*4
            height: parent.height
            anchors{right: parent.right;}
            onClicked: {forward()}
            //display: Button.TextOnly
            font.family: fawesome.name
            font.italic: false
            font.pixelSize: 18
            text: "\uf105"
        }

        Text{
            id:nameMonth
            width: parent.width-bleft.width-inputYear.width-bright.width-dpis// - (dpis*2)
            height: parent.height
            anchors{left: bleft.right;leftMargin: 0}
            font.italic: true
            font.pixelSize: 20
            minimumPixelSize: 6
            fontSizeMode: Text.Fit
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            color: inputYear.Material.primaryTextColor
        }

        Text{
            id: textWidth
            text:"2222"
            width: paintedWidth
            height: parent.height
            anchors{left: nameMonth.right;}
            font.pixelSize: fontPixel
            verticalAlignment: TextInput.AlignVCenter
            horizontalAlignment: TextInput.AlignHCenter
            visible: false
        }

        TextField{
            id: inputYear
            width: textWidth.width
            //height: parent.height
            placeholderText: qsTr("yyyy")
            anchors{right: bright.left; rightMargin: dpis;}
            mouseSelectionMode: TextInput.SelectWords
            selectByMouse: true
            font.pixelSize: fontPixel
            verticalAlignment: TextInput.AlignVCenter
            horizontalAlignment: TextInput.AlignHCenter
            clip:true
            activeFocusOnPress: true
            onTextChanged: {
                if(boolEscChangue==false){
                    if(text.toString().length>3){
                        enterYear();
                    }
                }
            }
            onFocusChanged: {
                if(focus==true){
                    boolFocus=true;
                    selectAll();
                }else{
                    checkYear();
                }
            }
            validator: RegExpValidator { regExp:/^(19|20|21)\d\d$/}
            Keys.onPressed: {
                if (event.key === Qt.Key_Enter){
                    event.accepted = true;
                    checkYear();
                    enterYear();
                }
                if (event.key === Qt.Key_Return){
                    event.accepted = true;
                    checkYear();
                    enterYear();
                }
                if (event.key === Qt.Key_Up){
                    event.accepted = true;
                    var x = parseInt(text);
                    if(x<2199){
                        x+=1;
                        text = x;
                    }
                    checkYear();
                    selectAll();
                    enterYear();
                }
                if (event.key === Qt.Key_Down){
                    event.accepted = true;
                    var xd = parseInt(text);
                    if(xd>1){
                        xd-=1;
                        text = xd;
                    }
                    checkYear();
                    enterYear();
                    selectAll();
                }
                if (event.key === Qt.Key_Escape ){
                    event.accepted = true;
                }
                if (event.key === Qt.Key_Tab ){
                    event.accepted = true;
                    checkYear();
                    enterYear();
                }
            }
        }
    }
    Item{
        id:ibody
        width: gdays.width
        height:gdays.height+rownamesDays.height
        anchors{bottom: parent.bottom}

        Row{
            id:rownamesDays
            width: gdays.width
            height: dpis*4
            anchors{top: parent.top;}
            Repeater{
                model:7
                Item{
                    width: rownamesDays.width/7
                    height: rownamesDays.height
                    Rectangle{
                        anchors{fill: parent;margins: 0.5}
                        color: mainroot.Material.accent
                    }
                    Text{
                        anchors{fill: parent;margins: 0.5}
                        text: namesDays[index]
                        font.pixelSize: dpis*3
                        minimumPixelSize: 6
                        fontSizeMode: Text.Fit
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        color: inputYear.Material.primaryTextColor
                    }
                }
            }
        }

        GridView{
            id:gdays
            width: cellWidth*7
            height: cellHeight*6
            cellWidth: widthGrid
            cellHeight: heightGrid
            anchors{bottom: parent.bottom;}
            delegate: ItemDelegate {
                id:idele
                width: gdays.cellWidth
                height: gdays.cellHeight
                text: dia
                font.bold: true
                font.pixelSize: fontPixel
                property bool isCurrentDay: false
                contentItem: Item{
                    anchors.fill: parent
                    Rectangle{
                        id:ibase
                        anchors{fill: parent;margins: 0.5}
                        color: isCurrentDay?mainroot.Material.accent:"transparent"
                    }
                    Text {
                        id:texto
                        width: idele.width
                        height: idele.height
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 3
                        text: idele.text
                        font: idele.font
                        color: type==0?mainroot.Material.primaryTextColor:mainroot.Material.accent
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        anchors{centerIn: parent}
                    }
                }
                onClicked: {
                    clickDay(new Date (anno,mes-1,dia));
                }
            }
            model:modelmonth
            clip: true

        }
    }
}
