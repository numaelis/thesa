import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.2

Button{
    id:bawe
    property string textToolTip: ""
    font.family:fawesome.name
    font.italic: false
    font.pixelSize: 20

    hoverEnabled: true

    ToolTip.delay: 1000
    ToolTip.timeout: 3000
    ToolTip.visible: hovered
    ToolTip.text: textToolTip
}
