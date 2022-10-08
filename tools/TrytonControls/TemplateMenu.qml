import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import "../thesatools"
import "../thesatools/messages.js" as MessageLib

Control {
    id:tmenu
    implicitWidth: 200
    implicitHeight: 60
    signal openRecord()
    signal newRecord()
    signal removeRecords()
    property string labelMenu: ""
    Pane{
        Material.elevation: 4
        anchors.fill: parent
        bottomPadding: 6
        topPadding: 6
        RowLayout{
            anchors.fill: parent
            Label{
                text: labelMenu
                Layout.fillWidth: true
                font.bold: true
                font.pixelSize: 18
                elide: Text.ElideRight
                color: mainroot.Material.accent
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
            }
            RowLayout{
                Button{
                    Material.background: setting.accent
                    onClicked: newRecord()
                    contentItem: RowLayout{
                        Text {
                            text: "\uf067"
                            font.family:fawesome.name
                            font.bold: false
                            font.italic: false
                            opacity: enabled ? 1.0 : 0.3
                            color: Qt.darker(mainroot.Material.accent)
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }
                        Text {
                            text: "Nuevo"
                            opacity: enabled ? 1.0 : 0.3
                            //                        color: Qt.darker(mainroot.Material.accent)
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }
                    }
                }
                Button{
                    Material.background: setting.accent
                    onClicked: openRecord()
                    contentItem: RowLayout{
                        Text {
                            text: "\uf35d"
                            font.family:fawesome.name
                            font.bold: false
                            font.italic: false
                            opacity: enabled ? 1.0 : 0.3
                            color: Qt.darker(mainroot.Material.accent)
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }
                        Text {
                            text: "Abrir"
                            opacity: enabled ? 1.0 : 0.3
                            //                        color: Qt.darker(mainroot.Material.accent)
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }
                    }
                }
                Button{
                    Material.background: setting_accent
                    onClicked: removeRecords()
                    contentItem: RowLayout{
                        Text {
                            text: "\uf2ed"
                            font.family:fawesome.name
                            font.bold: false
                            font.italic: false
                            opacity: enabled ? 1.0 : 0.3
                            color: Qt.darker(mainroot.Material.accent)
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }
                        Text {
                            text: "Eliminar"
                            opacity: enabled ? 1.0 : 0.3
                            //                        color: Qt.darker(mainroot.Material.accent)
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }
    }
}
