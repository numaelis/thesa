//this file is part the thesa: tryton client based PySide2(qml2)
// test example tree view tryton controls
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
    id:testTreeView

    onFirstTimeTab:{
        myvt.find([]);
    }

    TreeView{
        id:myvt
        anchors.fill: parent
        modelName:"account.invoice"
        limit: 300//step, step
        multiSelectItems:true
        activeFilters: true
        domain:[['type', '=', 'out']]
        order:[['invoice_date','DESC']]
        filters:[
            {"field":"party.name","fieldalias":"Tercero","type":"text"},
            {"field":"invoice_date","fieldalias":"Fecha Factura","type":"date"}
        ]
        //type: text, numeric
        verticalLine:true
        activeStates: true
        buttonRestart:true
        //heightField:60
        maximumLineCount:3
        //font.pixelSize:14
        modelStates:[
            {"name":"draft","alias":"Borrador"},
            {"name":"validated","alias":qsTr("Validado")},
            {"name":"posted","alias":qsTr("Confirmado")},
            {"name":"","alias":qsTr("Todo")}
        ]
        listHead: [//manual ...

            {
                "name":"number",
                "alias":"Número",
                "type":"text",
                "width":100,
                "align":Label.AlignLeft
            },

            {
                "name":"reference",
                "alias":"Ref",
                "type":"text",
                "width":150,
                "align":Label.AlignLeft
            },

            {
                "name":"invoice_date",
                "alias":"Fecha",
                "type":"datetime",
                "format":"dd/MM/yyyy",
                "width":120,
                "align":Label.AlignHCenter
            },

            {
                "name":"party.name",
                "alias":"Entidad",
                "type":"text",
                "width":200,
                "align":Label.AlignLeft
            },

            {
                "name":"total_amount",
                "virtual":true,//skip order, etc.. field type Function
                "alias":"Total",
                "type":"numeric",
                "width":200,
                "align":Label.AlignRight
            },

            {
                "name":"state",
                "alias":qsTr("Estado"),
                "type":"selection",
                "selectionalias":{'draft': "Borrador",
                                'validated': "Validado",
                                'posted': "Confirmado",
                                'paid': "Pagado",
                                'cancelled': "Cancelado"},
                "width":100,
                "align":Label.AlignHCenter
            },


            {
                "name":"description",
                "alias":"Descripción",
                "type":"text",
                "width":200,
                "align":Label.AlignHCenter
            },

            //            {
            //                "name":"image",
            //                "alias":"Imagen",
            //                "type":"image",//fields binary
            //                "format":"png",
            //                "width":60,
            //                "align":Label.AlignHCenter
            //            }

        ]
        onDoubleClick: {
            console.log("double click", getId())
        }
    }
}
