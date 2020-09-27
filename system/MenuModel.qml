import QtQuick 2.0

ListModel {
    id: panelModel

    ListElement {
        name: qsTr("test Basic")
        icon: "\uf187"
    }

    ListElement {
        name: qsTr("test Other")
        icon: "\uf302"
    }

    ListElement {
        name: qsTr("Tryton Controls")
        icon: "\uf0f4"
    }
}
