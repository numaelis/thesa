//this file is part the thesa: tryton client based PySide2(qml2)
// tools FieldCalendar, need to functions tools.calendar
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

Item{
    id:mainCa
    width: inputDia.width+sepa1.width+inputMes.width+sepa2.width+inputAnno.width+ bcalendar.width +dpis*3
    height: inputDia.height

    // property bool boolFocus: false
    property bool boolCargarFechaNow: true
    property bool boolEscChangueText: false
    property int currentDay: 1
    property int currentMonth: 1
    property int currentYear: 2020

    property string tituloCalendario: ""
    property int pixelFont: 16

    signal changueText()

    Component.onCompleted: {
        calcularFechaActual();
        if(boolCargarFechaNow){
            cargarFechaActual();
        }
    }


    function reset(){
        calcularFechaActual();
        if(boolCargarFechaNow){
            cargarFechaActual();
        }
    }

    function forceF(){
        inputDia.forceActiveFocus()
    }

    function calcularFechaActual(){
        var dataNow = new Date();
        currentDay = dataNow.getDate();
        currentMonth = dataNow.getMonth()+1;
        currentYear = dataNow.getFullYear();
    }
    function cargarFechaActual(){
        boolEscChangueText=true;
        inputDia.text=currentDay.toString();
        inputMes.text=currentMonth.toString();
        inputAnno.text=currentYear.toString();
        revisarDia();
        revisarMes();
        boolEscChangueText=false;
        changueText();

    }

    function revisarDia(){
        var texto = inputDia.text.toString();
        if(texto==="0" || texto===""){
            texto=currentDay.toString();
        }

        if(texto.length<2){
            inputDia.text="0" + texto;
        }else{
            inputDia.text=texto;
        }
        if(currentDay!==parseInt(inputDia.text)){
            currentDay=parseInt(inputDia.text)
            changueText();
        }
        //revisar mes anno
        ajustarDia();
    }
    function ajustarDia(){
        var ultimoDia = Tools.calendarLastDay(currentYear,currentMonth);
        if(ultimoDia<currentDay){
            boolEscChangueText=true;
            currentDay = ultimoDia;
            inputDia.text=currentDay.toString();
            changueText();
            boolEscChangueText=false;
        }
    }

    function revisarMes(){
        var texto = inputMes.text.toString();
        if(texto==="0" || texto===""){
            texto=currentMonth.toString();//importante ser string
        }
        if(texto.length<2){
            inputMes.text="0" + texto;
        }else{
            inputMes.text=texto;
        }
        if(currentMonth !== parseInt(inputMes.text)){
            currentMonth = parseInt(inputMes.text)
            changueText();
        }
        //revisar dia con el mes y año
        ajustarDia();

    }
    function revisarAnno(){
        var texto = inputAnno.text.toString();
        if(texto.length<4){
            inputAnno.text=currentYear.toString();
        }
        if(currentYear !== parseInt(inputAnno.text)){
            currentYear = parseInt(inputAnno.text)
            changueText();
        }
        //revisar dia con mes y año
        ajustarDia();
    }

    Text{
        id: textWidth
        text:"2222"
        width: paintedWidth
        height: parent.height
        anchors{left: parent.left;leftMargin: dpis;}
        //font.italic: va.allBoolItalic
        //font.family: va.allFontPrenta
        font.pixelSize: pixelFont
        verticalAlignment: TextInput.AlignVCenter
        horizontalAlignment: TextInput.AlignHCenter
        color: "silver"
        visible: false
    }

    Text{
        id: textWidth2
        text:"22"
        width: paintedWidth
        height: parent.height
        anchors{left: parent.left;leftMargin: dpis;}
        //font.italic: va.allBoolItalic
        //font.family: va.allFontPrenta
        font.pixelSize: pixelFont
        verticalAlignment: TextInput.AlignVCenter
        horizontalAlignment: TextInput.AlignHCenter
        color: "silver"
        visible: false
    }

    TextField{
        id: inputDia
        width: textWidth2.width
        //height: parent.height
        placeholderText: "dd"
        anchors{left: parent.left}
        mouseSelectionMode: TextInput.SelectWords
        selectByMouse: true
        readOnly:false
        font.pixelSize:pixelFont
        verticalAlignment: TextInput.AlignVCenter
        horizontalAlignment: TextInput.AlignHCenter
        activeFocusOnPress: true
        onTextChanged: {
            if(boolEscChangueText==false){
                if(text.toString().length>1){
                    inputMes.forceActiveFocus();
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
                revisarDia();
                boolEscChangueText=false
            }
        }
        // { regExp:/^(0[1-9]|[1-9]|[12][0-9]|3[01])[/](0[1-9]|[1-9]|1[012])[/](17|18|19|20)\d\d$/}
        validator: RegExpValidator { regExp:/^(0[1-9]|[1-9]|[12][0-9]|3[01])$/}
        Keys.onPressed: {
            if (event.key === Qt.Key_Enter){
                event.accepted = true;
                revisarDia();
                inputMes.forceActiveFocus();
            }
            if (event.key === Qt.Key_Return){
                event.accepted = true;
                revisarDia();
                inputMes.forceActiveFocus();
            }
            if (event.key === Qt.Key_Up){
                event.accepted = true;
                boolEscChangueText =true;
                var x = parseInt(text);
                if(x<31){
                    x+=1;
                    text = x;
                }
                revisarDia();
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
                revisarDia();
                selectAll();
                boolEscChangueText =false;
            }
            if (event.key === Qt.Key_Escape ){
                event.accepted = true;
                //mainCa.forceActiveFocus();
            }
            if (event.key === Qt.Key_Right ){
                event.accepted = true;
                revisarDia();
                inputMes.forceActiveFocus();
            }
        }

    }

    Label{
        id:sepa1
        width: textWidth2/2
        height: parent.height
        anchors{left:inputDia.right}
        //font.italic: true
        //font.family: va.allFontPrenta
        font.pixelSize: pixelFont
        verticalAlignment: TextInput.AlignVCenter
        horizontalAlignment: TextInput.AlignHCenter
        fontSizeMode: Text.Fit
        minimumPixelSize: 12
        bottomPadding: dpis*2
        text:"/"
        MouseArea{
            anchors.fill: parent
            onClicked: inputDia.forceActiveFocus();
        }

    }

    TextField{
        id: inputMes
        width: textWidth2.width
        //height: parent.height
        placeholderText: "mm"
        anchors{left: sepa1.right;leftMargin: dpis}
        mouseSelectionMode: TextInput.SelectWords
        selectByMouse: true
        readOnly:false
        //        font.italic: va.allBoolItalic
        //        font.family: va.allFontPrenta
        font.pixelSize:pixelFont
        verticalAlignment: TextInput.AlignVCenter
        horizontalAlignment: TextInput.AlignHCenter
        //clip:true
        //color: va.allColorInput
        activeFocusOnPress: true
        onTextChanged: {
            if(boolEscChangueText==false){
                if(text.toString().length>1){
                    inputAnno.forceActiveFocus();
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
                revisarMes();
                boolEscChangueText=false
            }
        }
        validator: RegExpValidator { regExp:/^(0[1-9]|[1-9]|1[012])$/}
        Keys.onPressed: {
            if (event.key === Qt.Key_Enter){
                event.accepted = true;
                revisarMes();
                inputAnno.forceActiveFocus();
            }
            if (event.key === Qt.Key_Return){
                event.accepted = true;
                revisarMes();
                inputAnno.forceActiveFocus();
            }
            if (event.key === Qt.Key_Up){
                event.accepted = true;
                boolEscChangueText =true;
                var x = parseInt(text);
                if(x<12){
                    x+=1;
                    text = x;
                }
                revisarMes();
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
                revisarMes();
                selectAll();
                boolEscChangueText =false;
            }
            if (event.key === Qt.Key_Escape ){
                event.accepted = true;
                //mainCa.forceActiveFocus();
            }
            if (event.key === Qt.Key_Right ){
                event.accepted = true;
                revisarMes();
                inputAnno.forceActiveFocus();
            }
            if (event.key === Qt.Key_Left ){
                event.accepted = true;
                revisarMes();
                inputDia.forceActiveFocus();
            }
        }

    }

    Label{
        id:sepa2
        width: textWidth2.width/2
        height: parent.height
        anchors{left:inputMes.right}
        //        font.italic: true
        //        font.family: va.allFontPrenta
        font.pixelSize: pixelFont
        verticalAlignment: TextInput.AlignVCenter
        horizontalAlignment: TextInput.AlignHCenter
        fontSizeMode: Text.Fit
        minimumPixelSize: 12
        bottomPadding: dpis*2
        text:"/"
        MouseArea{
            anchors.fill: parent
            onClicked: inputMes.forceActiveFocus();
        }

    }

    TextField{
        id: inputAnno
        width: textWidth.width
        //height: parent.height
        placeholderText: "aaaa"
        anchors{left: sepa2.right;leftMargin: dpis}
        mouseSelectionMode: TextInput.SelectWords
        selectByMouse: true
        readOnly:false
        //        font.italic: va.allBoolItalic
        //        font.family: va.allFontPrenta
        font.pixelSize:pixelFont
        verticalAlignment: TextInput.AlignVCenter
        horizontalAlignment: TextInput.AlignHCenter
        //clip:true
        //color: va.allColorInput
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
                revisarAnno();
                boolEscChangueText=false;
            }
        }
        validator: RegExpValidator { regExp:/^(19|20|21)\d\d$/}
        Keys.onPressed: {
            if (event.key === Qt.Key_Enter){
                event.accepted = true;
                revisarAnno();
                bcalendar.forceActiveFocus();
                //mainCa.forceActiveFocus();
            }
            if (event.key === Qt.Key_Return){
                event.accepted = true;
                revisarAnno();
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
                revisarAnno();
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
                revisarAnno();
                selectAll();
                boolEscChangueText =false;
            }
            if (event.key === Qt.Key_Escape ){
                event.accepted = true;
            }
            if (event.key === Qt.Key_Right ){
                event.accepted = true;
                revisarAnno();
                bcalendar.forceActiveFocus()
            }
            if (event.key === Qt.Key_Left ){
                event.accepted = true;
                revisarAnno();
                inputMes.forceActiveFocus();
            }
        }

    }

    Button{
        id:bcalendar
        width: height - 20
        height: parent.height
        anchors{left: inputAnno.right; top:parent.top;leftMargin: dpis}
        //display: Button.TextOnly
        font.family: fawesome.name
        font.italic: false
        font.pixelSize: 18
        text: "\uf073"
        //highlighted: true
        hoverEnabled: true
        onClicked: {
            crearCalenDesk()
        }
    }


    function crearCalenDesk(){
        var tmens= "import QtQuick 2.9;import QtQuick.Controls 2.2;import QtQuick.Layouts 1.3;"+
                "Dialog {"+
                "id:dicalen;"+
                "modal: true;"+
                "x: ((mainroot.width - width) / 2);"+
                "y: ((mainroot.height - height)/ 2);"+
                "title: qsTr(tituloCalendario);"+
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
                    "onClickDia: {"+
                        "mainCa.setDate(datesis);"+
                        "dicalen.visible=false;"+
                        "tcloseAll.start();"+
                    "}"+
                "onSignalClose: {"+
                    "reject();"+
                "}"+
                "}"+
                "}"
        var object=Qt.createQmlObject(tmens, mainroot, "dynamicSnippet1");
        object.openis();
    }

    function setDate(data){
        boolEscChangueText=true;
        currentDay=data.getDate();
        currentMonth=data.getMonth()+1;
        currentYear=data.getFullYear();
        inputDia.text=currentDay;
        inputMes.text=currentMonth;
        inputAnno.text=currentYear;
        revisarDia();
        revisarMes();
        revisarAnno();
        boolEscChangueText=false;
        changueText();
    }

    function getDate(){
        var fechaelis = new Date(currentYear,currentMonth-1,currentDay);
        return fechaelis;
    }
    function getDateTime(){
        var tdate = new Date();
        var fechaelis = new Date(currentYear,currentMonth-1,currentDay,tdate.getHours(),tdate.getMinutes());
        return fechaelis;
    }

}
