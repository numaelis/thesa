//this file is part of Tessa
//author Numael Garay
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
//import QtQuick.Layouts 1.3
Button {
      id: minibu
      property string textToolTip: ""
      font.family: fawesome.name
      font.italic: false
      font.pixelSize: width-4

      contentItem: Text {
          text: minibu.text
          font: minibu.font
          opacity: enabled ? 1.0 : 0.3
          color: minibu.down?mainroot.Material.foreground:mainroot.Material.accent//control.down ? "#17a81a" : "#21be2b"
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
          elide: Text.ElideRight
      }

      background: Rectangle {
          implicitWidth: minibu.width
          implicitHeight: minibu.height
          opacity: enabled ? 1 : 0.0
          radius: minibu.width/2
          color: minibu.hovered? Qt.lighter(mainroot.Material.background):"transparent"
      }
      hoverEnabled: true

      ToolTip.delay: 1000
      ToolTip.timeout: 3000
      ToolTip.visible: hovered
      ToolTip.text: textToolTip
      onClicked: {

      }
  }
