//this file is part the thesa: tryton client based PySide2(qml2)
// test example form dialog and search dialog
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
import thesatools 1.0
import TrytonControls 1.0

TabDesktop {
    id:testDialogs

    isPreClosing: true
    function preClosing(){//warning: must be synchronous
        //......
        console.log("closing...");
        //......
    }

    property var list_types:[
        {"name":'phone', "alias":'Phone'},
        {"name":'mobile', "alias":'Mobile'},
        {"name":'fax', "alias":'Fax'},
        {"name":'email', "alias":'E-Mail'},
        {"name":'website', "alias":'Website'},
        {"name":'skype', "alias":'Skype'},
        {"name":'sip', "alias":'SIP'},
        {"name":'irc', "alias":'IRC'},
        {"name":'jabber', "alias":'Jabber'},
        {"name":'other', "alias":'Other'},
    ]
    ColumnLayout{
        anchors.fill: parent
        Label{
            text:" Dialog Form Edit and Dialog Search"
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: 60
            font.pixelSize: 20
        }

        RowLayout{
            Layout.preferredHeight: 30
            Layout.preferredWidth: 200
            Layout.alignment: Qt.AlignHCenter
            Button{
                text: "Select Party"
                onClicked: {
                    diaSearchParty.open();
                }
            }

            Label{
                id:infoParty
                font.pixelSize: 30
            }

        }
        RowLayout{
            Layout.fillHeight: true
        }
    }

    TemplateDialogSearch{
        id:diaSearchParty
        width: boolShortWidth135?parent.width:730
        height: boolShortWidth135?parent.height:500
        title: "Search Party"
        dialogEdit: diaNewEditParty
        activeActionRemove:true
        modelName:"party.party"
        // domain:[['categories', '=', 'Clientes']]
        order:[['name','ASC']]
        listHead: [
            {
                "name":"name",
                "alias":"Nombre",
                "type":"text",
                "width":200,
                "align":Label.AlignLeft
            },

            //            {
            //                "name":"tax_identifier",
            //                "alias":"Ident Fiscal",
            //                "type":"many2one",
            //                "width":120,
            //                "align":Label.AlignLeft,
            //                "virtual":true
            //            },

            {
                "name":"lang",
                "alias":"idioma",
                "type":"many2one",
                "width":130,
                "align":Label.AlignLeft,
                "virtual":true
            },

            {
                "name":"phone",
                "alias":"Telefono",
                "type":"text",
                "width":120,
                "align":Label.AlignLeft,
                "virtual":true
            },

        ]
        placeholderText: "nombre o ciudad"
        filtersRecName: [['OR',["rec_name","ilike","%value%"], ["addresses.city","ilike","%value%"]]]
        onActionSelect:{
            infoParty.text= "Party: "+fields.name + " id: "+fields.id
        }

    }
    TemplateDialogEdit{
        id:diaNewEditParty
        width: boolShortWidth135?parent.width:450
        height: boolShortWidth135?parent.height:500
        modelName:"party.party"
        _title:"Party"
        onCreated: {

        }
        onUpdated:{

        }
        contentItemForm: ScrollView{
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentWidth: columl0.width
            ColumnLayout{
                id:columl0
                width: 450-(diaNewEditParty.padding*3)
                TemplateFieldChar{
                    labelAlias: "Nombre"
                    fieldName: "name"
                    required:true
                    Layout.preferredHeight: 60
                    Layout.fillWidth: true
                }
                RowLayout{
                    TemplateFieldChar{
                        labelAlias: "Código"
                        fieldName: "code"
                        readOnly: true
                        Layout.preferredHeight: 60
                        Layout.fillWidth: true
                    }
                    TemplateFieldMany2One{
                        labelAlias: "Idioma"
                        fieldName: "lang"
                        modelName:"ir.lang"
                        required:true
                        Layout.preferredHeight: 60
                        Layout.fillWidth: true
                        buttonSelection:true
                    }
                }//
                //            TemplateFieldMany2One{
                //                labelAlias: "Identificador Fiscal"
                //                fieldName: "tax_identifier"
                //                modelName:"party.identifier"
                //                Layout.preferredHeight: 60
                //                Layout.fillWidth: true
                //                readOnly: true  // virtual --> fields.Function without setter
                //            }

                //            TemplateFieldOne2Many{
                //                fieldName: "identifiers"
                //                fieldOne2Many: "party"
                //                modelName: "party.identifier"
                //               // title:""
                //                Layout.preferredHeight: 100
                //                Layout.fillWidth: true
                //                oneItemDefault: true
                //                paramsPlusCreate: {"type":"ar_dni"}
                //                contentItemForm: ColumnLayout{
                //                    TemplateFieldChar{
                //                        labelAlias: "Dni"
                //                        fieldName: "code"
                //                        required:true
                //                        Layout.preferredHeight: 60
                //                        Layout.fillWidth: true
                //                    }

                //                }
                //            }
                TemplateFieldOne2Many{
                    fieldName: "addresses"
                    fieldOne2Many: "party"
                    modelName: "party.address"
                    title:"Dirección"
                    Layout.preferredHeight: 100
                    Layout.fillWidth: true
                    oneItemDefault: true
                    contentItemForm: ColumnLayout{
                        TemplateFieldChar{
                            labelAlias: "Calle"
                            fieldName: "street"
                            required:true
                            Layout.preferredHeight: 60
                            Layout.fillWidth: true
                        }

                    }
                }

                TemplateFieldOne2Many{
                    fieldName: "contact_mechanisms"
                    fieldOne2Many: "party"
                    modelName: "party.contact_mechanism"
                    title: "Contacto"
                    Layout.preferredHeight: 100
                    Layout.fillWidth: true
                    oneItemDefault: true
                    //paramsPlusCreate: {"type":"phone"}
                    activeMenu: true
                    listHead: [{
                            "alias":"Tipo",
                            "name":"type",
                            "type":"text",
                            "width":70,
                            "align":Label.AlignLeft
                        },{
                            "alias":"Telefono",
                            "name":"value",
                            "type":"text",
                            "width":200,
                            "align":Label.AlignLeft
                        }]
                    contentItemForm: RowLayout{
                        TemplateFieldSelection{
                            labelAlias: "tipo"
                            fieldName: "type"
                            required:true
                            height:70
                            Layout.preferredWidth:150
                            model:list_types
                        }
                        TemplateFieldChar{
                            labelAlias: "Telefono"
                            fieldName: "value"
                            required:true
                            Layout.preferredHeight: 60
                            Layout.fillWidth: true
                        }

                    }
                }

                //TemplateFieldNumeric
            }
            //        paramsPlusCreate:{
            //            "active":true,
            //        }
        }
    }


}
