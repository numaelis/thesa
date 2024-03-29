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
        domain:[['type', '=', 'in']]
        order:[['create_date','DESC'],['invoice_date','DESC']]
        filters:[
            {"field":"party.name","fieldalias":"Tercero","type":"text"},
            {"field":"invoice_date","fieldalias":"Fecha Factura","type":"date"}
        ] //type: text, numeric, date
        placeholderText: "number, party"
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
                "type":"date",
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
                "decimals":2,
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
            var mid = getCurrentId();
            console.log("double click", mid);
            MessageLib.showQuestion(qsTr("¿Post Invoice?"),mainroot,"testTreeView._toPost("+mid.toString()+")");
        }
    }
    property int tempRecord: -1
    function _toPost(mid){
        tempRecord=mid;
        var r_params = prepareParamsLocal("model.account.invoice.post",
                                          [
                                              [mid],
                                              contextPreferences({'type': 'in'})
                                          ]);
        ConectionLib.jsonRpcAction(testTreeView,r_params,{},
                                   "testTreeView._postOk(response)",
                                   "testTreeView._postCancel()",
                                   "testTreeView._postError()");
    }
    function _postOk(response){
        MessageLib.showMessage(qsTr("posted"), mainroot);
        myvt.updateRecords([tempRecord]);

    }
    function _postCancel(){

    }
    function _postError(){

    }


}
