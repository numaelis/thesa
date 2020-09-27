import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import thesatools 1.0

StackDesktop {
    id:mydesktop

    StackSubDesktop{

        tabs: [
            {name: qsTr("Products and Price"), icon: "\uf58d"},
            {name: qsTr("Statistics"), icon: "\uf080"},
            {name: qsTr("Party Call"), icon: "\uf554"},
            {name: qsTr("Formats"), icon: "\uf0c3"},
        ]

        Products{

        }

        Statistics{

        }

        Party {

        }

        InvoicesTestFormats {

        }
    }


    StackSubDesktop{

        tabs: [
            {name: "Picker Image", icon: "\uf1c5"},
            {name: "File", icon: "\uf56f"},
            {name: "QZXing Scan Code", icon: "\uf030"}
        ]

        TestGetFile {

        }

        TestGetFile2 {

        }

        TestQZXing {

        }

    }

    StackSubDesktop{

        tabs: [{name: "Fields", icon: ""},
            {name: "Tree View", icon: ""}]

        TestFields {

        }

        TestTreeView {

        }

    }

}
