import QtQuick
import QtQuick.Controls

RadioButton {
  id: radio

  property bool paintDisabled: true

  opacity: enabled ? 1 : 0.5

  indicator: Rectangle {
    implicitWidth: 16
    implicitHeight: 16
    x: radio.leftPadding
    y: radio.height / 2 - height / 2
    radius: 4
    border.color: radio.down ? palette.highlight.darker() : palette.base
    color: palette.base

    Rectangle {
      width: 8
      height: 8
      x: 4
      y: 4
      radius: 4
      color: radio.down ? palette.highlight.darker() : palette.highlight
      visible: radio.checked && (radio.paintDisabled || radio.enabled)
    }

  }

}
