//this file is part the thesa: tryton client based PySide2(qml2)
//__author__ = "Numael Garay"
import QtQuick 2.9
import QtQuick.Controls 2.2

import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import "messages.js" as MessageLib

Item {
    id:mainfd
    width: dpis*60
    //height: tfdoc.height
    property alias value: tfdoc.text
    property int pixelFont: 16
    property string tipeDocument: "DNI"// DNI CUIT
    property bool boolAuto: false // solo para listView
    property alias readOnly: tfdoc.readOnly

    Component.onCompleted: {
        selectTipeDocument();
    }

    function selectTipeDocument(){
        switch(tipeDocument){
        case "DNI":
            tfdoc.validator= Qt.createQmlObject('import QtQuick 2.9;RegExpValidator { regExp:/^(0|[1-9][0-9]*)$/}', tfdoc, "dynamicSnippet1");
            break;
        case "CUIT":
            tfdoc.validator= Qt.createQmlObject('import QtQuick 2.9;RegExpValidator { regExp:/^(0|[1-9][0-9]*)$/}', tfdoc, "dynamicSnippet1");
            break;
//        case "PASS"://password
//            tfdoc.validator= Qt.createQmlObject('import QtQuick 2.9;RegExpValidator { regExp:/^(.*)$/}', tfdoc, "dynamicSnippet1");
//            break;
        case "TEL":
            tfdoc.validator= Qt.createQmlObject('import QtQuick 2.9;RegExpValidator { regExp:/^([0-9]*)$/}', tfdoc, "dynamicSnippet1");
            break;
        case "NUM":
            tfdoc.validator= Qt.createQmlObject('import QtQuick 2.9;RegExpValidator { regExp:/^([0-9]*)$/}', tfdoc, "dynamicSnippet1");
            break;
        case "DEC"://decimal
            tfdoc.validator= Qt.createQmlObject('import QtQuick 2.5;RegExpValidator { regExp:/^(0\\.([1-9][0-9]|[0-9][1-9])|[1-9][0-9]*\\.[0-9][0-9])$/ }', tfdoc, "dynamicSnippet1");
            break;
        case "DECUP"://decimal up
            tfdoc.validator= Qt.createQmlObject('import QtQuick 2.5;RegExpValidator { regExp:/^(0\\.([1-9][0-9]|[0-9][1-9])|[1-9][0-9]*\\.[0-9][0-9])$/ }', tfdoc, "dynamicSnippet1");
            break;
        }
    }

    onValueChanged: {
        if(boolAuto){
            reFormatize();
        }
    }

    function getValue(){
        return value;
    }
    function setValue(data){
        value = data;
        reFormatize();
    }

    function formatDni2(texto){
        var numero = parseFloat(texto);
        if (isNaN(numero)){
            numero = 0;
        }
        //var numero = texto;
        return numero.toFixed(0).replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1.")
//        return texto.replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1.")
    }

    function formatDni(numero){
        if(numero ===""){
            return "";
        }
        if(numero===0){
            return "0";
        }

        if (isNaN(numero)){
            numero = 0;
        }

        var places = 0;
        var symbol = "";
        var thousand =  ".";
        var decimal = ".";
        var number = numero,
                negative = number < 0 ? "-" : "",
                                        i = parseInt(number = Math.abs(+number || 0).toFixed(places), 10) + "",
                                        j = (j = i.length) > 3 ? j % 3 : 0;
        var textformat = symbol + negative + (j ? i.substr(0, j) + thousand : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + thousand) + (places ? decimal + Math.abs(number - i).toFixed(places).slice(2) : "");
        return textformat;
    }

    function formatCuit(numero){
        var textformat = numero;
        if(numero.length===11){
            //console.log(l.slice(0,2),l.slice(2,10),l.slice(10,11))
            textformat = numero.slice(0,2)+"-"+numero.slice(2,10)+"-"+numero.slice(10,11);
        }else{
            //mensajeAdvertencia();
            if(!boolAuto){
                MessageLib.showMessage("Error en el Cuit, verifiquelo por favor",mainroot);
            }
        }

        return textformat;
    }
    function validarCuit(cuit) {
        //cuit = cuit.toString();
        if(cuit.length != 11) {
            return false;
        }

        var acumulado 	= 0;
        var digitos 	= cuit.split("");
        var digito	= digitos.pop();

        for(var i = 0; i < digitos.length; i++) {
            acumulado += digitos[9 - i] * (2 + (i % 6));
        }

        var verif = 11 - (acumulado % 11);
        if(verif == 11) {
            verif = 0;
        }

        return digito == verif;
    }

    function verificacionCuit2(dataelis){
        dataelis = dataelis.toString()
        var aMult = '5432765432';
        aMult = aMult.split('');
        if (dataelis && dataelis.length == 11)
        {
            var aCUIT = dataelis.split('');
            var iResult = 0;
            for(var i = 0; i <= 9; i++)
            {
                iResult += aCUIT[i] * aMult[i];
            }
            iResult = (iResult % 11);
            iResult = 11 - iResult;
            if (iResult == 11) iResult = 0;
            if (iResult == 10){ return false};
            if (iResult == aCUIT[10])
            {
                return true;
            }
        }
        return false;
    }

    function forceF(){
        tfdoc.forceActiveFocus();
    }
    //textFormat: Text.RichText
    TextField{
        id: tfmascara
        width: parent.width
        //height: parent.height
        //placeholderText: "dd"
        font.pixelSize: pixelFont
        leftPadding: 2
        topPadding: 0
        bottomPadding: 0
        anchors{horizontalCenter: parent.horizontalCenter}
        mouseSelectionMode: TextInput.SelectWords
        selectByMouse: !boolMovil
        readOnly: true
        visible: tfdoc.focus==false?tipeDocument=="DECUP"?false:true:false
        horizontalAlignment: TextField.AlignRight
        onFocusChanged: {
            if(focus){
                tfdoc.forceActiveFocus();
            }
        }
    }
    Label{
        id: tfmaskcup
        width: parent.width
        height: parent.height// - dpis*4
        font.pixelSize: pixelFont
//        font.family: myFontPrenta
//        color: mainroot.Material.foreground
//        font.bold: true
        anchors{horizontalCenter: parent.horizontalCenter;bottom: parent.bottom; bottomMargin: dpis*2}

        visible: tfdoc.focus==false?tipeDocument=="DECUP"?true:false:false
        horizontalAlignment: Label.AlignRight
        verticalAlignment: Label.AlignBottom
        onFocusChanged: {
            if(focus){
                tfdoc.forceActiveFocus();
            }
        }
    }

    function mensajeAdvertencia(){
        var tmens= "import QtQuick 2.9;import QtQuick.Controls 2.2;import QtQuick.Layouts 1.3;"+
                "Advertencia {"+
                "id:dicalen;"+
                "modal: true;"+
                "focus: true;"+
                "x: ((mainroot.width - width) / 2);"+
                "y: ((mainroot.height - height)/ 2);"+
                "visible: true;"+
                "miTexto: 'Error en el Cuit, verifiquelo por favor';"+
                "onAccepted: {tfdoc.forceActiveFocus()}"+
                //"onRejected: {tcloseAll.start();}"+
                "}"
        var object=Qt.createQmlObject(tmens, mainroot, "dynamicSnippet1");
    }
        //(0054362) 461-6601
    function formatTelenelis(texto){
        var len = texto.length;
        if(len>6){
            if(texto[0]==="0" && texto[1]==="0");
            texto = texto.replace("00","+");
            len = texto.length;
        }
        if(len <= 4){
            return texto;
        }else{
            if(len > 4){
                if (len <=7 ){
                    var te1, te2 = "";
                    te2 = texto.slice(len-4,len);
                    te1 = texto.slice(0,len-4);
                    return te1+"-"+te2;
                }
                if (len > 7){
                    var t1, t2, t3 = "";
                    t3 = texto.slice(len-4,len);
                    t2 = texto.slice(len-7,len-4);
                    t1 = texto.slice(0, len-7);
                    return "("+t1+") "+t2+"-"+t3;

                }
            }
        }
    }

    function reFormatize(){
        switch(tipeDocument){
        case "CUIT":
            if(tfdoc.text.trim()!=""){
                if(validarCuit(tfdoc.text)==false){
                    //tfdoc.forceActiveFocus();
                    //crear mensaje con signal ok a focus
                    if(!boolAuto){
                        MessageLib.showMessage("Error en el Cuit, verifiquelo por favor",mainroot);
                    }
                    //mensajeAdvertencia();
                    tfmascara.text=tfdoc.text;
                }else{
                    tfmascara.text= formatCuit(tfdoc.text);
                }
            }else{
                tfmascara.text=tfdoc.text;
            }

            break;
        case "DNI":
            tfmascara.text=formatDni2(tfdoc.text)
            break;
//        case "PASS":
//            tfmascara.text=tfdoc.text;
//            break;
        case "TEL":
            tfmascara.text=formatTelenelis(tfdoc.text);
            break;
        case "NUM":
            tfmascara.text=formatNumeric(tfdoc.text)
            break;
        case "DEC":
            tfmascara.text=formatDecimal(tfdoc.text)
            break;
        case "DECUP":
            tfmaskcup.text=formatCentUp(tfdoc.text)
            break;
        default:
            tfmascara.text=tfdoc.text;
            break;
        }

    }

    TextField{
        id: tfdoc
        width: parent.width
        //height: parent.height
        leftPadding: 2
        topPadding: 0
        bottomPadding: 0
        //placeholderText: "dd"
        font.pixelSize: pixelFont
        anchors{horizontalCenter: parent.horizontalCenter}
        mouseSelectionMode: TextInput.SelectWords
        selectByMouse: !boolMovil
        opacity: focus==true?1:0

        onFocusChanged: {
            if(focus){
                //tfdoc.forceActiveFocus();
            }else{
                reFormatize();
            }
        }
        Keys.onPressed: {
            if (event.key === Qt.Key_Return ) {
                event.accepted = true;
                focus = false;
            }
            if (event.key === Qt.Key_Enter ) {
                event.accepted = true;
                focus = false;
            }
        }
    }

}
