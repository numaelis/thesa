//this file is part the thesa: tryton client based PySide2(qml2)
// tools FieldCalendar, need to functions tools.calendar
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

Item{
    id:mainCa
    width: inputDay.width+sepa1.width+inputMonth.width+sepa2.width+inputYear.width+ bcalendar.width + 6
    height: inputDay.height
    property bool dateInit: true
    property bool boolEscChangueText: false
    property int currentDay: 1
    property int currentMonth: 1
    property int currentYear: 2020
    property string placeholderDay: qsTr("dd");
    property string placeholderMonth: qsTr("mm");
    property string placeholderYear: qsTr("yyyy");
    property string calendarTitle: ""
    property int pixelFont: 16

    signal changueText()
    signal valueEdited()
    signal dateChangedNoCursor(var date)

    Component.onCompleted: {
        checkDateNow();
        if(dateInit){
            loadDateNow();
        }
    }

    function reset(){
        checkDateNow();
        if(dateInit){
            loadDateNow();
        }
    }

    function forceF(){
        inputDay.forceActiveFocus()
    }

    function checkDateNow(){
        var dataNow = new Date();
        currentDay = dataNow.getDate();
        currentMonth = dataNow.getMonth()+1;
        currentYear = dataNow.getFullYear();
    }

    function setNull(){
        boolEscChangueText=true;
        inputDay.focus=false;
        inputDay.text="";
        inputMonth.focus=false;
        inputMonth.text="";
        inputYear.focus=false;
        inputYear.text="";
        boolEscChangueText=false;
        checkDateNow();
    }

    function loadDateNow(){
        boolEscChangueText=true;
        inputDay.text=currentDay.toString();
        inputMonth.text=currentMonth.toString();
        inputYear.text=currentYear.toString();
        checkDay();
        checkMonth();
        boolEscChangueText=false;
        changueText();
    }

    function checkDay(){
        var texto = inputDay.text.toString();
        if(texto==="0" || texto===""){
            texto=currentDay.toString();
        }
        if(texto.length<2){
            inputDay.text="0" + texto;
        }else{
            inputDay.text=texto;
        }
        if(currentDay!==parseInt(inputDay.text)){
            currentDay=parseInt(inputDay.text)
            changueText();
        }
        //revisar mes anno
        adjustDay();
    }
    function adjustDay(){
        var ultimoDia = Tools.calendarLastDay(currentYear,currentMonth);
        if(ultimoDia<currentDay){
            boolEscChangueText=true;
            currentDay = ultimoDia;
            inputDay.text=currentDay.toString();
            changueText();
            boolEscChangueText=false;
        }
    }

    function checkMonth(){
        var texto = inputMonth.text.toString();
        if(texto==="0" || texto===""){
            texto=currentMonth.toString();//importante ser string
        }
        if(texto.length<2){
            inputMonth.text="0" + texto;
        }else{
            inputMonth.text=texto;
        }
        if(currentMonth !== parseInt(inputMonth.text)){
            currentMonth = parseInt(inputMonth.text)
            changueText();
        }
        //revisar dia con el mes y año
        adjustDay();

    }
    function checkYear(){
        var texto = inputYear.text.toString();
        if(texto.length<4){
            inputYear.text=currentYear.toString();
        }
        if(currentYear !== parseInt(inputYear.text)){
            currentYear = parseInt(inputYear.text)
            changueText();
        }
        //revisar dia con mes y año
        adjustDay();
    }

    Timer{
        id:tcursorChangued
        interval: 20
        onTriggered: {
            dateChangedNoCursor(getDate());
        }
    }

    Text{
        id: textWidthYear
        text:inputYear.text==""?placeholderYear:inputYear.text
        width: paintedWidth +3
        height: parent.height
        anchors{left: parent.left}
        font.pixelSize: pixelFont
        verticalAlignment: TextInput.AlignVCenter
        horizontalAlignment: TextInput.AlignHCenter
        visible: false
    }

    Text{
        id: textWidtMonth
        text:inputMonth.text==""?placeholderMonth:inputMonth.text
        width: paintedWidth
        height: parent.height
        anchors{left: parent.left}
        font.pixelSize: pixelFont
        verticalAlignment: TextInput.AlignVCenter
        horizontalAlignment: TextInput.AlignHCenter
        visible: false
    }

    Text{
        id: textWidthDay
        text:inputDay.text==""?placeholderDay:inputDay.text
        width: paintedWidth
        height: parent.height
        anchors{left: parent.left;}
        font.pixelSize: pixelFont
        verticalAlignment: TextInput.AlignVCenter
        horizontalAlignment: TextInput.AlignHCenter
        visible: false
    }

    TextField{
        id: inputDay
        width: textWidthDay.width
        leftPadding: 0
        rightPadding: 0
        placeholderText: placeholderDay
        anchors{left: parent.left}
        mouseSelectionMode: TextInput.SelectWords
        selectByMouse: true
        font.pixelSize:pixelFont
        verticalAlignment: TextInput.AlignVCenter
        horizontalAlignment: TextInput.AlignHCenter
        activeFocusOnPress: true
        onTextChanged: {
            if(boolEscChangueText==false){
                if(text.toString().length>1){
                    inputMonth.forceActiveFocus();
                }
            }
            if(focus==true){
            }
        }
        onFocusChanged: {
            if(focus==true){
                selectAll();
            }else{
                boolEscChangueText=true
                checkDay();
                boolEscChangueText=false
            }
        }
        onTextEdited: {
            valueEdited();
        }

        onCursorVisibleChanged: {
            if(isCursorVisible==false){
                tcursorChangued.start();
            }
        }

        // { regExp:/^(0[1-9]|[1-9]|[12][0-9]|3[01])[/](0[1-9]|[1-9]|1[012])[/](17|18|19|20)\d\d$/}
        validator: RegExpValidator { regExp:/^(0[1-9]|[1-9]|[12][0-9]|3[01])$/}
        Keys.onPressed: {
            if (event.key === Qt.Key_Enter){
                event.accepted = true;
                checkDay();
                inputMonth.forceActiveFocus();
            }
            if (event.key === Qt.Key_Return){
                event.accepted = true;
                checkDay();
                inputMonth.forceActiveFocus();
            }
            if (event.key === Qt.Key_Up){
                event.accepted = true;
                boolEscChangueText =true;
                var x = parseInt(text);
                if(x<31){
                    x+=1;
                    text = x;
                }
                checkDay();
                selectAll();
                boolEscChangueText =false;
            }
            if (event.key === Qt.Key_Down){
                event.accepted = true;
                boolEscChangueText =true;
                var xd = parseInt(text);
                if(xd>1){
                    xd-=1;
                    text = xd;
                }
                checkDay();
                selectAll();
                boolEscChangueText =false;
            }
            if (event.key === Qt.Key_Escape ){
                event.accepted = true;
                //mainCa.forceActiveFocus();
            }
            if (event.key === Qt.Key_Right ){
                event.accepted = true;
                checkDay();
                inputMonth.forceActiveFocus();
            }
        }

    }

    Label{
        id:sepa1
        width: paintedWidth
        leftPadding: 0
        rightPadding: 0
        height: parent.height
        anchors{left:inputDay.right;leftMargin: 2}
        font.pixelSize: pixelFont
        verticalAlignment: TextInput.AlignVCenter
        horizontalAlignment: TextInput.AlignHCenter
        bottomPadding: dpis*2
        text:"/"
        MouseArea{
            anchors.fill: parent
            onClicked: inputDay.forceActiveFocus();
        }

    }

    TextField{
        id: inputMonth
        width: textWidtMonth.width
        //height: parent.height
        leftPadding: 0
        rightPadding: 0
        placeholderText: placeholderMonth
        anchors{left: sepa1.right;leftMargin: 2}
        mouseSelectionMode: TextInput.SelectWords
        selectByMouse: true
        font.pixelSize:pixelFont
        verticalAlignment: TextInput.AlignVCenter
        horizontalAlignment: TextInput.AlignHCenter
        activeFocusOnPress: true
        onTextChanged: {
            if(boolEscChangueText==false){
                if(text.toString().length>1){
                    inputYear.forceActiveFocus();
                }
            }
            if(focus==true){
                //changueText();
            }
        }
        onFocusChanged: {
            if(focus==true){
                //boolFocus=true;
                selectAll();
            }else{
                boolEscChangueText=true
                checkMonth();
                boolEscChangueText=false
            }
        }
        onTextEdited: {
            valueEdited();
        }

        onCursorVisibleChanged: {
            if(isCursorVisible==false){
                tcursorChangued.start();
            }
        }
        validator: RegExpValidator { regExp:/^(0[1-9]|[1-9]|1[012])$/}
        Keys.onPressed: {
            if (event.key === Qt.Key_Enter){
                event.accepted = true;
                checkMonth();
                inputYear.forceActiveFocus();
            }
            if (event.key === Qt.Key_Return){
                event.accepted = true;
                checkMonth();
                inputYear.forceActiveFocus();
            }
            if (event.key === Qt.Key_Up){
                event.accepted = true;
                boolEscChangueText =true;
                var x = parseInt(text);
                if(x<12){
                    x+=1;
                    text = x;
                }
                checkMonth();
                selectAll();
                boolEscChangueText =false;
            }
            if (event.key === Qt.Key_Down){
                event.accepted = true;
                boolEscChangueText =true;
                var xd = parseInt(text);
                if(xd>1){
                    xd-=1;
                    text = xd;
                }
                checkMonth();
                selectAll();
                boolEscChangueText =false;
            }
            if (event.key === Qt.Key_Escape ){
                event.accepted = true;
                //mainCa.forceActiveFocus();
            }
            if (event.key === Qt.Key_Right ){
                event.accepted = true;
                checkMonth();
                inputYear.forceActiveFocus();
            }
            if (event.key === Qt.Key_Left ){
                event.accepted = true;
                checkMonth();
                inputDay.forceActiveFocus();
            }
        }

    }

    Label{
        id:sepa2
        width: paintedWidth
        leftPadding: 0
        rightPadding: 0
        height: parent.height
        anchors{left:inputMonth.right;leftMargin: 2}
        font.pixelSize: pixelFont
        verticalAlignment: TextInput.AlignVCenter
        horizontalAlignment: TextInput.AlignHCenter
        bottomPadding: dpis*2
        text:"/"
        MouseArea{
            anchors.fill: parent
            onClicked: inputMonth.forceActiveFocus();
        }

    }

    TextField{
        id: inputYear
        width: textWidthYear.width
        //height: parent.height
        leftPadding: 0
        rightPadding: 0
        placeholderText: placeholderYear
        anchors{left: sepa2.right;leftMargin: 2}
        mouseSelectionMode: TextInput.SelectWords
        selectByMouse: true
        readOnly:false
        font.pixelSize:pixelFont
        verticalAlignment: TextInput.AlignVCenter
        horizontalAlignment: TextInput.AlignHCenter
        activeFocusOnPress: true
        onTextChanged: {
            if(boolEscChangueText==false){
                if(text.toString().length>3){
                    bcalendar.forceActiveFocus();
                }
            }
            if(focus==true){
                //changueText();
            }
        }
        onFocusChanged: {
            if(focus==true){
                selectAll();
            }else{
                boolEscChangueText=true;
                checkYear();
                boolEscChangueText=false;
            }
        }
        onTextEdited: {
            valueEdited();
        }

        onCursorVisibleChanged: {
            if(isCursorVisible==false){
                tcursorChangued.start();
            }
        }
        validator: RegExpValidator { regExp:/^(19|20|21)\d\d$/}
        Keys.onPressed: {
            if (event.key === Qt.Key_Enter){
                event.accepted = true;
                checkYear();
                bcalendar.forceActiveFocus();
                //mainCa.forceActiveFocus();
            }
            if (event.key === Qt.Key_Return){
                event.accepted = true;
                checkYear();
                bcalendar.forceActiveFocus()
                //mainCa.forceActiveFocus();
            }
            if (event.key === Qt.Key_Up){
                event.accepted = true;
                boolEscChangueText =true;
                var x = parseInt(text);
                if(x<2199){
                    x+=1;
                    text = x;
                }
                checkYear();
                selectAll();
                boolEscChangueText =false;
            }
            if (event.key === Qt.Key_Down){
                event.accepted = true;
                boolEscChangueText =true;
                var xd = parseInt(text);
                if(xd>1){
                    xd-=1;
                    text = xd;
                }
                checkYear();
                selectAll();
                boolEscChangueText =false;
            }
            if (event.key === Qt.Key_Escape ){
                event.accepted = true;
            }
            if (event.key === Qt.Key_Right ){
                event.accepted = true;
                checkYear();
                bcalendar.forceActiveFocus()
            }
            if (event.key === Qt.Key_Left ){
                event.accepted = true;
                checkYear();
                inputMonth.forceActiveFocus();
            }
        }

    }

    Button{
        id:bcalendar
        width: height - 20
        height: parent.height
        anchors{left: inputYear.right; top:parent.top;leftMargin: dpis}
        //display: Button.TextOnly
        font.family: fawesome.name
        font.italic: false
        font.pixelSize: 18
        text: "\uf073"
        //highlighted: true
        hoverEnabled: true
        onClicked: {
            buildCalenDesk()
        }
    }


    function buildCalenDesk(){
        var tmens= "import QtQuick 2.9;import QtQuick.Controls 2.2;import QtQuick.Layouts 1.3;"+
                "Dialog {"+
                "id:dicalen;"+
                "modal: true;"+
                "x: ((mainroot.width - width) / 2);"+
                "y: ((mainroot.height - height)/ 2);"+
                "title: qsTr(calendarTitle);"+
                "contentWidth: calendesk.width;"+
                "contentHeight: calendesk.height;"+
                "visible: true;"+
                "focus: true;"+
                //"closePolicy: Dialog.NoAutoClose;"+
                //calendesk.forceF();
                "function openis(){visible=true;calendesk.setDate(currentYear,currentMonth);calendesk.forceActiveFocus();}"+
                "Timer{"+
                "id:tcloseAll;"+
                "interval: 800;"+
                "onTriggered: {bcalendar.forceActiveFocus();destroy(0);}"+
                "}"+

                //"onAccepted: {tcerraris.start()}"+
                "onRejected: {tcloseAll.start();}"+
                "contentItem:Calendar{"+
                "id:calendesk;"+
                "fontPixel: pixelFont;"+
                "onClickDay: {"+
                "mainCa.setDate(datesis);"+
                "valueEdited();"+
                "tcursorChangued.start();"+
                "dicalen.visible=false;"+
                "tcloseAll.start();"+
                "}"+
                "onSignalClose: {"+
                "reject();"+
                "}"+
                "}"+
                "}"
        var object=Qt.createQmlObject(tmens, mainroot, "dynamicSnippet1");
        object.open();
    }

    function setDate(data){
        boolEscChangueText=true;
        currentDay=data.getDate();
        currentMonth=data.getMonth()+1;
        currentYear=data.getFullYear();
        inputDay.text=currentDay;
        inputMonth.text=currentMonth;
        inputYear.text=currentYear;
        checkDay();
        checkMonth();
        checkYear();
        boolEscChangueText=false;
        changueText();
    }

    function setDateTime(data){//TODO
        setDate(data);
    }

    function getDate(){
        if(inputDay.text == "" || inputMonth.text == "" || inputYear.text == ""){
            return null;
        }
        var myDate = new Date(currentYear,currentMonth-1,currentDay);
        return myDate;
    }

    function getDateTime(){//TODO add inputs Hours and Minutes
        if(inputDay.text == "" || inputMonth.text == "" || inputYear.text == ""){
            return null;
        }
        var tdate = new Date();
        var myDate = new Date(currentYear,currentMonth-1,currentDay,tdate.getHours(),tdate.getMinutes());
        return myDate;
    }

}
