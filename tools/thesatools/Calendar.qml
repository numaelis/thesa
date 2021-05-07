//this file is part the thesa: tryton client based PySide2(qml2)
// tools Calendar, need to functions tools.calendar
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

Item {
    id:mainCaDes
    width: gdias.width
    height: icuerpo.height+barra.height
    property real widthGrid: 28
    property real heightGrid: 30
    //property real heightBarra: 20
    property int fontPixel: 16

    property bool boolFocus: false

    property int currentYear: 2020
    property int currentMonth: 1
    property bool boolFitText: true
    property var namesDays: []
    property var namesMonths: []
    property bool boolEscChangue: false

    signal clickDia( date datesis)
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
        inputAnno.forceActiveFocus()
    }
    function calculateCurrentDate(){
        var dataNow = new Date();
        //        diaActual = dataNow.getDate();
        currentMonth = dataNow.getMonth()+1;
        currentYear = dataNow.getFullYear();
    }
    function hayFoco(){

        return false;
    }
    function enterAnno(){
        currentYear=inputAnno.text;
        reload();
    }
    function atras(){
        if(currentMonth==1){
            currentYear-=1;
            currentMonth=12;
        }else{
            currentMonth-=1;
        }
        reload();
    }
    function adelante(){
        if(currentMonth==12){
            currentYear+=1;
            currentMonth=1;
        }else{
            currentMonth+=1;
        }
        reload();
    }

    function revisarAnno(){
        var texto = inputAnno.text.toString();
        if(texto.length<4){
            inputAnno.text=currentYear.toString();
        }
    }
    function loadNames(){
        namesDays = nameShortDays;//Tools.calendarNamesDays()
        namesMonths = nameLongMonths;//Tools.calendarNamesMonths()
    }

    ListModel{
        id:modelmes
    }
    function setDate(anno,mes){
        currentMonth=mes;
        currentYear=anno;
        reload();
    }

    function reload(){
        modelmes.clear()
        var lista = Tools.calendarMonth(currentYear,currentMonth);
        for(var i = 0, len = lista.length; i < len; i++){
            modelmes.append(lista[i]);
            //console.log(lista[i].dia)
        }
        nombreMes.text=namesMonths[currentMonth-1];
        boolEscChangue=true;
        inputAnno.text=currentYear;
        boolEscChangue=false;
    }

    Item{
        id:barra
        width: gdias.width
        height: inputAnno.height
        anchors{top:parent.top}

        Button{
            id:bizq
            width: height-dpis*4
            height: parent.height
            anchors{left: parent.left;}
            onClicked: {atras()}
            //display: Button.TextOnly
            font.family: fawesome.name
            font.italic: false
            font.pixelSize: 18
            text: "\uf104"
        }

        Button{
            id:bder
            width: height-dpis*4
            height: parent.height
            anchors{right: parent.right;}
            onClicked: {adelante()}
            //display: Button.TextOnly
            font.family: fawesome.name
            font.italic: false
            font.pixelSize: 18
            text: "\uf105"
        }

        Text{
            id:nombreMes
            //text:"aaaa"
            width: parent.width-bizq.width-inputAnno.width-bder.width-dpis// - (dpis*2)
            height: parent.height
            anchors{left: bizq.right;leftMargin: 0}
            font.italic: true
            //                font.family: va.allFontPrenta
            font.pixelSize: 20
            minimumPixelSize: 6
            fontSizeMode: Text.Fit
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            color: inputAnno.Material.primaryTextColor

            //color: va.allColorInput
            //            MouseArea{
            //                anchors.fill: parent
            //                cursorShape: Qt.IBeamCursor
            //            }
        }

        Text{
            id: textWidth
            text:"2222"
            width: paintedWidth
            height: parent.height
            anchors{left: nombreMes.right;}
            //            font.italic: va.allBoolItalic
            //            font.family: va.allFontPrenta
            font.pixelSize: fontPixel
            verticalAlignment: TextInput.AlignVCenter
            horizontalAlignment: TextInput.AlignHCenter
            color: "silver"
            visible: false

        }

        TextField{
            id: inputAnno
            width: textWidth.width
            //height: parent.height
            placeholderText: "aaaa"
            anchors{right: bder.left; rightMargin: dpis;}
            mouseSelectionMode: TextInput.SelectWords
            selectByMouse: true
            //            font.italic: va.allBoolItalic
            //            font.family: va.allFontPrenta
            font.pixelSize: fontPixel
            verticalAlignment: TextInput.AlignVCenter
            horizontalAlignment: TextInput.AlignHCenter
            clip:true
            activeFocusOnPress: true
            onTextChanged: {
                if(boolEscChangue==false){
                    if(text.toString().length>3){
                        enterAnno();
                    }
                }
            }
            onFocusChanged: {
                if(focus==true){
                    boolFocus=true;
                    selectAll();
                }else{
                    revisarAnno();
                }
            }
            validator: RegExpValidator { regExp:/^(19|20|21)\d\d$/}
            Keys.onPressed: {
                if (event.key === Qt.Key_Enter){
                    event.accepted = true;
                    revisarAnno();
                    enterAnno();
                }
                if (event.key === Qt.Key_Return){
                    event.accepted = true;
                    revisarAnno();
                    enterAnno();
                }
                if (event.key === Qt.Key_Up){
                    event.accepted = true;
                    var x = parseInt(text);
                    if(x<2199){
                        x+=1;
                        text = x;
                    }
                    revisarAnno();
                    selectAll();
                    enterAnno();
                }
                if (event.key === Qt.Key_Down){
                    event.accepted = true;
                    var xd = parseInt(text);
                    if(xd>1){
                        xd-=1;
                        text = xd;
                    }
                    revisarAnno();
                    enterAnno();
                    selectAll();
                }
                if (event.key === Qt.Key_Escape ){
                    event.accepted = true;
                }
                if (event.key === Qt.Key_Tab ){
                    event.accepted = true;
                    revisarAnno();
                    enterAnno();
                }
            }
        }
    }
    Item{
        id:icuerpo
        width: gdias.width
        height:gdias.height+rownamesDays.height
        anchors{bottom: parent.bottom}

        Row{
            id:rownamesDays
            width: gdias.width
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
                        // font.italic: va.allBoolItalic
                        //font.family: va.allFontPrenta
                        font.pixelSize: dpis*3
                        minimumPixelSize: 6
                        fontSizeMode: Text.Fit
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        color: inputAnno.Material.primaryTextColor
                    }
                }
            }
        }

        GridView{
            id:gdias
            width: cellWidth*7
            height: cellHeight*6
            cellWidth: widthGrid
            cellHeight: heightGrid
            anchors{bottom: parent.bottom;}
            delegate: ItemDelegate {
                id:idele
                width: gdias.cellWidth
                height: gdias.cellHeight
                text: dia
                font.bold: true
                font.pixelSize: fontPixel
                contentItem: Item{
                    anchors.fill: parent
                    Rectangle{
                        id:ibase
                        anchors{fill: parent;margins: 0.5}
                        color: "transparent"
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
                    clickDia(new Date (anno,mes-1,dia));
                }
            }
            model:modelmes
            clip: true
        }
    }
}
