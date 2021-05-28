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
        width: 730
        title: "Search Party"
        anchors.centerIn: parent
        dialogEdit: diaNewEditParty
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

            {
                "name":"tax_identifier",
                "alias":"Identificador",
                "type":"many2one",
                "width":120,
                "align":Label.AlignLeft,
                "virtual":true
            },

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
        modelName:"party.party"
        _title:"Party"
        onCreated: {

        }
        onUpdated:{

        }
        contentItemForm: ColumnLayout{
            TemplateFieldText{
                labelAlias: "Nombre"
                fieldName: "name"
                required:true
                Layout.preferredHeight: 60
                Layout.fillWidth: true
            }
            RowLayout{
                TemplateFieldText{
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
                    Layout.preferredHeight: 60
                    Layout.fillWidth: true
                    buttonSelection:true
                }
            }//
            TemplateFieldMany2One{
                labelAlias: "Identificador"
                fieldName: "tax_identifier"
                modelName:"party.identifier"
                Layout.preferredHeight: 60
                Layout.fillWidth: true
                readOnly: true
                //buttonSelection:true
            }

            //TemplateFieldNumeric , TemplateFieldSelection
        }
//        paramsPlusCreate:{
//            "active":true,
//        }

    }


}
