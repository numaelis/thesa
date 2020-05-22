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
        ]

        Products{

        }

        Statistics{

        }
    }

    StackSubDesktop{

        tabs: [{name: "", icon: ""}]

        Party {

        }

    }

    StackSubDesktop{

        tabs: [{name: "", icon: ""}]

        InvoicesTestFormats {

        }

    }

    StackSubDesktop{

        tabs: [
            {name: "Picker Image", icon: "\uf1c5"},
            {name: "File", icon: "\uf56f"}
        ]

        TestGetFile {

        }

        TestGetFile2 {

        }

    }

    StackSubDesktop{

        tabs: [{name: "", icon: ""}]

        TestQZXing {

        }

    }

}
