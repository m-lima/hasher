import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Column {
  id: root

  property alias prefix: prefix.text
  property alias length: length.value
  property alias saltCustom: saltCustom.checked
  property alias saltValue: saltValue.text
  property alias useSha256: algorithmSha256.checked
  property alias deviceAutomatic: deviceAutomatic.checked
  property alias useGpu: gpu.checked
  property alias useMask: maskEnabled.checked
  property alias customMask: maskCustom.checked
  property alias maskValue: maskValue.text
  property Item _current: null

  state: _current ? 'Expanded' : ''

  anchors {
    verticalCenter: parent.verticalCenter
    left: parent.left
    right: parent.right
  }

  CollapsibleItem {
    id: format

    title: qsTr('Format')
    expanded: root._current === this
    onClicked: root._current = this
    innerSpacing: 10

    ComboBox {
      id: templates

      function updateFields() {
        let idx = model.index(currentIndex, 0);
        prefix.text = model.data(idx, Qt.UserRole + 1);
        length.value = model.data(idx, Qt.UserRole + 2);
        maskEnabled.checked = model.data(idx, Qt.UserRole + 3);
      }

      function selectMatching() {
        let idx = 0;
        for (; idx < model.rowCount() - 1; idx++) {
          let index = model.index(idx, 0);
          // Implicit conversion for comparison desired
          if (model.data(index, Qt.UserRole + 2) === length.value && model.data(index, Qt.UserRole + 1) == prefix.text)
            break;

        }
        if (idx !== currentIndex)
          currentIndex = idx;

      }

      width: parent.width
      textRole: 'name'
      model: _templates
      onActivated: updateFields()
      Component.onCompleted: updateFields()
    }

    TextField {
      id: prefix

      width: parent.width
      placeholderText: qsTr('Prefix')
      maximumLength: 25
      onTextEdited: templates.selectMatching()

      validator: RegularExpressionValidator {
        regularExpression: /[0-9]{0,25}/
      }

    }

    RowLayout {
      width: parent.width

      Text {
        text: qsTr('Length:')
        color: palette.buttonText
      }

      SpinBox {
        id: length

        Layout.fillWidth: true
        value: 12
        from: Math.max(prefix.text.length, 3)
        to: 25
        onValueModified: templates.selectMatching()
      }

    }

  }

  CollapsibleItem {
    title: qsTr('Salt')
    expanded: root._current === this
    onClicked: root._current = this

    Switch {
      id: saltCustom

      visible: _hasSalt
      enabled: _hasSalt
      text: qsTr('Custom')
      checked: !_hasSalt
      onCheckedChanged: saltCustom.checked && saltValue.forceActiveFocus()
    }

    TextField {
      id: saltValue

      width: parent.width
      enabled: saltCustom.checked
      placeholderText: qsTr('Salt')
      opacity: enabled ? 1 : 0.5
    }

  }

  CollapsibleItem {
    title: qsTr('Algorithm')
    expanded: root._current === this
    onClicked: root._current = this

    Radio {
      id: algorithmSha256

      text: qsTr('Sha256')
      checked: true
    }

    Radio {
      text: qsTr('Md5')
    }

  }

  CollapsibleItem {
    title: qsTr('Device')
    expanded: root._current === this
    onClicked: root._current = this

    Switch {
      id: deviceAutomatic

      text: qsTr('Automatic')
      checked: true
    }

    Radio {
      id: gpu

      text: qsTr('GPU')
      enabled: !deviceAutomatic.checked
      checked: true
      paintDisabled: false
    }

    Radio {
      text: qsTr('CPU')
      enabled: !deviceAutomatic.checked
      paintDisabled: false
    }

  }

  CollapsibleItem {
    title: qsTr('Mask')
    showLine: false
    expanded: root._current === this
    onClicked: root._current = this

    Row {
      Switch {
        id: maskEnabled

        text: qsTr('Enable')
        checked: false
        onCheckedChanged: !_hasMask && maskEnabled.checked && maskValue.forceActiveFocus()
      }

      Switch {
        id: maskCustom

        text: qsTr('Custom')
        visible: _hasMask
        enabled: _hasMask && maskEnabled.checked
        checked: !_hasMask
        opacity: enabled ? 1 : 0.5
        onCheckedChanged: maskCustom.checked && maskValue.forceActiveFocus()
      }

    }

    TextField {
      id: maskValue

      width: parent.width
      enabled: maskEnabled.checked && maskCustom.checked
      placeholderText: qsTr('XOR mask')
      opacity: enabled ? 1 : 0.5

      validator: RegularExpressionValidator {
        regularExpression: /[0-9a-zA-Z\/+]+[=]{0,2}/
      }

    }

  }

  states: State {
    name: 'Expanded'

    AnchorChanges {
      target: root
      anchors.verticalCenter: undefined
      anchors.top: parent.top
    }

  }

  transitions: Transition {
    AnchorAnimation {
      duration: 200
    }

  }

}
